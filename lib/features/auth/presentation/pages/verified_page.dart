import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/shared/widgets/custom_button.dart';

class VerifiedPage extends StatelessWidget {
  const VerifiedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              const CircleAvatar(
                radius: 46,
                backgroundColor: AppColors.primarySoft,
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 52,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'verified'.tr,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'verified_body'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
              const Spacer(),
              CustomButton(
                label: 'login_account'.tr,
                onPressed: () => Get.offAllNamed(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
