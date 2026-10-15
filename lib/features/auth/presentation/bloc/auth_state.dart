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
    this.accountCreated = false,
    this.pendingOnboarding = false,
    this.signedUp = false,
    this.otpVerified = false,
    this.codeSent = false,
    this.passwordReset = false,
    this.roleSubmitted = false,
    this.passwordChanged = false,
    this.resetToken = '',
    this.onboardingPayload = const {},
    this.signupEmail = '',
    this.signupPassword = '',
    this.locale = LocalizationConfig.fallbackLocale,
    this.revision = 0,
    this.socialSession = false,
    this.socialProvider = '',
  });

  final UserRole role;
  final bool obscurePassword;
  final bool acceptedTerms;
  final bool authenticated;
  final LoadStatus status;
  final String errorMessage;
  final bool accountCreated;
  final bool pendingOnboarding;
  final bool signedUp;
  final bool otpVerified;
  final bool codeSent;
  final bool passwordReset;
  final bool roleSubmitted;
  final bool passwordChanged;
  final String resetToken;
  final Map<String, String> onboardingPayload;
  final String signupEmail;
  final String signupPassword;
  final Locale locale;
  final int revision;
  final bool socialSession;
  final String socialProvider;

  AuthState copyWith({
    UserRole? role,
    bool? obscurePassword,
    bool? acceptedTerms,
    bool? authenticated,
    LoadStatus? status,
    String? errorMessage,
    bool? accountCreated,
    bool? pendingOnboarding,
    bool? signedUp,
    bool? otpVerified,
    bool? codeSent,
    bool? passwordReset,
    bool? roleSubmitted,
    bool? passwordChanged,
    String? resetToken,
    Map<String, String>? onboardingPayload,
    String? signupEmail,
    String? signupPassword,
    Locale? locale,
    int? revision,
    bool? socialSession,
    String? socialProvider,
  }) {
    return AuthState(
      role: role ?? this.role,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      authenticated: authenticated ?? this.authenticated,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      accountCreated: accountCreated ?? this.accountCreated,
      pendingOnboarding: pendingOnboarding ?? this.pendingOnboarding,
      signedUp: signedUp ?? this.signedUp,
      otpVerified: otpVerified ?? this.otpVerified,
      codeSent: codeSent ?? this.codeSent,
      passwordReset: passwordReset ?? this.passwordReset,
      roleSubmitted: roleSubmitted ?? this.roleSubmitted,
      passwordChanged: passwordChanged ?? this.passwordChanged,
      resetToken: resetToken ?? this.resetToken,
      onboardingPayload: onboardingPayload ?? this.onboardingPayload,
      signupEmail: signupEmail ?? this.signupEmail,
      signupPassword: signupPassword ?? this.signupPassword,
      locale: locale ?? this.locale,
      revision: revision ?? this.revision,
      socialSession: socialSession ?? this.socialSession,
      socialProvider: socialProvider ?? this.socialProvider,
    );
  }

  @override
  List<Object?> get props => [
    revision,
    role,
    obscurePassword,
    acceptedTerms,
    authenticated,
    status,
    errorMessage,
    accountCreated,
    pendingOnboarding,
    signedUp,
    otpVerified,
    codeSent,
    passwordReset,
    roleSubmitted,
    passwordChanged,
    resetToken,
    onboardingPayload,
    signupEmail,
    locale,
    socialSession,
    socialProvider,
  ];
}
