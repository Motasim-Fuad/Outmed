import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/offer_actions.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class InventoryRow extends StatelessWidget {
  const InventoryRow({required this.offer, required this.product, super.key});

  final SupplierOfferModel offer;
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final status = offer.stock == 0
        ? ('out_of_stock'.tr, AppColors.danger, const Color(0xFFFDECEC))
        : offer.stock < 20
        ? ('low_stock'.tr, const Color(0xFFC67A1D), const Color(0xFFFFF3E4))
        : ('in_stock'.tr, AppColors.success, const Color(0xFFE6F7F0));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlossyCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(10),
              ),
              child: AppAssetImage(
                product.imageAsset,
                bytes: product.imageBytes,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${'sku'.tr} ${product.reference}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  if (product.addedOn.isNotEmpty)
                    Text(
                      '${'added_on'.tr} ${product.addedOn}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${offer.stock} ${'units'.tr}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: status.$3,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: status.$2,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  OfferActions(offer: offer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
