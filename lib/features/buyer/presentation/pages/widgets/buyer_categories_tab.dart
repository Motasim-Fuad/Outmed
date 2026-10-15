import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/buyer/presentation/pages/widgets/category_grid_shimmer.dart';
import 'package:outmed/features/buyer/presentation/pages/widgets/category_tile.dart';
import 'package:outmed/features/buyer/presentation/pages/widgets/order_shortcut.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_state.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_state.dart';
import 'package:outmed/features/catalog/presentation/category_match.dart';

class BuyerCategoriesTab extends StatefulWidget {
  const BuyerCategoriesTab({super.key});

  @override
  State<BuyerCategoriesTab> createState() => _BuyerCategoriesTabState();
}

class _BuyerCategoriesTabState extends State<BuyerCategoriesTab> {
  String _query = '';

  Future<void> _refresh() async {
    final bloc = context.read<CategoryBloc>()..add(const CategoryStarted());
    await bloc.stream.firstWhere((state) => state.status != LoadStatus.loading);
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
            children: [
              Text(
                'all_categories'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'search_placeholder'.tr,
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              BlocSelector<CatalogBloc, CatalogState, List<ProductModel>>(
                selector: (state) => state.products,
                builder: (context, products) =>
                    BlocSelector<CategoryBloc, CategoryState, CategoryState>(
                      selector: (state) => state,
                      builder: (context, state) {
                        if (state.loading) return const CategoryGridShimmer();
                        final visible = state.categories
                            .where(
                              (item) =>
                                  query.isEmpty ||
                                  item.name.toLowerCase().contains(query),
                            )
                            .toList(growable: false);
                        if (visible.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              state.errorMessage.isEmpty
                                  ? 'no_categories'.tr
                                  : state.errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          );
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: .86,
                              ),
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final category = visible[index];
                            return CategoryTile(
                              category: category,
                              count:
                                  category.productCount ??
                                  products.where(category.contains).length,
                            );
                          },
                        );
                      },
                    ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'recent_orders'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => AppNav.push(AppRoutes.buyerOrders),
                    child: Text('view_all'.tr),
                  ),
                ],
              ),
              const OrderShortcut(),
            ],
          ),
        ),
      ),
    );
  }
}
