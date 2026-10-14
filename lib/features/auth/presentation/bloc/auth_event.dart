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
