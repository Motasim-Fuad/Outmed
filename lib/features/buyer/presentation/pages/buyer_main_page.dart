import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_assets.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/features/cart/presentation/controllers/cart_controller.dart';
import 'package:outmed/features/cart/presentation/pages/cart_page.dart';
import 'package:outmed/features/catalog/data/models/marketplace_supplier.dart';
import 'package:outmed/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:outmed/features/messages/presentation/pages/messages_page.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';
import 'package:outmed/features/orders/presentation/controllers/order_controller.dart';
import 'package:outmed/features/profile/presentation/pages/profile_page.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';
import 'package:outmed/shared/widgets/custom_bottom_nav.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';
import 'package:outmed/shared/widgets/product_card.dart';

class BuyerMainPage extends StatefulWidget {
  const BuyerMainPage({super.key});

  @override
  State<BuyerMainPage> createState() => _BuyerMainPageState();
}

class _BuyerMainPageState extends State<BuyerMainPage> {
  int currentIndex = 0;

  late final pages = const [
    _BuyerHome(),
    _CategoriesPage(),
    CartPage(),
    MessagesPage(),
    ProfilePage(supplier: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: [
          NavDestination(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'home'.tr,
          ),
          NavDestination(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: 'categories'.tr,
          ),
          NavDestination(
            icon: Icons.shopping_cart_outlined,
            activeIcon: Icons.shopping_cart_rounded,
            label: 'cart'.tr,
            isCenter: true,
          ),
          NavDestination(
            icon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
            label: 'messages'.tr,
          ),
          NavDestination(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'profile'.tr,
          ),
        ],
      ),
    );
  }
}

class _BuyerHome extends StatelessWidget {
  const _BuyerHome();

