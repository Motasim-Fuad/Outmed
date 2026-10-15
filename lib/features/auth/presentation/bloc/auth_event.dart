import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:outmed/features/auth/domain/user_role.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthRoleSelected extends AuthEvent {
  const AuthRoleSelected(this.role);

  final UserRole role;

  @override
  List<Object?> get props => [role];
}

class AuthRoleToggled extends AuthEvent {
  const AuthRoleToggled();
}

class AuthPasswordVisibilityToggled extends AuthEvent {
  const AuthPasswordVisibilityToggled();
}

class AuthTermsChanged extends AuthEvent {
  const AuthTermsChanged({required this.accepted});

  final bool accepted;

  @override
  List<Object?> get props => [accepted];
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested(this.payload);

  final Map<String, String> payload;

  @override
  List<Object?> get props => [payload];
}

class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
    required this.email,
    required this.fullName,
    required this.location,
    required this.password,
    required this.confirmPassword,
    required this.termsAccepted,
  });

  final String email;
  final String fullName;
  final String location;
  final String password;
  final String confirmPassword;
  final bool termsAccepted;

  @override
  List<Object?> get props => [
    email,
    fullName,
    location,
    password,
    confirmPassword,
    termsAccepted,
  ];
}

class AuthVerifyOtpRequested extends AuthEvent {
  const AuthVerifyOtpRequested({required this.email, required this.code});

  final String email;
  final String code;

  @override
  List<Object?> get props => [email, code];
}

class AuthResendOtpRequested extends AuthEvent {
  const AuthResendOtpRequested(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthForgotPasswordRequested extends AuthEvent {
  const AuthForgotPasswordRequested(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthResetPasswordRequested extends AuthEvent {
  const AuthResetPasswordRequested({
    required this.password,
    required this.confirmPassword,
  });

  final String password;
  final String confirmPassword;

  @override
  List<Object?> get props => [password, confirmPassword];
}

class AuthOnboardingRoleRequested extends AuthEvent {
  const AuthOnboardingRoleRequested();
}

class AuthFeedbackCleared extends AuthEvent {
  const AuthFeedbackCleared();
}

class AuthChangePasswordRequested extends AuthEvent {
  const AuthChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class AuthDeleteAccountRequested extends AuthEvent {
  const AuthDeleteAccountRequested({required this.password, this.reason = ''});

  final String password;
  final String reason;

  @override
  List<Object?> get props => [password, reason];
}

class AuthSessionRestoreRequested extends AuthEvent {
  const AuthSessionRestoreRequested();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}

class AuthLanguageChanged extends AuthEvent {
  const AuthLanguageChanged(this.locale);

  final Locale locale;

  @override
  List<Object?> get props => [locale];
}
