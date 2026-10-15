import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/l10n/app_locale.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_json.dart';
import 'package:outmed/core/network/api_response.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/core/storage/token_store.dart';
import 'package:outmed/features/auth/domain/user_role.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_event.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.tokens,
    required this._dio,
    this.cache,
    bool authenticated = false,
  }) : super(AuthState(authenticated: authenticated)) {
    on<AuthFeedbackCleared>(_onFeedbackCleared);
    on<AuthChangePasswordRequested>(_onChangePassword);
    on<AuthDeleteAccountRequested>(_onDeleteAccount);
    on<AuthRoleSelected>(_onRole);
    on<AuthRoleToggled>(_onToggleRole);
    on<AuthPasswordVisibilityToggled>(_onPassword);
    on<AuthTermsChanged>(_onTerms);
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthVerifyOtpRequested>(_onVerifyOtp);
    on<AuthResendOtpRequested>(_onResendOtp);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
    on<AuthResetPasswordRequested>(_onResetPassword);
    on<AuthOnboardingRoleRequested>(_onOnboardingRole);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthSessionRestoreRequested>(_onRestore);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthSessionExpired>(_onLogout);
    on<AuthLanguageChanged>(_onLanguage);
  }

  final TokenStore tokens;
  final Dio _dio;
  final RemoteCache? cache;

  void _onFeedbackCleared(AuthFeedbackCleared event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        status: LoadStatus.initial,
        errorMessage: '',
        signedUp: false,
        otpVerified: false,
        codeSent: false,
        passwordReset: false,
        passwordChanged: false,
        accountCreated: false,
        revision: state.revision + 1,
      ),
    );
  }

  Future<void> _onRestore(
    AuthSessionRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.authenticated || !AppEnv.useRemote) return;
    final role = await tokens.load();
    final access = tokens.accessToken;
    if (access == null || access.isEmpty || role == null) return;
    emit(
      state.copyWith(
        role: role == UserRole.supplier.name
            ? UserRole.supplier
            : UserRole.buyer,
        authenticated: true,
        status: LoadStatus.success,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
  }

  Future<void> _onChangePassword(
    AuthChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: LoadStatus.loading,
        errorMessage: '',
        passwordChanged: false,
        revision: state.revision + 1,
      ),
    );
    if (AppEnv.useRemote) {
      try {
        await _dio.post<dynamic>(
          ApiEndpoints.changePassword,
          data: {
            'currentPassword': event.currentPassword,
            'newPassword': event.newPassword,
          },
        );
      } on DioException catch (error) {
        emit(
          state.copyWith(
            status: LoadStatus.failure,
            errorMessage: _message(error),
            revision: state.revision + 1,
          ),
        );
        return;
      }
    }
    emit(
      state.copyWith(
        status: LoadStatus.success,
        passwordChanged: true,
        revision: state.revision + 1,
      ),
    );
  }

  Future<void> _onDeleteAccount(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: LoadStatus.loading,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
    if (AppEnv.useRemote) {
      try {
        await _dio.delete<dynamic>(
          ApiEndpoints.deleteAccount,
          data: {
            'password': event.password,
            if (event.reason.trim().isNotEmpty) 'reason': event.reason.trim(),
          },
        );
      } on DioException catch (error) {
        emit(
          state.copyWith(
            status: LoadStatus.failure,
            errorMessage: _message(error),
            revision: state.revision + 1,
          ),
        );
        return;
      }
    }
    await _signOut(emit);
  }

  void _onRole(AuthRoleSelected event, Emitter<AuthState> emit) {
    emit(state.copyWith(role: event.role, revision: state.revision + 1));
  }

  void _onToggleRole(AuthRoleToggled event, Emitter<AuthState> emit) {
    final next = state.role == UserRole.buyer
        ? UserRole.supplier
        : UserRole.buyer;
    emit(state.copyWith(role: next, revision: state.revision + 1));
  }

  void _onPassword(
    AuthPasswordVisibilityToggled event,
    Emitter<AuthState> emit,
  ) {
    emit(
      state.copyWith(
        obscurePassword: !state.obscurePassword,
        revision: state.revision + 1,
      ),
    );
  }

  void _onTerms(AuthTermsChanged event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        acceptedTerms: event.accepted,
        revision: state.revision + 1,
      ),
    );
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.log('AuthBloc: LoginRequested');
    if (event.email.trim().isEmpty || event.password.trim().isEmpty) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: AppLocale.translate('request_failed'),
          revision: state.revision + 1,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: LoadStatus.loading,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
    if (AppEnv.useRemote) {
      try {
        final response = await _dio.post<dynamic>(
          ApiEndpoints.login,
          data: {'email': event.email.trim(), 'password': event.password},
        );
        final access = ApiJson.accessToken(response.data);
        if (access == null) {
          emit(
            state.copyWith(
              status: LoadStatus.failure,
              errorMessage: AppLocale.translate('request_failed'),
              revision: state.revision + 1,
            ),
          );
          return;
        }
        await tokens.save(
          access: access,
          refresh: ApiJson.refreshToken(response.data),
        );
        final remoteRole = await _profileRole();
        if (remoteRole != null) {
          emit(state.copyWith(role: remoteRole, revision: state.revision + 1));
        }
        await tokens.saveRole(state.role.name);
      } on DioException catch (error) {
        tokens.clear();
        emit(
          state.copyWith(
            status: LoadStatus.failure,
            authenticated: false,
            errorMessage: _message(error),
            revision: state.revision + 1,
          ),
        );
        return;
      }
    }
    emit(
      state.copyWith(
        status: LoadStatus.success,
        authenticated: true,
        accountCreated: false,
        pendingOnboarding: false,
        onboardingPayload: const {},
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.log('AuthBloc: SignUpRequested');
    emit(
      state.copyWith(
        status: LoadStatus.loading,
        errorMessage: '',
        signedUp: false,
        revision: state.revision + 1,
      ),
    );
    if (AppEnv.useRemote) {
      try {
        await _dio.post<dynamic>(
          ApiEndpoints.register,
          data: {
            'email': event.email.trim(),
            'fullName': event.fullName.trim(),
            'location': event.location.trim(),
            'password': event.password,
            'confirmPassword': event.confirmPassword,
            'termsAccepted': event.termsAccepted,
          },
        );
      } on DioException catch (error) {
        emit(
          state.copyWith(
            status: LoadStatus.failure,
            signedUp: false,
            errorMessage: _message(error),
            revision: state.revision + 1,
          ),
        );
        return;
      }
    }
    emit(
      state.copyWith(
        status: LoadStatus.success,
        signedUp: true,
        pendingOnboarding: true,
        signupEmail: event.email.trim(),
        signupPassword: event.password,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
  }

  Future<void> _onVerifyOtp(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: LoadStatus.loading,
        errorMessage: '',
        otpVerified: false,
        revision: state.revision + 1,
      ),
    );
    var token = '';
    if (AppEnv.useRemote) {
      try {
        final response = await _dio.post<dynamic>(
          ApiEndpoints.verifyOtp,
          data: {'email': event.email.trim(), 'code': event.code.trim()},
        );
        token = ApiJson.resetToken(response.data) ?? '';
      } on DioException catch (error) {
        emit(
          state.copyWith(
            status: LoadStatus.failure,
            otpVerified: false,
            errorMessage: _message(error),
            revision: state.revision + 1,
          ),
        );
        return;
      }
    }
    emit(
      state.copyWith(
        status: LoadStatus.success,
        otpVerified: true,
        resetToken: token,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
  }

  Future<void> _onResendOtp(
    AuthResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (!AppEnv.useRemote) return;
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.resendOtp,
        data: {'email': event.email.trim()},
      );
      emit(
        state.copyWith(
          status: LoadStatus.success,
          errorMessage: '',
          revision: state.revision + 1,
        ),
      );
    } on DioException catch (error) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: _message(error),
          revision: state.revision + 1,
        ),
      );
    }
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: LoadStatus.loading,
        errorMessage: '',
        codeSent: false,
        revision: state.revision + 1,
      ),
    );
    if (AppEnv.useRemote) {
      try {
        await _dio.post<dynamic>(
          ApiEndpoints.forgotPassword,
          data: {'email': event.email.trim()},
        );
      } on DioException catch (error) {
        emit(
          state.copyWith(
            status: LoadStatus.failure,
            codeSent: false,
            errorMessage: _message(error),
            revision: state.revision + 1,
          ),
        );
        return;
      }
    }
    emit(
      state.copyWith(
        status: LoadStatus.success,
        codeSent: true,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
  }

  Future<void> _onResetPassword(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: LoadStatus.loading,
        errorMessage: '',
        passwordReset: false,
        revision: state.revision + 1,
      ),
    );
    if (AppEnv.useRemote) {
      try {
        await _dio.post<dynamic>(
          ApiEndpoints.resetPassword,
          data: {
            'resetToken': state.resetToken,
            'newPassword': event.password,
            'confirmPassword': event.confirmPassword,
          },
        );
      } on DioException catch (error) {
        emit(
          state.copyWith(
            status: LoadStatus.failure,
            passwordReset: false,
            errorMessage: _message(error),
            revision: state.revision + 1,
          ),
        );
        return;
      }
    }
    emit(
      state.copyWith(
        status: LoadStatus.success,
        passwordReset: true,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
  }

  Future<void> _onOnboardingRole(
    AuthOnboardingRoleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: LoadStatus.loading,
        errorMessage: '',
        roleSubmitted: false,
        revision: state.revision + 1,
      ),
    );
    if (AppEnv.useRemote) {
      try {
        await _dio.post<dynamic>(
          ApiEndpoints.onboardingRole,
          data: {
            'role': state.role == UserRole.supplier ? 'SUPPLIER' : 'BUYER',
            'termsAccepted': state.acceptedTerms,
          },
        );
      } on DioException catch (error) {
        emit(
          state.copyWith(
            status: LoadStatus.failure,
            roleSubmitted: false,
            errorMessage: _message(error),
            revision: state.revision + 1,
          ),
        );
        return;
      }
    }
    emit(
      state.copyWith(
        status: LoadStatus.success,
        roleSubmitted: true,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.log('AuthBloc: RegisterRequested');
    emit(
      state.copyWith(
        status: LoadStatus.loading,
        accountCreated: false,
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
    if (!AppEnv.useRemote) {
      emit(
        state.copyWith(
          status: LoadStatus.success,
          accountCreated: true,
          pendingOnboarding: false,
          onboardingPayload: const {},
          errorMessage: '',
          revision: state.revision + 1,
        ),
      );
      return;
    }
    try {
      if ((tokens.accessToken ?? '').isEmpty) {
        await _loginForOnboarding();
      }
      await _postRole();
      await _submitOnboarding(event.payload);
      emit(
        state.copyWith(
          status: LoadStatus.success,
          accountCreated: true,
          pendingOnboarding: false,
          onboardingPayload: const {},
          signupPassword: '',
          authenticated: false,
          errorMessage: '',
          revision: state.revision + 1,
        ),
      );
    } on DioException catch (error) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          accountCreated: false,
          authenticated: false,
          errorMessage: _message(error),
          revision: state.revision + 1,
        ),
      );
    }
  }

  Future<void> _loginForOnboarding() async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.login,
      data: {'email': state.signupEmail, 'password': state.signupPassword},
    );
    final access = ApiJson.accessToken(response.data);
    if (access == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: AppLocale.translate('request_failed'),
      );
    }
    await tokens.save(
      access: access,
      refresh: ApiJson.refreshToken(response.data),
    );
  }

  Future<void> _postRole() async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        ApiEndpoints.onboardingRole,
        data: {
          'role': state.role == UserRole.supplier ? 'SUPPLIER' : 'BUYER',
          'termsAccepted': true,
        },
      );
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      if (code == 400 || code == 409) return;
      rethrow;
    }
    final access = ApiJson.accessToken(response.data);
    if (access != null) {
      await tokens.save(
        access: access,
        refresh: ApiJson.refreshToken(response.data),
      );
      return;
    }
    if (state.signupPassword.isNotEmpty) {
      await _loginForOnboarding();
    }
  }

  Future<UserRole?> _profileRole() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.profile);
      return _readRole(response.data);
    } on DioException {
      return null;
    }
  }

  UserRole? _readRole(Object? value) {
    if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key.toString().toLowerCase();
        final item = entry.value;
        if (key == 'role' && item is String) {
          final name = item.toUpperCase();
          if (name == 'SUPPLIER') return UserRole.supplier;
          if (name == 'BUYER') return UserRole.buyer;
        }
        final nested = _readRole(item);
        if (nested != null) return nested;
      }
    }
    if (value is List) {
      for (final item in value) {
        final nested = _readRole(item);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  Future<void> _submitOnboarding(Map<String, String> payload) async {
    final postal = _value(payload, 'postal_code');
    final website = _website(_value(payload, 'website'));
    if (state.role == UserRole.supplier) {
      final year = int.tryParse(_value(payload, 'year_established'));
      await _dio.post<dynamic>(
        ApiEndpoints.supplierOnboardingStep1,
        data: {
          'companyName': _value(payload, 'company_name'),
          'companyType': _value(payload, 'company_type'),
          'registrationNumber': _value(payload, 'commercial_registration'),
          'vatNumber': _value(payload, 'vat_number'),
          'bankName': _value(payload, 'bank_name'),
          'bankAccountHolderName': _value(payload, 'bank_account_holder'),
          'iban': _value(payload, 'iban'),
          'yearsEstablished': year ?? 0,
          if (_value(payload, 'number_of_employees').isNotEmpty)
            'numberOfEmployees': _value(payload, 'number_of_employees'),
          if (website.isNotEmpty) 'companyWebsite': website,
        },
      );
      await _dio.post<dynamic>(
        ApiEndpoints.supplierOnboardingStep2,
        data: {
          'businessAddressLine1': _value(payload, 'address'),
          'businessCity': _value(payload, 'city'),
          'businessPostalCode': postal,
          'businessCountry': _value(payload, 'country'),
          'pickupAddressLine1': _value(payload, 'address'),
          'pickupCity': _value(payload, 'city'),
          'pickupPostalCode': postal,
          'pickupCountry': _value(payload, 'country'),
        },
      );
      final categories = await _dio.get<dynamic>(ApiEndpoints.categories);
      final ids = ApiJson.maps(categories.data)
          .map((row) => ApiJson.text(row, const ['id']))
          .whereType<String>()
          .take(1)
          .toList();
      if (ids.isNotEmpty) {
        await _dio.post<dynamic>(
          ApiEndpoints.supplierOnboardingStep3,
          data: {'medicalCategories': ids},
        );
      }
      return;
    }
    await _dio.post<dynamic>(
      ApiEndpoints.buyerOnboarding,
      data: {
        'organizationName': _value(payload, 'company_name'),
        'registrationNumber': _value(payload, 'commercial_registration'),
        if (_value(payload, 'vat_number').isNotEmpty)
          'vatNumber': _value(payload, 'vat_number'),
        'bankName': _value(payload, 'bank_name'),
        'bankAccountHolderName': _value(payload, 'bank_account_holder'),
        'iban': _value(payload, 'iban'),
        'addressLine1': _value(payload, 'address'),
        'city': _value(payload, 'city'),
        'postalCode': postal,
        'country': _value(payload, 'country'),
        if (website.isNotEmpty) 'website': website,
      },
    );
  }

  String _value(Map<String, String> payload, String key) =>
      payload[key]?.trim() ?? '';

  String _website(String raw) {
    if (raw.isEmpty) return '';
    return raw.contains('://') ? raw : 'https://$raw';
  }

  String _message(DioException error) {
    if (error.response == null) {
      return AppLocale.translate('server_unreachable');
    }
    return ApiResponse.detailMessage(
      error.response?.data,
      AppLocale.translate('request_failed'),
    );
  }

  Future<void> _onLogout(AuthEvent event, Emitter<AuthState> emit) async {
    AppLogger.log('AuthBloc: LogoutRequested');
    if (event is AuthLogoutRequested &&
        AppEnv.useRemote &&
        tokens.accessToken != null) {
      emit(
        state.copyWith(
          status: LoadStatus.loading,
          revision: state.revision + 1,
        ),
      );
      try {
        await _dio.post<dynamic>(ApiEndpoints.logout);
      } on DioException catch (error) {
        AppLogger.log('AuthBloc: logout ${error.type.name}');
      }
    }
    await _signOut(emit);
  }

  Future<void> _signOut(Emitter<AuthState> emit) async {
    tokens.clear();
    await cache?.clear();
    emit(
      const AuthState().copyWith(
        locale: state.locale,
        role: state.role,
        revision: state.revision + 1,
      ),
    );
  }

  void _onLanguage(AuthLanguageChanged event, Emitter<AuthState> emit) {
    AppLocale.instance.setLocale(event.locale);
    emit(state.copyWith(locale: event.locale, revision: state.revision + 1));
  }
}
