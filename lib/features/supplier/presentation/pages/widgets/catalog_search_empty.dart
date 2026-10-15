import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/shared/widgets/custom_button.dart';

class CatalogSearchEmpty extends StatelessWidget {
  const CatalogSearchEmpty({required this.onCreate, super.key});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: AppColors.muted,
            size: 34,
          ),
          const SizedBox(height: 8),
          Text(
            'no_product_found'.tr,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'create_only_if_missing'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          CustomButton(
            label: 'create_new_product'.tr,
            outlined: true,
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}
