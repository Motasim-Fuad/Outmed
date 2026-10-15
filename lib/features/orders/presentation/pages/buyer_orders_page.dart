import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';
import 'package:outmed/features/orders/presentation/bloc/order_bloc.dart';
import 'package:outmed/features/orders/presentation/bloc/order_event.dart';
import 'package:outmed/features/orders/presentation/bloc/order_state.dart';
import 'package:outmed/features/orders/presentation/pages/widgets/buyer_order_card.dart';
import 'package:outmed/features/orders/presentation/pages/widgets/order_list_shimmer.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class BuyerOrdersPage extends StatelessWidget {
  const BuyerOrdersPage({super.key});

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
      appBar: AppBar(title: Text('order_history'.tr)),
      body:
          BlocSelector<
            OrderBloc,
            OrderState,
            (bool, List<OrderModel>, String, int)
          >(
            selector: (state) => (
              state.loading,
              state.orders,
              state.errorMessage,
              state.revision,
            ),
            builder: (context, data) {
              if (data.$1) return const OrderListShimmer();
              final orders = data.$2;
              return RefreshIndicator(
                onRefresh: () => _refresh(context),
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    InlineErrorText(message: data.$3),
                    if (orders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Column(
                          children: [
                            Text(
                              'no_orders'.tr,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'empty_orders_hint'.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    for (final order in orders) BuyerOrderCard(order: order),
                  ],
                ),
              );
            },
          ),
    );
  }
}
