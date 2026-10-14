import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:outmed/core/config/localization/localization_config.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/auth/domain/user_role.dart';

class AuthState extends Equatable {
  const AuthState({
    this.role = UserRole.buyer,
    this.obscurePassword = true,
    this.acceptedTerms = false,
    this.authenticated = false,
    this.status = LoadStatus.initial,
    this.errorMessage = '',
    this.locale = LocalizationConfig.fallbackLocale,
    this.revision = 0,
  });

  final UserRole role;
  final bool obscurePassword;
  final bool acceptedTerms;
  final bool authenticated;
  final LoadStatus status;
  final String errorMessage;
  final Locale locale;
  final int revision;

  AuthState copyWith({
    UserRole? role,
    bool? obscurePassword,
    bool? acceptedTerms,
    bool? authenticated,
    LoadStatus? status,
    String? errorMessage,
    Locale? locale,
    int? revision,
  }) {
    return AuthState(
      role: role ?? this.role,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      authenticated: authenticated ?? this.authenticated,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      locale: locale ?? this.locale,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [revision, role, obscurePassword, acceptedTerms, authenticated, status, errorMessage, locale];
}
