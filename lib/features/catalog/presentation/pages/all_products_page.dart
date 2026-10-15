import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/router/route_args.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_state.dart';
import 'package:outmed/features/catalog/presentation/pages/widgets/category_filter_chip.dart';
import 'package:outmed/features/catalog/presentation/pages/widgets/product_grid_shimmer.dart';
import 'package:outmed/shared/widgets/product_card.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  static const List<(String, String)> _filters = [
    ('All', 'all'),
    ('PPE & Safety', 'ppe'),
    ('Surgical', 'surgical'),
    ('Diagnostic', 'diagnostic'),
    ('Dental', 'dental'),
  ];

  final searchController = TextEditingController();
  String category = 'All';
  bool _hydrated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;
    _hydrated = true;
    final extra = RouteArgs.maybe<Object>(context);
    if (extra is String) category = extra;
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
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(category == 'All' ? 'all_products'.tr : category),
      ),
      body: BlocSelector<CatalogBloc, CatalogState, (int, CatalogState)>(
        selector: (state) => (state.revision, state),
        builder: (context, data) {
          final catalog = data.$2;
          final products = catalog.products
              .where(
                (product) =>
                    (category == 'All' || product.category == category) &&
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
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (final filter in _filters)
                              CategoryFilterChip(
                                text: filter.$2.tr,
                                selected: category == filter.$1,
                                onTap: () =>
                                    setState(() => category = filter.$1),
                              ),
                          ],
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
                            childAspectRatio: .70,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          offer: catalog.bestOfferFor(product.id),
                          onTap: () => AppNav.push(
                            AppRoutes.productDetail,
                            extra: product,
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
