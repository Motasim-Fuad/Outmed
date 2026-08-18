import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_assets.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/outmed_logo.dart';

class AuthLandingPage extends StatelessWidget {
  const AuthLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),
          child: Column(
            children: [
              const OutMedLogo(height: 44),
              const Spacer(),
              Container(
                height: 230,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const AppAssetImage(AppAssets.healthFacility),
              ),
              const SizedBox(height: 24),
              Text(
                'join_outmed'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'buy_sell_medical'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, height: 1.45),
              ),
              const Spacer(),
              _SocialButton(
                icon: Icons.email_outlined,
                color: AppColors.accent,
                label: 'sign_up_email'.tr,
                onTap: () => Get.toNamed(AppRoutes.profileSelection),
              ),
              const SizedBox(height: 10),
              _SocialButton(
                icon: Icons.g_mobiledata_rounded,
                color: AppColors.primary,
                label: 'sign_up_google'.tr,
                onTap: () => Get.snackbar('app_name'.tr, 'sign_up_google'.tr),
              ),
              const SizedBox(height: 10),
              _SocialButton(
                icon: Icons.apple,
                color: AppColors.ink,
                label: 'sign_up_apple'.tr,
                onTap: () => Get.snackbar('app_name'.tr, 'sign_up_apple'.tr),
              ),
              const SizedBox(height: 18),
              Text(
                'already_account'.tr,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 8),
              CustomButton(
                label: 'log_in'.tr,
                onPressed: () => Get.toNamed(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
