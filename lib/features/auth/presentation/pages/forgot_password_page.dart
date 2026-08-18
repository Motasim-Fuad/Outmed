import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/outmed_logo.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController(text: 'demo@outmed.sa');
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    GetUtils.isEmail(value ?? '') ? null : 'invalid_email'.tr,
              ),
              const SizedBox(height: 22),
              CustomButton(
                label: 'send_code'.tr,
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  Get.snackbar('app_name'.tr, 'code_sent'.tr);
                  Get.toNamed(
                    AppRoutes.verifyEmail,
                    arguments: emailController.text,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
