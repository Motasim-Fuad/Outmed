import 'package:flutter/material.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';
import 'package:outmed/features/orders/presentation/pages/widgets/buy_again_button.dart';
import 'package:outmed/features/orders/presentation/pages/widgets/order_status_pill.dart';

class BuyerOrderCard extends StatelessWidget {
  const BuyerOrderCard({required this.order, super.key});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AppNav.push(AppRoutes.orderDetail, extra: order),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.border),
        ),
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
                OrderStatusPill(order: order),
              ],
            ),
            const Divider(height: 24),
            Text(
              order.productName,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              [
                '${order.quantity} ${'items'.tr}',
                if (order.supplierName.isNotEmpty) order.supplierName,
              ].join(' · '),
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 7),
                Text(
                  'track_order'.tr,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                BuyAgainButton(order: order),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
