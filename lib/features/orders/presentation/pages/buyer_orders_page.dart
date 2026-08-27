import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';
import 'package:outmed/features/orders/presentation/controllers/order_controller.dart';

class BuyerOrdersPage extends StatelessWidget {
  const BuyerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text('order_history'.tr)),
      body: Obx(() {
        if (controller.orders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return InkWell(
              onTap: () => Get.toNamed(AppRoutes.orderDetail, arguments: order),
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
                        Text(
                          order.id,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        _StatusPill(status: order.status),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      order.productName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.quantity} ${'items'.tr} · ${order.supplierName}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
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
                        _BuyAgainButton(order: order),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _BuyAgainButton extends StatelessWidget {
  const _BuyAgainButton({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        final added = Get.find<OrderController>().buyAgain(order);
        if (!added) {
          Get.snackbar('app_name'.tr, 'offer_unavailable'.tr);
          return;
        }
        Get.snackbar('app_name'.tr, 'added_to_cart'.tr);
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        visualDensity: VisualDensity.compact,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: Text(
        'buy_again'.tr,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(status),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
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
