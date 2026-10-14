import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/di/injection.dart';
import 'package:outmed/core/feature_flags/feature_flag_service.dart';
import 'package:outmed/core/feature_flags/feature_key.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/payments/stripe_payment_service.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_event.dart';
import 'package:outmed/features/orders/presentation/bloc/order_bloc.dart';
import 'package:outmed/features/orders/presentation/bloc/order_event.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class CartPage extends StatelessWidget {
  const CartPage({this.showAppBar = false, super.key});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartBloc>();
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: showAppBar ? AppBar(title: Text('your_cart'.tr)) : null,
      body: SafeArea(
        child: Builder(builder: (context) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: AppColors.muted,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'your_cart'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'continue_shopping'.tr,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            );
          }
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
                    ...cart.items.map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 82,
                              height: 82,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.canvas,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: AppAssetImage(
                                item.product.imageAsset,
                                bytes: item.product.imageBytes,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.offer.supplierName,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        '${'sar'.tr} ${item.offer.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const Spacer(),
                                      _CartQuantityButton(
                                        icon: Icons.remove,
                                        onTap: () => cart.add(
                                          CartQuantityChanged(item.offer.id, -1),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      _CartQuantityButton(
                                        icon: Icons.add,
                                        onTap: () => cart.add(
                                          CartQuantityChanged(item.offer.id, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          _PriceRow(label: 'subtotal'.tr, value: cart.subtotal),
                          _PriceRow(
                            label: 'delivery'.tr,
                            value: cart.deliveryFee,
                          ),
                          _PriceRow(label: 'vat'.tr, value: cart.vat),
                          const Divider(height: 24),
                          _PriceRow(
                            label: 'total'.tr,
                            value: cart.total,
                            emphasized: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                child: _CheckoutBar(cart: cart),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CartQuantityButton extends StatelessWidget {
  const _CartQuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 15, color: AppColors.primary),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final double value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: emphasized ? AppColors.ink : AppColors.muted,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '${'sar'.tr} ${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: emphasized ? AppColors.primary : AppColors.ink,
              fontSize: emphasized ? 17 : 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatefulWidget {
  const _CheckoutBar({required this.cart});

  final CartBloc cart;

  @override
  State<_CheckoutBar> createState() => _CheckoutBarState();
}

class _CheckoutBarState extends State<_CheckoutBar> {
  String _error = '';

  Future<void> _pay() async {
    setState(() => _error = '');
    if (getIt<FeatureFlagService>().isEnabled(FeatureKey.stripePayments)) {
      final failure = await getIt<StripePaymentService>().pay(
        amountInMinor: (widget.cart.total * 100).round(),
        currency: 'sar',
      );
      if (!mounted) return;
      if (failure != null) {
        setState(() => _error = failure);
        return;
      }
    }
    context.read<OrderBloc>().add(OrderPlaceRequested(widget.cart.state));
  }

  @override
  Widget build(BuildContext context) {
    final orderError = context.watch<OrderBloc>().state.errorMessage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(label: 'checkout'.tr, onPressed: _pay),
        InlineErrorText(message: _error.isEmpty ? orderError : _error),
      ],
    );
  }
}
