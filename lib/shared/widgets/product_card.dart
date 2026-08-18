import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.offer,
    required this.onTap,
    this.onAdd,
    this.compact = false,
    super.key,
  });

  final ProductModel product;
  final SupplierOfferModel? offer;
  final VoidCallback onTap;
  final VoidCallback? onAdd;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withValues(alpha: .6)),
            boxShadow: AppColors.glossyShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.mint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: AppAssetImage(
                            product.imageAsset,
                            bytes: product.imageBytes,
                          ),
                        ),
                      ),
                    ),
                    const PositionedDirectional(
                      top: 6,
                      end: 6,
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.favorite_border_rounded,
                          size: 16,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 7 : 10),
              Text(
                product.category.toUpperCase(),
                maxLines: 1,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 9,
                  letterSpacing: .4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              if (offer != null)
                Text(
                  '${'sar'.tr} ${offer!.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              Text(
                offer?.supplierName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'in_stock'.tr,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onAdd,
                    child: const CircleAvatar(
                      radius: 13,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.add, size: 16, color: Colors.white),
                    ),
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
