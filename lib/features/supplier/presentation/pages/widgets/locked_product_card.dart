import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';

class LockedProductCard extends StatelessWidget {
  const LockedProductCard({required this.product, this.onChange, super.key});

  final ProductModel product;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    final change = onChange;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppAssetImage(
                  product.imageAsset,
                  bytes: product.imageBytes,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'canonical_product'.tr,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        product.manufacturer,
                        product.reference,
                      ].where((part) => part.isNotEmpty).join(' · '),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
            ],
          ),
          const Divider(height: 26),
          Text(
            'canonical_locked'.tr,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
          if (change != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: change,
              icon: const Icon(Icons.swap_horiz_rounded),
              label: Text('select_product'.tr),
            ),
          ],
        ],
      ),
    );
  }
}
