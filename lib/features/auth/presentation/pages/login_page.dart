import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_event.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_state.dart';
import 'package:outmed/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:outmed/features/auth/presentation/widgets/social_login_buttons.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';
import 'package:outmed/shared/widgets/outmed_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthFeedbackCleared());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'welcome_back'.tr,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'login_subtitle'.tr,
                style: const TextStyle(color: AppColors.muted, fontSize: 14),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: emailController,
                label: 'email'.tr,
                hint: 'name@company.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'required_field'.tr;
                  }
                  return _isEmail(value) ? null : 'invalid_email'.tr;
                },
              ),
              const SizedBox(height: 14),
              BlocSelector<AuthBloc, AuthState, bool>(
                selector: (state) => state.obscurePassword,
                builder: (context, obscure) => AppTextField(
                  controller: passwordController,
                  label: 'password'.tr,
                  obscureText: obscure,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    onPressed: () => context.read<AuthBloc>().add(
                      const AuthPasswordVisibilityToggled(),
                    ),
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'required_field'.tr
                      : null,
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => AppNav.push(AppRoutes.forgotPassword),
                  child: Text('forgot_password'.tr),
                ),
              ),
              const SizedBox(height: 6),
              AuthSubmitButton(
                label: 'sign_in'.tr,
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    context.read<AuthBloc>().add(
                      AuthLoginRequested(
                        email: emailController.text,
                        password: passwordController.text,
                      ),
                    );
                  }
                },
              ),
              const SocialLoginButtons(),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'no_account'.tr,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  TextButton(
                    onPressed: () => AppNav.push(AppRoutes.signUp),
                    child: Text('create_account'.tr),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => context.read<AuthBloc>().add(
                      const AuthLanguageChanged(Locale('en', 'US')),
                    ),
                    child: Text('english'.tr),
                  ),
                  const Text('·'),
                  TextButton(
                    onPressed: () => context.read<AuthBloc>().add(
                      const AuthLanguageChanged(Locale('ar', 'SA')),
                    ),
                    child: Text('arabic'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
}
