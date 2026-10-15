import 'package:equatable/equatable.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/profile/data/models/user_profile.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.profile = UserProfile.empty,
    this.status = LoadStatus.initial,
    this.saving = false,
    this.saved = false,
    this.errorMessage = '',
  });

  final UserProfile profile;
  final LoadStatus status;
  final bool saving;
  final bool saved;
  final String errorMessage;

  ProfileState copyWith({
    UserProfile? profile,
    LoadStatus? status,
    bool? saving,
    bool? saved,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      status: status ?? this.status,
      saving: saving ?? this.saving,
      saved: saved ?? this.saved,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [profile, status, saving, saved, errorMessage];
}
