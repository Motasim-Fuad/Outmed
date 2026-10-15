import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';
import 'package:outmed/features/orders/presentation/bloc/order_bloc.dart';
import 'package:outmed/features/orders/presentation/bloc/order_state.dart';
import 'package:outmed/features/orders/presentation/order_status_label.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';
import 'package:outmed/shared/widgets/shimmer_box.dart';

class OrderShortcut extends StatelessWidget {
  const OrderShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OrderBloc, OrderState, (bool, OrderModel?)>(
      selector: (state) =>
          (state.loading, state.orders.isEmpty ? null : state.orders.first),
      builder: (context, data) {
        if (data.$1) return const ShimmerBox(height: 76, radius: 16);
        final order = data.$2;
        if (order == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'no_orders'.tr,
              style: const TextStyle(color: AppColors.muted),
            ),
          );
        }
        return GlossyCard(
          onTap: () => AppNav.push(AppRoutes.orderDetail, extra: order),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primarySoft,
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.displayId,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      order.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      order.buyerLabel,
                      style: TextStyle(
                        color: order.cancelled
                            ? AppColors.danger
                            : AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        );
      },
    );
  }
}
