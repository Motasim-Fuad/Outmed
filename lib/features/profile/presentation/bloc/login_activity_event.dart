import 'package:equatable/equatable.dart';

sealed class LoginActivityEvent extends Equatable {
  const LoginActivityEvent();

  @override
  List<Object?> get props => [];
}

class LoginActivitiesRequested extends LoginActivityEvent {
  const LoginActivitiesRequested();
}
