import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/features/auth/presentation/controllers/auth_controller.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/outmed_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController(text: 'demo@outmed.sa');
  final passwordController = TextEditingController(text: '12345678');
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
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
              Text(
                'continue_as'.tr,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _RoleButton(
                          label: 'buyer'.tr,
                          icon: Icons.business,
                          selected: auth.selectedRole.value == UserRole.buyer,
                          onTap: () => auth.selectRole(UserRole.buyer),
                        ),
                      ),
                      Expanded(
                        child: _RoleButton(
                          label: 'supplier'.tr,
                          icon: Icons.business_center_outlined,
                          selected:
                              auth.selectedRole.value == UserRole.supplier,
                          onTap: () => auth.selectRole(UserRole.supplier),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: emailController,
                label: 'email'.tr,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'required_field'.tr;
                  }
                  return GetUtils.isEmail(value) ? null : 'invalid_email'.tr;
                },
              ),
              const SizedBox(height: 14),
              Obx(
                () => AppTextField(
                  controller: passwordController,
                  label: 'password'.tr,
                  obscureText: auth.obscurePassword.value,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    onPressed: auth.togglePasswordVisibility,
                    icon: Icon(
                      auth.obscurePassword.value
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
                  onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                  child: Text('forgot_password'.tr),
                ),
              ),
              const SizedBox(height: 6),
              CustomButton(
                label: 'sign_in'.tr,
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) auth.login();
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: auth.toggleRole,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.swap_horiz_rounded),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Obx(
                        () => Text(
                          '${'demo_role_hint'.tr}: '
                          '${auth.selectedRole.value == UserRole.buyer ? 'buyer'.tr : 'supplier'.tr}',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'no_account'.tr,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.profileSelection),
                    child: Text('create_account'.tr),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () =>
                        auth.changeLanguage(const Locale('en', 'US')),
                    child: Text('english'.tr),
                  ),
                  const Text('·'),
                  TextButton(
                    onPressed: () =>
                        auth.changeLanguage(const Locale('ar', 'SA')),
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

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected ? Border.all(color: AppColors.primary) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 19,
              color: selected ? AppColors.primary : AppColors.muted,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
