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
import 'package:outmed/features/auth/presentation/widgets/social_login_buttons.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';
import 'package:outmed/shared/widgets/outmed_logo.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscure = true;
  bool acceptedTerms = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthFeedbackCleared());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => !previous.signedUp && current.signedUp,
      listener: (context, state) {
        AppNav.push(
          '${AppRoutes.verifyEmail}?purpose=signup',
          extra: emailController.text.trim(),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              children: [
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutMedLogo(height: 48),
                ),
                const SizedBox(height: 34),
                Text(
                  'sign_up_title'.tr,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 28,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'sign_up_subtitle'.tr,
                  style: const TextStyle(color: AppColors.muted, fontSize: 14),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: nameController,
                  label: 'full_name'.tr,
                  validator: Validators.required,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: emailController,
                  label: 'email'.tr,
                  hint: 'name@company.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: locationController,
                  label: 'location'.tr,
                  validator: Validators.required,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: passwordController,
                  label: 'password'.tr,
                  obscureText: obscure,
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  validator: Validators.strongPassword,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: confirmController,
                  label: 'confirm_password'.tr,
                  obscureText: obscure,
                  validator: (value) => value == passwordController.text
                      ? null
                      : 'passwords_mismatch'.tr,
                ),
                CheckboxListTile(
                  value: acceptedTerms,
                  onChanged: (value) =>
                      setState(() => acceptedTerms = value ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                  title: Text(
                    'accept_terms'.tr,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                AuthSubmitButton(
                  label: 'create_account'.tr,
                  enabled: acceptedTerms,
                  onPressed: _submit,
                ),
                const SocialLoginButtons(),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => AppNav.go(AppRoutes.login),
                  child: Text('log_in'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        email: emailController.text,
        fullName: nameController.text,
        location: locationController.text,
        password: passwordController.text,
        confirmPassword: confirmController.text,
        termsAccepted: acceptedTerms,
      ),
    );
  }
}
