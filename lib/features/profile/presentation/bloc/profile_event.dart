import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

class ProfileUpdateRequested extends ProfileEvent {
  const ProfileUpdateRequested(this.fields);

  final Map<String, Object?> fields;

  @override
  List<Object?> get props => [fields];
}

class ProfileFeedbackCleared extends ProfileEvent {
  const ProfileFeedbackCleared();
}

class ProfileReset extends ProfileEvent {
  const ProfileReset();
}
