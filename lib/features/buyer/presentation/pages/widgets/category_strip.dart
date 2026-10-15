import 'package:flutter/material.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/buyer/presentation/pages/widgets/round_category.dart';

class CategoryStrip extends StatelessWidget {
  const CategoryStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          RoundCategory(
            icon: Icons.apps_rounded,
            label: 'all'.tr,
            selected: true,
            onTap: () => AppNav.push(AppRoutes.allProducts),
          ),
          RoundCategory(
            icon: Icons.health_and_safety_outlined,
            label: 'ppe'.tr,
            onTap: () =>
                AppNav.push(AppRoutes.categoryProducts, extra: 'PPE & Safety'),
          ),
          RoundCategory(
            icon: Icons.cut_rounded,
            label: 'surgical'.tr,
            onTap: () =>
                AppNav.push(AppRoutes.categoryProducts, extra: 'Surgical'),
          ),
          RoundCategory(
            icon: Icons.monitor_heart_outlined,
            label: 'diagnostic'.tr,
            onTap: () =>
                AppNav.push(AppRoutes.categoryProducts, extra: 'Diagnostic'),
          ),
          RoundCategory(
            icon: Icons.medication_outlined,
            label: 'medicine'.tr,
            onTap: () => AppNav.push(AppRoutes.allProducts),
          ),
          RoundCategory(
            icon: Icons.more_horiz_rounded,
            label: 'more'.tr,
            onTap: () => AppNav.push(AppRoutes.allProducts),
          ),
        ],
      ),
    );
  }
}
