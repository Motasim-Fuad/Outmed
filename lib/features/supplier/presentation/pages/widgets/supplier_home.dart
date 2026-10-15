import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';
import 'package:outmed/features/orders/presentation/bloc/order_bloc.dart';
import 'package:outmed/features/orders/presentation/bloc/order_event.dart';
import 'package:outmed/features/orders/presentation/bloc/order_state.dart';
import 'package:outmed/features/supplier/data/models/supplier_stats.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_event.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_state.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/dashboard_summary_card.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/low_stock_tile.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/quick_action_card.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/recent_order_tile.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/supplier_dashboard_shimmer.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/supplier_greeting.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';
import 'package:outmed/shared/widgets/section_header.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class SupplierHome extends StatelessWidget {
  const SupplierHome({super.key});

  Future<void> _refresh(BuildContext context) async {
    final supplier = context.read<SupplierBloc>();
    context.read<OrderBloc>().add(const OrderStarted());
    supplier.add(const SupplierStatsRequested());
    await supplier.stream.firstWhere(
      (state) => state.status != LoadStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final supplier = context.read<SupplierBloc>();
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child:
            BlocSelector<
              SupplierBloc,
              SupplierState,
              (bool, int, SupplierStats, String)
            >(
              selector: (state) => (
                state.loading && state.offers.isEmpty,
                state.revision,
                state.stats,
                state.errorMessage,
              ),
              builder: (context, supplierData) {
                if (supplierData.$1) return const SupplierDashboardShimmer();
                final stats = supplierData.$3;
                final lowStock = supplier.state.offers
                    .where((offer) => offer.stock > 0 && offer.stock < 20)
                    .toList();
                return RefreshIndicator(
                  onRefresh: () => _refresh(context),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                    children: [
                      const SupplierGreeting(),
                      const SizedBox(height: 16),
                      BlocSelector<OrderBloc, OrderState, List<OrderModel>>(
                        selector: (state) => state.orders,
                        builder: (context, orders) {
                          final today = DateTime.now();
                          final todays = orders
                              .where(
                                (order) =>
                                    order.createdAt.year == today.year &&
                                    order.createdAt.month == today.month &&
                                    order.createdAt.day == today.day,
                              )
                              .toList();
                          return DashboardSummaryCard(
                            orderCount: stats.todayOrders ?? todays.length,
                            revenue:
                                stats.todayRevenue ??
                                todays.fold<double>(
                                  0,
                                  (sum, order) => sum + order.total,
                                ),
                            pendingCount:
                                stats.pendingOrders ??
                                orders
                                    .where(
                                      (order) =>
                                          !order.cancelled &&
                                          order.status == OrderStatus.pending,
                                    )
                                    .length,
                          );
                        },
                      ),
                      InlineErrorText(message: supplierData.$4),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.add_box_outlined,
                              title: 'add_product'.tr,
                              subtitle: 'add_new_product'.tr,
                              onTap: () => AppNav.push(AppRoutes.addOffer),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.inventory_2_outlined,
                              title: 'update_stock'.tr,
                              subtitle: 'manage_inventory'.tr,
                              onTap: () =>
                                  supplier.add(const SupplierShellSelected(3)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.shopping_cart_outlined,
                              title: 'orders'.tr,
                              subtitle: 'manage_orders'.tr,
                              onTap: () =>
                                  supplier.add(const SupplierShellSelected(1)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      SectionHeader(
                        title: 'recent_orders'.tr,
                        onViewAll: () =>
                            supplier.add(const SupplierShellSelected(1)),
                      ),
                      const SizedBox(height: 10),
                      BlocSelector<
                        OrderBloc,
                        OrderState,
                        (bool, List<OrderModel>)
                      >(
                        selector: (state) => (state.loading, state.orders),
                        builder: (context, data) {
                          if (data.$1) {
                            return const ShimmerBox(height: 92, radius: 16);
                          }
                          if (data.$2.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'no_orders'.tr,
                                style: const TextStyle(color: AppColors.muted),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              for (final order in data.$2.take(3))
                                RecentOrderTile(order: order),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SectionHeader(
                        title: 'low_stock_alert'.tr,
                        onViewAll: () =>
                            supplier.add(const SupplierShellSelected(3)),
                      ),
                      const SizedBox(height: 10),
                      for (final offer in lowStock)
                        if (supplier.productForOffer(offer)
                            case final ProductModel product)
                          LowStockTile(offer: offer, product: product),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}
