import 'package:flutter/material.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/catalog/data/models/marketplace_supplier.dart';
import 'package:outmed/features/catalog/presentation/widgets/supplier_logo.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class SupplierTile extends StatelessWidget {
  const SupplierTile({required this.supplier, super.key});

  final MarketplaceSupplier supplier;

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      onTap: () => AppNav.push(AppRoutes.supplierProfile, extra: supplier),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          SupplierLogo(logo: supplier.logo, name: supplier.name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  supplier.verified
                      ? 'verified_supplier'.tr
                      : supplier.companyType,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.star_rounded, color: AppColors.warning),
          Text(supplier.rating),
        ],
      ),
    );
  }
}
