import 'package:equatable/equatable.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/profile/data/models/login_activity.dart';

class LoginActivityState extends Equatable {
  const LoginActivityState({
    this.activities = const [],
    this.status = LoadStatus.initial,
    this.errorMessage = '',
  });

  final List<LoginActivity> activities;
  final LoadStatus status;
  final String errorMessage;

  bool get loading => status == LoadStatus.loading && activities.isEmpty;

  LoginActivityState copyWith({
    List<LoginActivity>? activities,
    LoadStatus? status,
    String? errorMessage,
  }) {
    return LoginActivityState(
      activities: activities ?? this.activities,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [activities, status, errorMessage];
}
