import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_state.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class ProfileSaveButton extends StatelessWidget {
  const ProfileSaveButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, (bool, String)>(
      selector: (state) => (state.saving, state.errorMessage),
      builder: (context, view) {
        final (saving, error) = view;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomButton(label: label, isLoading: saving, onPressed: onPressed),
            InlineErrorText(message: error),
          ],
        );
      },
    );
  }
}
