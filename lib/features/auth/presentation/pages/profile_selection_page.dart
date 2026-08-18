import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_assets.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/features/auth/presentation/controllers/auth_controller.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class ProfileSelectionPage extends StatelessWidget {
  const ProfileSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('select_profile'.tr)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'profile_type_hint'.tr,
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ProfileTypeCard(
                        title: 'healthcare_facility'.tr,
                        subtitle: 'healthcare_facility_hint'.tr,
                        image: AppAssets.healthFacility,
                        selected: auth.selectedRole.value == UserRole.buyer,
                        onTap: () => auth.selectRole(UserRole.buyer),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProfileTypeCard(
                        title: 'suppliers'.tr,
                        subtitle: 'suppliers_hint'.tr,
                        image: AppAssets.supplierWarehouse,
                        selected: auth.selectedRole.value == UserRole.supplier,
                        onTap: () => auth.selectRole(UserRole.supplier),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                CheckboxListTile(
                  value: auth.acceptedTerms.value,
                  onChanged: (value) =>
                      auth.acceptedTerms.value = value ?? false,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                  title: Text(
                    'accept_terms'.tr,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                CustomButton(
                  label: 'continue'.tr,
                  onPressed: auth.acceptedTerms.value
                      ? () => Get.toNamed(AppRoutes.registration)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTypeCard extends StatelessWidget {
  const _ProfileTypeCard({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1.18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: AppAssetImage(image, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
