import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';

class SearchProductTile extends StatelessWidget {
  const SearchProductTile({
    required this.product,
    required this.onTap,
    super.key,
  });

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: SizedBox(
          width: 52,
          child: AppAssetImage(product.imageAsset, bytes: product.imageBytes),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          [
            product.manufacturer,
            product.reference,
          ].where((part) => part.isNotEmpty).join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
