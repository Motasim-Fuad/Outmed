import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/validation/validators.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_event.dart';
import 'package:outmed/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final formKey = GlobalKey<FormState>();
  final password = TextEditingController();
  final reason = TextEditingController();

  @override
  void dispose() {
    password.dispose();
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('delete_account'.tr),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('delete_account_hint'.tr),
              const SizedBox(height: 12),
              AppTextField(
                controller: password,
                label: 'password'.tr,
                obscureText: true,
                validator: Validators.required,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: reason,
                label: '${'reason'.tr} (${'optional'.tr})',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              AuthSubmitButton(
                label: 'delete_account'.tr,
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  context.read<AuthBloc>().add(
                    AuthDeleteAccountRequested(
                      password: password.text,
                      reason: reason.text,
                    ),
                  );
                },
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
