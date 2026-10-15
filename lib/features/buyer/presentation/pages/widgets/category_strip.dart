import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/buyer/presentation/pages/widgets/round_category.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_state.dart';
import 'package:outmed/features/catalog/presentation/category_icon.dart';
import 'package:outmed/features/supplier/data/models/category_option.dart';

class CategoryStrip extends StatelessWidget {
  const CategoryStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: BlocSelector<CategoryBloc, CategoryState, List<CategoryOption>>(
        selector: (state) => state.roots,
        builder: (context, categories) => ListView(
          scrollDirection: Axis.horizontal,
          children: [
            RoundCategory(
              icon: Icons.apps_rounded,
              label: 'all'.tr,
              selected: true,
              onTap: () => AppNav.push(AppRoutes.allProducts),
            ),
            for (final category in categories.take(5))
              RoundCategory(
                icon: category.icon,
                label: category.name,
                onTap: () =>
                    AppNav.push(AppRoutes.categoryProducts, extra: category),
              ),
            if (categories.length > 5)
              RoundCategory(
                icon: Icons.more_horiz_rounded,
                label: 'more'.tr,
                onTap: () => AppNav.push(AppRoutes.allProducts),
              ),
          ],
        ),
      ),
    );
  }
}
