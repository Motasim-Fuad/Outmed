import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';
import 'package:outmed/features/orders/presentation/controllers/order_controller.dart';
import 'package:outmed/shared/widgets/custom_button.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({this.success = false, super.key});

  final bool success;

  @override
  Widget build(BuildContext context) {
    final initial = Get.arguments as OrderModel;
    final controller = Get.find<OrderController>();
    return Scaffold(
      appBar: success ? null : AppBar(title: Text('order_details'.tr)),
      body: SafeArea(
        child: Obx(() {
          final order =
              controller.orders.firstWhereOrNull(
                (item) => item.id == initial.id,
              ) ??
              initial;
          return ListView(
            padding: const EdgeInsets.all(22),
            children: [
              if (success) ...[
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
                  order.id,
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
                      '${order.quantity} ${'items'.tr} · ${order.supplierName}',
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
              ...OrderStatus.values.map(
                (status) => _StatusStep(
                  label: _statusLabel(status),
                  complete: status.index <= order.status.index,
                  last: status == OrderStatus.values.last,
                ),
              ),
              const SizedBox(height: 26),
              if (success)
                CustomButton(
                  label: 'continue_shopping'.tr,
                  onPressed: () => Get.back(),
                ),
            ],
          );
        }),
      ),
    );
  }
}

String _statusLabel(OrderStatus status) {
  return switch (status) {
    OrderStatus.pending => 'pending_confirmation'.tr,
    OrderStatus.confirmed => 'confirmed'.tr,
    OrderStatus.preparing => 'preparing'.tr,
    OrderStatus.readyForPickup => 'ready_for_pickup'.tr,
    OrderStatus.inTransit => 'in_transit'.tr,
    OrderStatus.delivered => 'delivered'.tr,
  };
}

class _StatusStep extends StatelessWidget {
  const _StatusStep({
    required this.label,
    required this.complete,
    required this.last,
  });

  final String label;
  final bool complete;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: complete
                      ? AppColors.primary
                      : AppColors.border,
                  child: complete
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : null,
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: complete ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 10, bottom: 24),
              child: Text(
                label,
                style: TextStyle(
                  color: complete ? AppColors.ink : AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
