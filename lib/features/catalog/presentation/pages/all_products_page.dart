import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:outmed/shared/widgets/product_card.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final catalog = Get.find<CatalogController>();
  final searchController = TextEditingController();
  late String category;

  @override
  void initState() {
    super.initState();
    category = Get.arguments is String ? Get.arguments as String : 'All';
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<ProductModel> get products {
    final query = searchController.text.trim().toLowerCase();
    return catalog.products
        .where((product) {
          final categoryMatches =
              category == 'All' || product.category == category;
          final queryMatches =
              query.isEmpty || product.searchableText.contains(query);
          return categoryMatches && queryMatches;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(category == 'All' ? 'all_products'.tr : category),
      ),
      body: Obx(
        () => CustomScrollView(
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
                        _FilterChip(
                          text: 'all'.tr,
                          selected: category == 'All',
                          onTap: () => setState(() => category = 'All'),
                        ),
                        _FilterChip(
                          text: 'ppe'.tr,
                          selected: category == 'PPE & Safety',
                          onTap: () =>
                              setState(() => category = 'PPE & Safety'),
                        ),
                        _FilterChip(
                          text: 'surgical'.tr,
                          selected: category == 'Surgical',
                          onTap: () => setState(() => category = 'Surgical'),
                        ),
                        _FilterChip(
                          text: 'diagnostic'.tr,
                          selected: category == 'Diagnostic',
                          onTap: () => setState(() => category = 'Diagnostic'),
                        ),
                        _FilterChip(
                          text: 'dental'.tr,
                          selected: category == 'Dental',
                          onTap: () => setState(() => category = 'Dental'),
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
            if (products.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'no_product_found'.tr,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      onTap: () => Get.toNamed(
                        AppRoutes.productDetail,
                        arguments: product,
                      ),
                    );
                  }, childCount: products.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(text),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: AppColors.primarySoft,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
