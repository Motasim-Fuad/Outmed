import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';
import 'package:outmed/features/orders/presentation/bloc/order_bloc.dart';
import 'package:outmed/features/orders/presentation/bloc/order_event.dart';
import 'package:outmed/features/orders/presentation/order_status_label.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/shipping_details_dialog.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/supplier_status_badge.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class SupplierOrderCard extends StatelessWidget {
  const SupplierOrderCard({
    required this.order,
    required this.updating,
    super.key,
  });

  final OrderModel order;
  final bool updating;

  Future<void> _confirmReject(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('reject_order'.tr),
        content: Text('confirm_reject_order'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text('reject_order'.tr),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<OrderBloc>().add(OrderCancelRequested(order.id));
    }
  }

  Future<void> _advance(BuildContext context) async {
    final orders = context.read<OrderBloc>();
    if (order.supplierNextStatus != OrderStatus.inTransit) {
      orders.add(OrderStatusAdvanced(order.id));
      return;
    }
    final details = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const ShippingDetailsDialog(),
    );
    if (details == null) return;
    orders.add(
      OrderStatusAdvanced(
        order.id,
        courierName: details.$1,
        trackingNumber: details.$2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlossyCard(
        onTap: () => AppNav.push(
          '${AppRoutes.orderDetail}?from=supplier',
          extra: order,
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.displayId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                SupplierStatusBadge(order: order),
              ],
            ),
            const Divider(height: 24),
            if (order.buyerName.isNotEmpty) ...[
              Text(
                order.buyerName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              order.productName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '${order.quantity} ${'items'.tr} · '
              '${'sar'.tr} ${order.total.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            if (order.supplierCanAdvance) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  if (order.status == OrderStatus.pending) ...[
                    Expanded(
                      child: CustomButton(
                        label: 'reject_order'.tr,
                        outlined: true,
                        onPressed: updating
                            ? null
                            : () => unawaited(_confirmReject(context)),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: CustomButton(
                      label: order.supplierNextAction,
                      isLoading: updating,
                      onPressed: () => unawaited(_advance(context)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
