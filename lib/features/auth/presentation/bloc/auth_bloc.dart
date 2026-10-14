import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/l10n/app_locale.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_response.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/core/storage/token_store.dart';
import 'package:outmed/features/auth/domain/user_role.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_event.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.tokens, required this._dio, bool authenticated = false})
    : super(AuthState(authenticated: authenticated)) {
    on<AuthRoleSelected>(_onRole);
    on<AuthRoleToggled>(_onToggleRole);
    on<AuthPasswordVisibilityToggled>(_onPassword);
    on<AuthTermsChanged>(_onTerms);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthSessionExpired>(_onLogout);
    on<AuthLanguageChanged>(_onLanguage);
  }

  final TokenStore tokens;
  final Dio _dio;

  void _onRole(AuthRoleSelected event, Emitter<AuthState> emit) {
    emit(state.copyWith(role: event.role, revision: state.revision + 1));
  }

  void _onToggleRole(AuthRoleToggled event, Emitter<AuthState> emit) {
    final next = state.role == UserRole.buyer ? UserRole.supplier : UserRole.buyer;
    emit(state.copyWith(role: next, revision: state.revision + 1));
  }

  void _onPassword(AuthPasswordVisibilityToggled event, Emitter<AuthState> emit) {
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

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
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
    emit(state.copyWith(status: LoadStatus.loading, errorMessage: '', revision: state.revision + 1));
    if (!AppEnv.isMock) {
      try {
        final response = await _dio.post<dynamic>(
          ApiEndpoints.login,
          data: {'email': event.email.trim(), 'password': event.password},
        );
        final body = response.data;
        if (body is Map && body['access_token'] is String) {
          await tokens.save(
            access: body['access_token'] as String,
            refresh: body['refresh_token'] as String?,
          );
        }
      } on DioException catch (error) {
        final message = ApiResponse.detailMessage(
          error.response?.data,
          AppLocale.translate('request_failed'),
        );
        emit(
          state.copyWith(
            status: LoadStatus.failure,
            errorMessage: message,
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
        errorMessage: '',
        revision: state.revision + 1,
      ),
    );
  }

  void _onLogout(AuthEvent event, Emitter<AuthState> emit) {
    AppLogger.log('AuthBloc: LogoutRequested');
    tokens.clear();
    emit(
      const AuthState().copyWith(
        locale: state.locale,
        revision: state.revision + 1,
      ),
    );
  }

  void _onLanguage(AuthLanguageChanged event, Emitter<AuthState> emit) {
    AppLocale.instance.setLocale(event.locale);
    emit(state.copyWith(locale: event.locale, revision: state.revision + 1));
  }
}
