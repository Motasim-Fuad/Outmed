import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/router/route_args.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';
import 'package:outmed/features/orders/presentation/bloc/order_bloc.dart';
import 'package:outmed/features/orders/presentation/bloc/order_event.dart';
import 'package:outmed/features/orders/presentation/bloc/order_state.dart';
import 'package:outmed/features/orders/presentation/order_status_label.dart';
import 'package:outmed/features/orders/presentation/pages/widgets/order_status_step.dart';
import 'package:outmed/features/orders/presentation/pages/widgets/shipment_info_card.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({this.success = false, super.key});

  final bool success;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool _requested = false;

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(const OrderFeedbackCleared());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;
    final initial = RouteArgs.maybe<Object>(context);
    if (initial is OrderModel) {
      context.read<OrderBloc>().add(OrderDetailRequested(initial.id));
    }
  }

  String _stepLabel(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => 'pending_confirmation'.tr,
      OrderStatus.confirmed => 'confirmed'.tr,
      OrderStatus.preparing => 'preparing'.tr,
      OrderStatus.readyForPickup => 'ready_for_pickup'.tr,
      OrderStatus.inTransit => 'in_transit'.tr,
      OrderStatus.delivered => 'delivered'.tr,
    };
  }

  @override
  Widget build(BuildContext context) {
    final initial = RouteArgs.maybe<Object>(context)! as OrderModel;
    final fromSupplier =
        GoRouterState.of(context).uri.queryParameters['from'] == 'supplier';
    return Scaffold(
      appBar: widget.success ? null : AppBar(title: Text('order_details'.tr)),
      body: SafeArea(
        child: BlocSelector<OrderBloc, OrderState, (OrderModel, String)>(
          selector: (state) =>
              (state.byId(initial.id) ?? initial, state.errorMessage),
          builder: (context, data) {
            final order = data.$1;
            if (order.isPlaceholder) {
              return Center(
                child: data.$2.isEmpty
                    ? const CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.all(22),
                        child: InlineErrorText(message: data.$2),
                      ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(22),
              children: [
                if (widget.success) ...[
                  const SizedBox(height: 24),
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.primary,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'order_placed'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.displayId,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 32),
                ],
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [
                          '${order.quantity} ${'items'.tr}',
                          if (order.supplierName.isNotEmpty) order.supplierName,
                        ].join(' · '),
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const Divider(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('total'.tr),
                          Text(
                            '${'sar'.tr} ${order.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'track_order'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                if (order.cancelled)
                  Text(
                    order.buyerLabel,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                else
                  for (final status in OrderStatus.values)
                    OrderStatusStep(
                      label: _stepLabel(status),
                      complete: status.index <= order.status.index,
                      last: status == OrderStatus.values.last,
                    ),
                ShipmentInfoCard(order: order),
                const SizedBox(height: 26),
                if (!fromSupplier)
                  CustomButton(
                    label: 'buy_again'.tr,
                    onPressed: () => context.read<OrderBloc>().add(
                      OrderBuyAgainRequested(order),
                    ),
                  ),
                InlineErrorText(message: data.$2),
                if (widget.success) ...[
                  const SizedBox(height: 12),
                  CustomButton(
                    label: 'continue_shopping'.tr,
                    onPressed: AppNav.pop,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
