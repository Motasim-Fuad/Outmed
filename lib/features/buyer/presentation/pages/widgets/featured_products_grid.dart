import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_state.dart';
import 'package:outmed/shared/widgets/product_card.dart';

class FeaturedProductsGrid extends StatelessWidget {
  const FeaturedProductsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CatalogBloc, CatalogState, (int, CatalogState)>(
      selector: (state) => (state.revision, state),
      builder: (context, data) {
        final catalog = data.$2;
        final products = catalog.featured.take(4).toList();
        if (products.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                catalog.errorMessage.isEmpty
                    ? 'no_products'.tr
                    : catalog.errorMessage,
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: .62,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            final offer = catalog.bestOfferFor(product.id);
            return ProductCard(
              product: product,
              offer: offer,
              onTap: () => AppNav.push(AppRoutes.productDetail, extra: product),
              onAdd: offer == null
                  ? null
                  : () => context.read<CartBloc>().add(
                      CartItemAdded(product: product, offer: offer),
                    ),
            );
          },
        );
      },
    );
  }
}
