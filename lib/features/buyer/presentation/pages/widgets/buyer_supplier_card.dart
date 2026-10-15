import 'package:flutter/material.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/catalog/data/models/marketplace_supplier.dart';
import 'package:outmed/features/catalog/presentation/widgets/supplier_logo.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class BuyerSupplierCard extends StatelessWidget {
  const BuyerSupplierCard({required this.supplier, super.key});

  final MarketplaceSupplier supplier;

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      onTap: () => AppNav.push(AppRoutes.supplierProfile, extra: supplier),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: SupplierLogo(
                logo: supplier.logo,
                name: supplier.name,
                size: 58,
              ),
            ),
          ),
          if (supplier.verified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 10,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'verified'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            supplier.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.warning,
                size: 13,
              ),
              Text(
                '${supplier.rating} (${supplier.reviews})',
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
            ],
          ),
          Text(
            'product_count_label'.trParams({'count': supplier.productsCount}),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
