import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';

class PriceTag extends StatelessWidget {
  const PriceTag({
    required this.offer,
    this.fontSize = 13,
    this.color = AppColors.primary,
    super.key,
  });

  final SupplierOfferModel offer;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text(
          '${'sar'.tr} ${offer.price.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (offer.discounted)
          Text(
            offer.sellingPrice.toStringAsFixed(2),
            style: TextStyle(
              color: AppColors.muted,
              fontSize: fontSize * .8,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}
