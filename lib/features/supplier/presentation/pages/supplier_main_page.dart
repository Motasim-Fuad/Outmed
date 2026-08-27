import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/messages/presentation/pages/messages_page.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';
import 'package:outmed/features/orders/presentation/controllers/order_controller.dart';
import 'package:outmed/features/profile/presentation/pages/profile_page.dart';
import 'package:outmed/features/supplier/presentation/controllers/supplier_controller.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';
import 'package:outmed/shared/widgets/custom_bottom_nav.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class SupplierMainPage extends StatelessWidget {
  const SupplierMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supplier = Get.find<SupplierController>();
    return Obx(() {
      final currentIndex = supplier.shellIndex.value;
      return Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: const [
            _SupplierHome(),
            _SupplierOrders(),
            SizedBox.shrink(),
            SupplierInventoryPage(embedded: true),
            ProfilePage(supplier: true),
          ],
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: currentIndex,
          onDestinationSelected: (index) {
            if (index == 2) {
              Get.toNamed(AppRoutes.addOffer);
              return;
            }
            supplier.shellIndex.value = index;
          },
          destinations: [
            NavDestination(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'dashboard'.tr,
            ),
            NavDestination(
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long,
              label: 'orders'.tr,
            ),
            NavDestination(
              icon: Icons.add_rounded,
              activeIcon: Icons.add_rounded,
              label: 'catalog'.tr,
              isCenter: true,
            ),
            NavDestination(
              icon: Icons.inventory_2_outlined,
              activeIcon: Icons.inventory_2_rounded,
              label: 'inventory'.tr,
            ),
            NavDestination(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'profile'.tr,
            ),
          ],
        ),
      );
    });
  }
}

void _openMessages() {
  Get.to(() => const MessagesPage(showBack: true));
}

class _SupplierHome extends StatelessWidget {
  const _SupplierHome();

