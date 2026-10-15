import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_state.dart';
import 'package:outmed/features/cart/presentation/pages/widgets/price_row.dart';

class CartSummaryCard extends StatelessWidget {
  const CartSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child:
          BlocSelector<CartBloc, CartState, (double, double, double, double)>(
            selector: (state) =>
                (state.subtotal, state.deliveryFee, state.vat, state.total),
            builder: (context, totals) => Column(
              children: [
                PriceRow(label: 'subtotal'.tr, value: totals.$1),
                PriceRow(label: 'delivery'.tr, value: totals.$2),
                PriceRow(label: 'vat'.tr, value: totals.$3),
                const Divider(height: 24),
                PriceRow(label: 'total'.tr, value: totals.$4, emphasized: true),
              ],
            ),
          ),
    );
  }
}
