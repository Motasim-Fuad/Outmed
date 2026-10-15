import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_state.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthBloc, AuthState, (bool, String)>(
      selector: (state) =>
          (state.status == LoadStatus.loading, state.errorMessage),
      builder: (context, view) {
        final (loading, error) = view;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomButton(
              label: label,
              isLoading: loading,
              onPressed: enabled ? onPressed : null,
            ),
            InlineErrorText(message: error),
          ],
        );
      },
    );
  }
}
