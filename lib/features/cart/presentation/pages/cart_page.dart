import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/cart/domain/cart_item.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_state.dart';
import 'package:outmed/features/cart/presentation/pages/widgets/cart_empty_view.dart';
import 'package:outmed/features/cart/presentation/pages/widgets/cart_item_tile.dart';
import 'package:outmed/features/cart/presentation/pages/widgets/cart_summary_card.dart';
import 'package:outmed/features/cart/presentation/pages/widgets/checkout_bar.dart';
import 'package:outmed/features/cart/presentation/pages/widgets/delivery_details_card.dart';

class CartPage extends StatelessWidget {
  const CartPage({this.showAppBar = false, super.key});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: showAppBar ? AppBar(title: Text('your_cart'.tr)) : null,
      body: SafeArea(
        child: BlocSelector<CartBloc, CartState, (int, List<CartItem>)>(
          selector: (state) => (state.revision, state.items),
          builder: (context, data) {
            final items = data.$2;
            if (items.isEmpty) return const CartEmptyView();
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      if (!showAppBar) ...[
                        Text(
                          'your_cart'.tr,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      for (final item in items) CartItemTile(item: item),
                      const SizedBox(height: 8),
                      const CartSummaryCard(),
                      const SizedBox(height: 12),
                      const DeliveryDetailsCard(),
                    ],
                  ),
                ),
                const ColoredBox(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(18, 12, 18, 14),
                    child: CheckoutBar(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
