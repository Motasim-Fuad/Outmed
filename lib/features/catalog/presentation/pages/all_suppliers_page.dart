import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/features/catalog/data/models/marketplace_supplier.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class AllSuppliersPage extends StatelessWidget {
  const AllSuppliersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text('top_suppliers'.tr)),
      body: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: MarketplaceSupplier.all.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final supplier = MarketplaceSupplier.all[index];
          return GlossyCard(
            onTap: () =>
                Get.toNamed(AppRoutes.supplierProfile, arguments: supplier),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: AppAssetImage(supplier.logo),
                ),
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
                        'verified_supplier'.tr,
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
        },
      ),
    );
  }
}
