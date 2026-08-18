import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/features/auth/presentation/controllers/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.supplier, super.key});

  final bool supplier;

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
          children: [
            Text(
              'my_profile'.tr,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.business_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier
                              ? 'HealthCare Supplies'
                              : 'Al Noor Medical Center',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          supplier ? 'supplier'.tr : 'buyer'.tr,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.verified_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _ProfileItem(
              icon: Icons.person_outline_rounded,
              label: 'edit_profile'.tr,
            ),
            _ProfileItem(
              icon: Icons.business_outlined,
              label: 'company_profile'.tr,
            ),
            _ProfileItem(icon: Icons.shield_outlined, label: 'security'.tr),
            if (!supplier)
              _ProfileItem(
                icon: Icons.receipt_long_outlined,
                label: 'my_orders'.tr,
                onTap: () => Get.toNamed(AppRoutes.buyerOrders),
              ),
            if (!supplier)
              _ProfileItem(
                icon: Icons.location_on_outlined,
                label: 'addresses'.tr,
              ),
            _ProfileItem(
              icon: Icons.language_rounded,
              label: 'language'.tr,
              onTap: () => _showLanguagePicker(auth),
            ),
            _ProfileItem(
              icon: Icons.notifications_none_rounded,
              label: 'notifications'.tr,
            ),
            _ProfileItem(
              icon: Icons.help_outline_rounded,
              label: 'help_support'.tr,
            ),
            _ProfileItem(
              icon: Icons.description_outlined,
              label: 'terms_conditions'.tr,
            ),
            const SizedBox(height: 12),
            _ProfileItem(
              icon: Icons.logout_rounded,
              label: 'logout'.tr,
              danger: true,
              onTap: auth.logout,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(AuthController auth) {
    Get.bottomSheet<void>(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'choose_language'.tr,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('english'.tr),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  auth.changeLanguage(const Locale('en', 'US'));
                  Get.back<void>();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('arabic'.tr),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  auth.changeLanguage(const Locale('ar', 'SA'));
                  Get.back<void>();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            icon,
            color: danger ? AppColors.danger : AppColors.primary,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: danger ? AppColors.danger : AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
        ),
      ),
    );
  }
}
