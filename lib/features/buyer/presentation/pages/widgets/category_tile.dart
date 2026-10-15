import 'package:flutter/material.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/catalog/presentation/category_icon.dart';
import 'package:outmed/features/supplier/data/models/category_option.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({required this.category, required this.count, super.key});

  final CategoryOption category;
  final int count;

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      onTap: () => AppNav.push(AppRoutes.categoryProducts, extra: category),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (category.imageUrl.startsWith('http'))
            AppAssetImage(category.imageUrl, width: 30, height: 30)
          else
            Icon(category.icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            category.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            '$count ${'products'.tr}',
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
