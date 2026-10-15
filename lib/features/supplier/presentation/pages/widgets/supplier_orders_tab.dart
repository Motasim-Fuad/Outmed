import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';
import 'package:outmed/features/orders/presentation/bloc/order_bloc.dart';
import 'package:outmed/features/orders/presentation/bloc/order_event.dart';
import 'package:outmed/features/orders/presentation/bloc/order_state.dart';
import 'package:outmed/features/orders/presentation/pages/widgets/order_list_shimmer.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/supplier_order_card.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class SupplierOrdersTab extends StatelessWidget {
  const SupplierOrdersTab({super.key});

  Future<void> _refresh(BuildContext context) async {
    final orders = context.read<OrderBloc>()..add(const OrderStarted());
    await orders.stream.firstWhere(
      (state) => state.status != LoadStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child:
            BlocSelector<
              OrderBloc,
              OrderState,
              (bool, List<OrderModel>, String, String, int)
            >(
              selector: (state) => (
                state.loading,
                state.orders,
                state.updatingId,
                state.errorMessage,
                state.revision,
              ),
              builder: (context, data) {
                if (data.$1) return const OrderListShimmer();
                final orders = data.$2;
                return RefreshIndicator(
                  onRefresh: () => _refresh(context),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                    children: [
                      Text(
                        'supplier_orders'.tr,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      InlineErrorText(message: data.$4),
                      const SizedBox(height: 18),
                      if (orders.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Text(
                            'no_orders'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        ),
                      for (final order in orders)
                        SupplierOrderCard(
                          order: order,
                          updating: data.$3 == order.id,
                        ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}
