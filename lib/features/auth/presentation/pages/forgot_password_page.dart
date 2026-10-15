import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_event.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_state.dart';
import 'package:outmed/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';
import 'package:outmed/shared/widgets/outmed_logo.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthFeedbackCleared());
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => !previous.codeSent && current.codeSent,
      listener: (context, state) {
        AppNav.push(
          '${AppRoutes.verifyEmail}?purpose=reset',
          extra: emailController.text.trim(),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text('reset_password'.tr)),
        body: SafeArea(
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              children: [
                const Center(child: OutMedLogo(height: 52)),
                const SizedBox(height: 28),
                Text(
                  'verify_email'.tr,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text('verify_email_body'.tr),
                const SizedBox(height: 22),
                AppTextField(
                  controller: emailController,
                  label: 'email'.tr,
                  hint: 'name@company.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch((value ?? '').trim())
                      ? null
                      : 'invalid_email'.tr,
                ),
                const SizedBox(height: 22),
                AuthSubmitButton(
                  label: 'send_code'.tr,
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    context.read<AuthBloc>().add(
                      AuthForgotPasswordRequested(emailController.text),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
