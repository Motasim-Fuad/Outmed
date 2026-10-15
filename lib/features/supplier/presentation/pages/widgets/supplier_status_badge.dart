import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';

class SupplierStatusBadge extends StatelessWidget {
  const SupplierStatusBadge({required this.order, super.key});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final (text, color, background) = order.cancelled
        ? ('cancelled'.tr, AppColors.danger, const Color(0xFFFDECEC))
        : switch (order.status) {
            OrderStatus.pending => (
              'pending'.tr,
              const Color(0xFFC67A1D),
              const Color(0xFFFFF3E4),
            ),
            OrderStatus.confirmed => (
              'accepted'.tr,
              const Color(0xFF2B6CB0),
              const Color(0xFFE8F1FB),
            ),
            OrderStatus.inTransit => (
              'shipped'.tr,
              AppColors.success,
              const Color(0xFFE6F7F0),
            ),
            OrderStatus.preparing => (
              'preparing'.tr,
              AppColors.primary,
              AppColors.primarySoft,
            ),
            OrderStatus.readyForPickup => (
              'ready_for_pickup'.tr,
              AppColors.primary,
              AppColors.primarySoft,
            ),
            OrderStatus.delivered => (
              'delivered'.tr,
              AppColors.success,
              const Color(0xFFE6F7F0),
            ),
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
