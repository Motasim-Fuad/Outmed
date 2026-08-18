import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';
import 'package:outmed/shared/widgets/custom_button.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool agreed = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('create_new_password'.tr)),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            children: [
              Text(
                'create_new_password'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'password_hint'.tr,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 22),
              AppTextField(
                controller: passwordController,
                label: 'password'.tr,
                obscureText: true,
                validator: (value) => value == null || value.length < 6
                    ? 'required_field'.tr
                    : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: confirmController,
                label: 'confirm_password'.tr,
                obscureText: true,
                validator: (value) => value == passwordController.text
                    ? null
                    : 'passwords_mismatch'.tr,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: agreed,
                onChanged: (value) => setState(() => agreed = value ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
                title: Text('privacy_agree'.tr),
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'continue'.tr,
                onPressed: agreed
                    ? () {
                        if (formKey.currentState?.validate() ?? false) {
                          Get.offAllNamed(AppRoutes.verified);
                        }
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