  @override
  Widget build(BuildContext context) {
    final catalog = Get.find<CatalogController>();
    final cart = Get.find<CartController>();
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Obx(
          () => ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(Icons.person_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${'good_evening'.tr}, ',
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(
                            text: 'Mugdho!',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => catalog.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'search_placeholder'.tr,
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 168,
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B8A7C), Color(0xFF4DB6A8)],
                  ),
                  boxShadow: AppColors.glossyShadow,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'trusted_partner'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'banner_heading'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'banner_subtext'.tr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFE8F6F2),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.allProducts),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF26A69A),
                                    AppColors.primaryDark,
                                  ],
                                ),
                              ),
                              child: Text(
                                '${'shop_now'.tr} →',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 120,
                      child: AppAssetImage(AppAssets.catalogIllustration),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _SectionHeader(
                title: 'shop_by_category'.tr,
                onViewAll: () => Get.toNamed(AppRoutes.allProducts),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 108,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _RoundCategory(
                      icon: Icons.apps_rounded,
                      label: 'all'.tr,
                      selected: true,
                      onTap: () => Get.toNamed(AppRoutes.allProducts),
                    ),
                    _RoundCategory(
                      icon: Icons.health_and_safety_outlined,
                      label: 'ppe'.tr,
                      onTap: () => Get.toNamed(
                        AppRoutes.categoryProducts,
                        arguments: 'PPE & Safety',
                      ),
                    ),
                    _RoundCategory(
                      icon: Icons.cut_rounded,
                      label: 'surgical'.tr,
                      onTap: () => Get.toNamed(
                        AppRoutes.categoryProducts,
                        arguments: 'Surgical',
                      ),
                    ),
                    _RoundCategory(
                      icon: Icons.monitor_heart_outlined,
                      label: 'diagnostic'.tr,
                      onTap: () => Get.toNamed(
                        AppRoutes.categoryProducts,
                        arguments: 'Diagnostic',
                      ),
                    ),
                    _RoundCategory(
                      icon: Icons.medication_outlined,
                      label: 'medicine'.tr,
                      onTap: () => Get.toNamed(AppRoutes.allProducts),
                    ),
                    _RoundCategory(
                      icon: Icons.more_horiz_rounded,
                      label: 'more'.tr,
                      onTap: () => Get.toNamed(AppRoutes.allProducts),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SectionHeader(
                title: 'featured_products'.tr,
                onViewAll: () => Get.toNamed(AppRoutes.allProducts),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: catalog.visibleProducts.take(2).length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: .62,
                ),
                itemBuilder: (context, index) {
                  final product = catalog.visibleProducts[index];
                  final offer = catalog.bestOfferFor(product.id);
                  return ProductCard(
                    product: product,
                    offer: offer,
                    onTap: () => Get.toNamed(
                      AppRoutes.productDetail,
                      arguments: product,
                    ),
                    onAdd: offer == null
                        ? null
                        : () {
                            cart.add(product: product, offer: offer);
                            Get.snackbar('app_name'.tr, 'added_to_cart'.tr);
                          },
                  );
                },
              ),
              const SizedBox(height: 22),
              _SectionHeader(
                title: 'top_suppliers'.tr,
                onViewAll: () => Get.toNamed(AppRoutes.allSuppliers),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 188,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: MarketplaceSupplier.all.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final supplier = MarketplaceSupplier.all[index];
                    return SizedBox(
                      width: 168,
                      child: _SupplierCard(supplier: supplier),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        InkWell(
          onTap: onViewAll,
          child: Text(
            'view_all'.tr,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundCategory extends StatelessWidget {
  const _RoundCategory({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 74,
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                  boxShadow: selected ? AppColors.glossyShadow : null,
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primaryDark : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  const _SupplierCard({required this.supplier});

  final MarketplaceSupplier supplier;

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      onTap: () => Get.toNamed(AppRoutes.supplierProfile, arguments: supplier),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(child: AppAssetImage(supplier.logo, height: 58)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  size: 10,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 3),
                Text(
                  'verified'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            supplier.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.warning,
                size: 13,
              ),
              Text(
                '${supplier.rating} (${supplier.reviews})',
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
            ],
          ),
          Text(
            'product_count_label'.trParams({'count': supplier.productsCount}),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _CategoriesPage extends StatelessWidget {
  const _CategoriesPage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CatalogController>();
    final categories = [
      ('PPE & Safety', Icons.health_and_safety_outlined, 'ppe'),
      ('Surgical', Icons.cut_rounded, 'surgical_instruments'),
      ('Diagnostic', Icons.biotech_outlined, 'diagnostic'),
      ('Dental', Icons.medication_liquid_outlined, 'dental'),
      ('Cardiology', Icons.favorite_outline_rounded, 'cardiology'),
      ('Emergency Care', Icons.medical_services_outlined, 'emergency_care'),
      ('Laboratory', Icons.science_outlined, 'laboratory'),
    ];
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
          children: [
            Text(
              'all_categories'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            TextField(
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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: .86,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final count = controller.products
                    .where((p) => p.category == category.$1)
                    .length;
                return GlossyCard(
                  onTap: () => Get.toNamed(
                    AppRoutes.categoryProducts,
                    arguments: category.$1,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(category.$2, color: AppColors.primary, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        category.$3.tr,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count ${'products'.tr}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
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
                  onPressed: () => Get.toNamed(AppRoutes.buyerOrders),
                  child: Text('view_all'.tr),
                ),
              ],
            ),
            const _OrderShortcut(),
          ],
        ),
      ),
    );
  }
}

class _OrderShortcut extends StatelessWidget {
  const _OrderShortcut();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();
    return Obx(() {
      final order = controller.orders.first;
      return GlossyCard(
        onTap: () => Get.toNamed(AppRoutes.orderDetail, arguments: order),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.primarySoft,
              child: Icon(
                Icons.local_shipping_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    order.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    _buyerOrderStatus(order.status),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      );
    });
  }
}

String _buyerOrderStatus(OrderStatus status) {
  return switch (status) {
    OrderStatus.pending => 'pending_confirmation'.tr,
    OrderStatus.confirmed => 'confirmed'.tr,
    OrderStatus.preparing => 'preparing'.tr,
    OrderStatus.readyForPickup => 'ready_for_pickup'.tr,
    OrderStatus.inTransit => 'in_transit'.tr,
    OrderStatus.delivered => 'delivered'.tr,
  };
}