  @override
  Widget build(BuildContext context) {
    final supplier = Get.find<SupplierController>();
    final orders = Get.find<OrderController>();
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Obx(() {
          final today = DateTime.now();
          final todaysOrders = orders.orders
              .where(
                (order) =>
                    order.createdAt.year == today.year &&
                    order.createdAt.month == today.month &&
                    order.createdAt.day == today.day,
              )
              .toList();
          final revenue = (todaysOrders.isEmpty ? orders.orders : todaysOrders)
              .fold<double>(0, (sum, order) => sum + order.total);
          final pendingCount = orders.orders
              .where((order) => order.status == OrderStatus.pending)
              .length;
          final lowStock = supplier.ownOffers
              .where((offer) => offer.stock > 0 && offer.stock < 20)
              .toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(
                      Icons.local_hospital_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${'good_evening'.tr} ',
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(
                            text: 'HealthCare',
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
                  IconButton(
                    onPressed: _openMessages,
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DashboardSummaryCard(
                orderCount: todaysOrders.isEmpty
                    ? orders.orders.length
                    : todaysOrders.length,
                revenue: revenue,
                pendingCount: pendingCount,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.add_box_outlined,
                      title: 'add_product'.tr,
                      subtitle: 'add_new_product'.tr,
                      onTap: () => Get.toNamed(AppRoutes.addOffer),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.inventory_2_outlined,
                      title: 'update_stock'.tr,
                      subtitle: 'manage_inventory'.tr,
                      onTap: () => supplier.shellIndex.value = 3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.shopping_cart_outlined,
                      title: 'orders'.tr,
                      subtitle: 'manage_orders'.tr,
                      onTap: () => supplier.shellIndex.value = 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _SectionLink(
                title: 'recent_orders'.tr,
                onViewAll: () => supplier.shellIndex.value = 1,
              ),
              const SizedBox(height: 10),
              ...orders.orders
                  .take(3)
                  .map((order) => _RecentOrderTile(order: order)),
              const SizedBox(height: 12),
              _SectionLink(
                title: 'low_stock_alert'.tr,
                onViewAll: () => supplier.shellIndex.value = 3,
              ),
              const SizedBox(height: 10),
              ...lowStock.map(
                (offer) => _LowStockTile(
                  offer: offer,
                  product: supplier.productForOffer(offer),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _DashboardSummaryCard extends StatelessWidget {
  const _DashboardSummaryCard({
    required this.orderCount,
    required this.revenue,
    required this.pendingCount,
  });

  final int orderCount;
  final double revenue;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF2BBBAD), Color(0xFF7EDCC9)],
        ),
        boxShadow: AppColors.glossyShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -12,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .14),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: 40,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'business_today'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDate(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _Metric(
                        icon: Icons.shopping_bag_outlined,
                        label: 'todays_orders'.tr,
                        value: '$orderCount',
                      ),
                    ),
                    Expanded(
                      child: _Metric(
                        icon: Icons.payments_outlined,
                        label: 'todays_revenue'.tr,
                        value: '${'sar'.tr} ${revenue.toStringAsFixed(0)}',
                      ),
                    ),
                    Expanded(
                      child: _Metric(
                        icon: Icons.schedule_rounded,
                        label: 'pending_orders'.tr,
                        value: '$pendingCount',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFFE8F6F2), fontSize: 10),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _SectionLink extends StatelessWidget {
  const _SectionLink({required this.title, required this.onViewAll});

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

class _RecentOrderTile extends StatelessWidget {
  const _RecentOrderTile({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlossyCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    order.buyerName.characters.first,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.buyerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${order.id} · ${_formatDate(order.createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'sar'.tr} ${order.total.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Get.toNamed(AppRoutes.orderDetail, arguments: order),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'view_details'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LowStockTile extends StatelessWidget {
  const _LowStockTile({required this.offer, required this.product});

  final SupplierOfferModel offer;
  final ProductModel? product;

  @override
  Widget build(BuildContext context) {
    if (product == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlossyCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(10),
              ),
              child: AppAssetImage(
                product!.imageAsset,
                bytes: product!.imageBytes,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${'sku'.tr} ${product!.reference}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'only_left'.trParams({'count': '${offer.stock}'}),
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            _OfferActions(offer: offer),
          ],
        ),
      ),
    );
  }
}

class SupplierInventoryPage extends StatelessWidget {
  const SupplierInventoryPage({this.embedded = false, super.key});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: embedded ? null : AppBar(title: Text('inventory'.tr)),
      body: const SafeArea(child: _InventoryBody()),
    );
  }
}

class _InventoryBody extends StatefulWidget {
  const _InventoryBody();

  @override
  State<_InventoryBody> createState() => _InventoryBodyState();
}

class _InventoryBodyState extends State<_InventoryBody> {
  String filter = 'all';

  @override
  Widget build(BuildContext context) {
    final supplier = Get.find<SupplierController>();
    return Obx(() {
      final offers = supplier.ownOffers;
      final inStock = offers.where((offer) => offer.stock >= 20).length;
      final lowStock = offers
          .where((offer) => offer.stock > 0 && offer.stock < 20)
          .length;
      final outOfStock = offers.where((offer) => offer.stock == 0).length;
      final visible = offers.where((offer) {
        return switch (filter) {
          'low' => offer.stock > 0 && offer.stock < 20,
          'out' => offer.stock == 0,
          _ => true,
        };
      }).toList();
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'inventory'.tr,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'inventory_subtitle'.tr,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              IconButton(
                onPressed: _openMessages,
                icon: const Icon(Icons.chat_bubble_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InventoryStat(
                  icon: Icons.grid_view_rounded,
                  label: 'total_products'.tr,
                  value: '${offers.length}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InventoryStat(
                  icon: Icons.inventory_2_outlined,
                  label: 'in_stock'.tr,
                  value: '$inStock',
                  valueColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InventoryStat(
                  icon: Icons.warning_amber_rounded,
                  label: 'low_stock'.tr,
                  value: '$lowStock',
                  valueColor: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: '${'all_products_filter'.tr} (${offers.length})',
                  selected: filter == 'all',
                  onTap: () => setState(() => filter = 'all'),
                ),
                _FilterChip(
                  label: '${'low_stock'.tr} ($lowStock)',
                  selected: filter == 'low',
                  onTap: () => setState(() => filter = 'low'),
                ),
                _FilterChip(
                  label: '${'out_of_stock'.tr} ($outOfStock)',
                  selected: filter == 'out',
                  onTap: () => setState(() => filter = 'out'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...visible.map(
            (offer) => _InventoryRow(
              offer: offer,
              product: supplier.productForOffer(offer),
            ),
          ),
        ],
      );
    });
  }
}

class _InventoryStat extends StatelessWidget {
  const _InventoryStat({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryDark,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(
          color: selected ? AppColors.primaryDark : AppColors.border,
        ),
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({required this.offer, required this.product});

  final SupplierOfferModel offer;
  final ProductModel? product;

  @override
  Widget build(BuildContext context) {
    if (product == null) return const SizedBox.shrink();
    final status = offer.stock == 0
        ? ('out_of_stock'.tr, AppColors.danger, const Color(0xFFFDECEC))
        : offer.stock < 20
        ? ('low_stock'.tr, const Color(0xFFC67A1D), const Color(0xFFFFF3E4))
        : ('in_stock'.tr, AppColors.success, const Color(0xFFE6F7F0));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlossyCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(10),
              ),
              child: AppAssetImage(
                product!.imageAsset,
                bytes: product!.imageBytes,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${'sku'.tr} ${product!.reference}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${'added_on'.tr} ${product!.addedOn}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${offer.stock} ${'units'.tr}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: status.$3,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: status.$2,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _OfferActions(offer: offer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupplierOrders extends StatelessWidget {
  const _SupplierOrders();

  @override
  Widget build(BuildContext context) {
    final orders = Get.find<OrderController>();
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Obx(
          () => ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
            children: [
              Text(
                'supplier_orders'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              ...orders.orders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlossyCard(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.id,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            _StatusBadge(status: order.status),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          order.buyerName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.productName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.quantity} ${'items'.tr} · ${'sar'.tr} ${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        if (order.status != OrderStatus.delivered) ...[
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => orders.advanceStatus(order.id),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: Text(_nextOrderAction(order.status)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _nextOrderAction(OrderStatus status) {
  return switch (status) {
    OrderStatus.pending => 'confirm_order'.tr,
    OrderStatus.confirmed => 'mark_preparing'.tr,
    OrderStatus.preparing => 'mark_ready'.tr,
    OrderStatus.readyForPickup => 'move_to_in_transit'.tr,
    OrderStatus.inTransit => 'mark_delivered'.tr,
    OrderStatus.delivered => 'delivered'.tr,
  };
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (text, color, background) = switch (status) {
      OrderStatus.pending => (
        'pending'.tr,
        const Color(0xFFC67A1D),
        const Color(0xFFFFF3E4),
      ),
      OrderStatus.confirmed => (
        'accepted'.tr,
        const Color(0xFF2B6CB0),
        const Color(0xFFE8F1FB),
      ),
      OrderStatus.inTransit => (
        'shipped'.tr,
        AppColors.success,
        const Color(0xFFE6F7F0),
      ),
      OrderStatus.preparing => (
        'preparing'.tr,
        AppColors.primary,
        AppColors.primarySoft,
      ),
      OrderStatus.readyForPickup => (
        'ready_for_pickup'.tr,
        AppColors.primary,
        AppColors.primarySoft,
      ),
      OrderStatus.delivered => (
        'delivered'.tr,
        AppColors.success,
        const Color(0xFFE6F7F0),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _OfferActions extends StatelessWidget {
  const _OfferActions({required this.offer});

  final SupplierOfferModel offer;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'edit_offer'.tr,
      padding: EdgeInsets.zero,
      onSelected: (value) {
        switch (value) {
          case 'stock':
            Get.toNamed(AppRoutes.updateStock, arguments: offer);
          case 'edit':
            Get.toNamed(AppRoutes.addOffer, arguments: offer);
          case 'delete':
            _confirmDeleteOffer(offer);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'stock', child: Text('update_stock'.tr)),
        PopupMenuItem(value: 'edit', child: Text('edit_offer'.tr)),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'delete_offer'.tr,
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary),
        ),
        child: const Icon(
          Icons.more_horiz_rounded,
          size: 16,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

Future<void> _confirmDeleteOffer(SupplierOfferModel offer) async {
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      title: Text('delete_offer'.tr),
      content: Text('confirm_delete_offer'.tr),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          child: Text('delete'.tr),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    Get.find<SupplierController>().deleteOffer(offer.id);
    Get.snackbar('app_name'.tr, 'offer_deleted'.tr);
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
