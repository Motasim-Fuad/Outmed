import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/validation/validators.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_event.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_state.dart';
import 'package:outmed/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:outmed/features/profile/presentation/pages/widgets/delete_account_dialog.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final formKey = GlobalKey<FormState>();
  final current = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthFeedbackCleared());
  }

  @override
  void dispose() {
    current.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
      AuthChangePasswordRequested(
        currentPassword: current.text,
        newPassword: password.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          !previous.passwordChanged && current.passwordChanged,
      listener: (context, state) {
        current.clear();
        password.clear();
        confirm.clear();
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(title: Text('security'.tr)),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            children: [
              Text(
                'change_password'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: current,
                label: 'current_password'.tr,
                obscureText: true,
                validator: Validators.required,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: password,
                label: 'new_password'.tr,
                obscureText: true,
                validator: Validators.strongPassword,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: confirm,
                label: 'confirm_password'.tr,
                obscureText: true,
                validator: (value) =>
                    value == password.text ? null : 'passwords_mismatch'.tr,
              ),
              BlocSelector<AuthBloc, AuthState, bool>(
                selector: (state) => state.passwordChanged,
                builder: (context, changed) => changed
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'password_updated'.tr,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 18),
              AuthSubmitButton(label: 'update_password'.tr, onPressed: _submit),
              const SizedBox(height: 24),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.devices_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  'login_activity'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('login_activity_hint'.tr),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => AppNav.push(AppRoutes.loginActivity),
              ),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'delete_account'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'delete_account_hint'.tr,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => unawaited(
                  showDialog<void>(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: context.read<AuthBloc>(),
                      child: const DeleteAccountDialog(),
                    ),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text('delete_account'.tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
