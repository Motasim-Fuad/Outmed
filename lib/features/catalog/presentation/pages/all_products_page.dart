import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/router/route_args.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_state.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/category_state.dart';
import 'package:outmed/features/catalog/presentation/category_match.dart';
import 'package:outmed/features/catalog/presentation/pages/widgets/category_filter_chip.dart';
import 'package:outmed/features/catalog/presentation/pages/widgets/product_grid_shimmer.dart';
import 'package:outmed/features/supplier/data/models/category_option.dart';
import 'package:outmed/shared/widgets/product_card.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final searchController = TextEditingController();
  CategoryOption? category;
  bool _hydrated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;
    _hydrated = true;
    final extra = RouteArgs.maybe<Object>(context);
    if (extra is CategoryOption) category = extra;
    if (extra is String) category = CategoryOption(id: extra, name: extra);
    if (extra is ({String query})) searchController.text = extra.query;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final catalog = context.read<CatalogBloc>()
      ..add(const CatalogRefreshRequested());
    await catalog.stream.firstWhere(
      (state) => state.status != LoadStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    final selected = category;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text(selected?.name ?? 'all_products'.tr)),
      body: BlocSelector<CatalogBloc, CatalogState, (int, CatalogState)>(
        selector: (state) => (state.revision, state),
        builder: (context, data) {
          final catalog = data.$2;
          final products = catalog.products
              .where(
                (product) =>
                    (selected == null || selected.contains(product)) &&
                    (query.isEmpty || product.searchableText.contains(query)),
              )
              .toList(growable: false);
          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                  sliver: SliverList.list(
                    children: [
                      TextField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'search_products'.tr,
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 36,
                        child:
                            BlocSelector<
                              CategoryBloc,
                              CategoryState,
                              List<CategoryOption>
                            >(
                              selector: (state) => state.categories,
                              builder: (context, categories) => ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  CategoryFilterChip(
                                    text: 'all'.tr,
                                    selected: selected == null,
                                    onTap: () =>
                                        setState(() => category = null),
                                  ),
                                  for (final item in categories)
                                    CategoryFilterChip(
                                      text: item.name,
                                      selected:
                                          selected?.id == item.id ||
                                          selected?.name == item.name,
                                      onTap: () =>
                                          setState(() => category = item),
                                    ),
                                ],
                              ),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${products.length} ${'products'.tr}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (catalog.loading)
                  const ProductGridShimmer()
                else if (products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        catalog.errorMessage.isEmpty
                            ? 'no_product_found'.tr
                            : catalog.errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            mainAxisExtent: 268,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = products[index];
                        final offer = catalog.bestOfferFor(product.id);
                        return ProductCard(
                          product: product,
                          offer: offer,
                          onTap: () => AppNav.push(
                            AppRoutes.productDetail,
                            extra: product,
                          ),
                          onAdd: offer == null || offer.stock <= 0
                              ? null
                              : () => context.read<CartBloc>().add(
                                  CartItemAdded(
                                    product: product,
                                    offer: offer,
                                    quantity: offer.minimumOrder,
                                  ),
                                ),
                        );
                      }, childCount: products.length),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
