import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';

class ShipmentInfoCard extends StatelessWidget {
  const ShipmentInfoCard({required this.order, super.key});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    if (order.trackingNumber.isEmpty && order.courierName.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.courierName.isNotEmpty)
                  Text(
                    '${'courier_name'.tr}: ${order.courierName}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                if (order.trackingNumber.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  SelectableText(
                    '${'tracking_number'.tr}: ${order.trackingNumber}',
                    style: const TextStyle(color: AppColors.ink),
                  ),
                ],
              ],
            ),
          ),
          if (order.trackingNumber.isNotEmpty)
            IconButton(
              tooltip: 'copy'.tr,
              icon: const Icon(Icons.copy_rounded, size: 18),
              onPressed: () => Clipboard.setData(
                ClipboardData(text: order.trackingNumber),
              ),
            ),
        ],
      ),
    );
  }
}
