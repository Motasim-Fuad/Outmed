import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_state.dart';

class CartAddedNotice extends StatelessWidget {
  const CartAddedNotice({required this.offerId, super.key});

  final String offerId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CartBloc, CartState, int>(
      selector: (state) => state.quantityOf(offerId),
      builder: (context, quantity) => AnimatedSize(
        duration: const Duration(milliseconds: 220),
        child: quantity == 0
            ? const SizedBox(width: double.infinity)
            : Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'in_cart_count'.trParams({'count': '$quantity'}),
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => AppNav.push(AppRoutes.cart),
                      child: Text('view_cart'.tr),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
