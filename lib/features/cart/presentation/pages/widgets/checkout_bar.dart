import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/di/injection.dart';
import 'package:outmed/core/feature_flags/feature_flag_service.dart';
import 'package:outmed/core/feature_flags/feature_key.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/payments/stripe_payment_service.dart';
import 'package:outmed/core/validation/validators.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:outmed/features/orders/presentation/bloc/order_bloc.dart';
import 'package:outmed/features/orders/presentation/bloc/order_event.dart';
import 'package:outmed/features/orders/presentation/bloc/order_state.dart';
import 'package:outmed/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class CheckoutBar extends StatefulWidget {
  const CheckoutBar({super.key});

  @override
  State<CheckoutBar> createState() => _CheckoutBarState();
}

class _CheckoutBarState extends State<CheckoutBar> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phone;
  String _error = '';
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(
      text: context.read<ProfileBloc>().state.profile.phone,
    );
    context.read<OrderBloc>().add(const OrderFeedbackCleared());
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _error = '');
    if (AppEnv.useRemote && !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final cart = context.read<CartBloc>();
    if (getIt<FeatureFlagService>().isEnabled(FeatureKey.stripePayments)) {
      setState(() => _paying = true);
      final failure = await getIt<StripePaymentService>().pay(
        amountInMinor: (cart.total * 100).round(),
        currency: 'sar',
      );
      if (!mounted) return;
      setState(() => _paying = false);
      if (failure != null) {
        setState(() => _error = failure);
        return;
      }
    }
    context.read<OrderBloc>().add(
      OrderPlaceRequested(cart.state, phone: _phone.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: _phone,
            label: 'phone'.tr,
            hint: '+966 5X XXX XXXX',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            validator: Validators.phone,
          ),
          const SizedBox(height: 10),
          BlocSelector<OrderBloc, OrderState, (bool, String)>(
            selector: (state) => (state.placing, state.errorMessage),
            builder: (context, order) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomButton(
                  label: 'checkout'.tr,
                  isLoading: _paying || order.$1,
                  onPressed: _pay,
                ),
                InlineErrorText(message: _error.isEmpty ? order.$2 : _error),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
