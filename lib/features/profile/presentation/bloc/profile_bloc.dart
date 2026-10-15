import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_error.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/auth/domain/user_role.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/profile/data/models/user_profile.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_event.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._dio, this._cache, this._auth)
    : super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileUpdateRequested>(_onUpdate);
    on<ProfileFeedbackCleared>(
      (event, emit) => emit(state.copyWith(saved: false, errorMessage: '')),
    );
    on<ProfileReset>((event, emit) => emit(const ProfileState()));
  }

  final Dio _dio;
  final RemoteCache _cache;
  final AuthBloc _auth;

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    if (!AppEnv.useRemote) {
      emit(state.copyWith(profile: _demo, status: LoadStatus.success));
      return;
    }
    final cached = _cache.peek(ApiEndpoints.profile);
    emit(
      state.copyWith(
        profile: cached == null ? null : UserProfile.parse(cached),
        status: cached == null ? LoadStatus.loading : LoadStatus.success,
        errorMessage: '',
      ),
    );
    try {
      final body = await _cache.get(ApiEndpoints.profile);
      emit(
        state.copyWith(
          profile: UserProfile.parse(body),
          status: LoadStatus.success,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: ApiError.message(error),
        ),
      );
    }
  }

  Future<void> _onUpdate(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final fields = {
      for (final entry in event.fields.entries)
        if (entry.value != null && entry.value.toString().trim().isNotEmpty)
          entry.key: entry.value is String
              ? (entry.value! as String).trim()
              : entry.value,
    };
    emit(state.copyWith(saving: true, saved: false, errorMessage: ''));
    if (!AppEnv.useRemote) {
      emit(
        state.copyWith(
          saving: false,
          saved: true,
          profile: _merge(state.profile, fields),
        ),
      );
      return;
    }
    try {
      final supplier = _auth.state.role == UserRole.supplier;
      await _dio.patch<dynamic>(
        supplier ? ApiEndpoints.supplierProfile : ApiEndpoints.buyerProfile,
        data: fields,
      );
      final body = await _cache.get(ApiEndpoints.profile);
      emit(
        state.copyWith(
          saving: false,
          saved: true,
          profile: UserProfile.parse(body),
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(saving: false, errorMessage: ApiError.message(error)),
      );
    }
  }

  UserProfile _merge(UserProfile profile, Map<String, Object?> fields) {
    String value(String key, String fallback) =>
        fields[key]?.toString() ?? fallback;
    return UserProfile(
      userId: profile.userId,
      email: profile.email,
      fullName: profile.fullName,
      phone: profile.phone,
      role: profile.role,
      organization: value(
        'companyName',
        value('organizationName', profile.organization),
      ),
      companyType: value('companyType', profile.companyType),
      logoUrl: value('logoUrl', profile.logoUrl),
      bankName: value('bankName', profile.bankName),
      bankAccountHolderName: value(
        'bankAccountHolderName',
        profile.bankAccountHolderName,
      ),
      iban: value('iban', profile.iban),
      country: value('country', profile.country),
      city: value('city', profile.city),
      fullAddress: value('fullAddress', profile.fullAddress),
      postalCode: value('postalCode', profile.postalCode),
      pickupAddress: value('pickupAddress', profile.pickupAddress),
      website: value('companyWebsite', profile.website),
      yearsEstablished: value('yearsEstablished', profile.yearsEstablished),
      numberOfEmployees: value('numberOfEmployees', profile.numberOfEmployees),
    );
  }

  static const _demo = UserProfile(
    userId: 'demo-user',
    email: 'mugdho@outmed.app',
    fullName: 'Mugdho Rahman',
    phone: '+966 50 000 0000',
    organization: 'Riyadh Care Hospital',
    country: 'Saudi Arabia',
    city: 'Riyadh',
    fullAddress: 'King Fahd Road',
    postalCode: '12211',
  );
}
