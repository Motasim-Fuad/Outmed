import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_event.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_state.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/inventory_filter_chip.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/inventory_row.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/inventory_shimmer.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/inventory_stat.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class InventoryBody extends StatefulWidget {
  const InventoryBody({super.key});

  @override
  State<InventoryBody> createState() => _InventoryBodyState();
}

class _InventoryBodyState extends State<InventoryBody> {
  String filter = 'all';

  Future<void> _refresh() async {
    final supplier = context.read<SupplierBloc>()
      ..add(const SupplierStatsRequested());
    await supplier.stream.firstWhere(
      (state) => state.status != LoadStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final supplier = context.read<SupplierBloc>();
    return BlocSelector<
      SupplierBloc,
      SupplierState,
      (bool, List<SupplierOfferModel>, String)
    >(
      selector: (state) => (
        state.loading && state.offers.isEmpty,
        state.offers,
        state.errorMessage,
      ),
      builder: (context, data) {
        if (data.$1) return const InventoryShimmer();
        final offers = data.$2;
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
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
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
                  const NotificationBell(),
                  IconButton(
                    onPressed: () =>
                        AppNav.push('${AppRoutes.messages}?back=1'),
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InventoryStat(
                      icon: Icons.grid_view_rounded,
                      label: 'total_products'.tr,
                      value: '${offers.length}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InventoryStat(
                      icon: Icons.inventory_2_outlined,
                      label: 'in_stock'.tr,
                      value: '$inStock',
                      valueColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InventoryStat(
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
                    InventoryFilterChip(
                      label: '${'all_products_filter'.tr} (${offers.length})',
                      selected: filter == 'all',
                      onTap: () => setState(() => filter = 'all'),
                    ),
                    InventoryFilterChip(
                      label: '${'low_stock'.tr} ($lowStock)',
                      selected: filter == 'low',
                      onTap: () => setState(() => filter = 'low'),
                    ),
                    InventoryFilterChip(
                      label: '${'out_of_stock'.tr} ($outOfStock)',
                      selected: filter == 'out',
                      onTap: () => setState(() => filter = 'out'),
                    ),
                  ],
                ),
              ),
              InlineErrorText(message: data.$3),
              const SizedBox(height: 14),
              if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    'no_product_found'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ),
              for (final offer in visible)
                if (supplier.productForOffer(offer)
                    case final ProductModel product)
                  InventoryRow(offer: offer, product: product),
            ],
          ),
        );
      },
    );
  }
}
