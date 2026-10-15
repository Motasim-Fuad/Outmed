import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/router/route_args.dart';
import 'package:outmed/core/validation/validators.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_event.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_state.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class UpdateStockPage extends StatefulWidget {
  const UpdateStockPage({super.key});

  @override
  State<UpdateStockPage> createState() => _UpdateStockPageState();
}

class _UpdateStockPageState extends State<UpdateStockPage> {
  static const _reasons = [
    'RESTOCK',
    'MANUAL_ADJUSTMENT',
    'DAMAGE_EXPIRY',
    'RETURN',
    'AUDIT_CORRECTION',
  ];

  final formKey = GlobalKey<FormState>();
  final notesController = TextEditingController();
  late final SupplierOfferModel offer;
  late final TextEditingController stockController;
  String reason = _reasons.first;
  bool _hydrated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;
    _hydrated = true;
    offer = RouteArgs.maybe<Object>(context)! as SupplierOfferModel;
    stockController = TextEditingController(text: '${offer.stock}');
    context.read<SupplierBloc>().add(const SupplierFeedbackCleared());
  }

  @override
  void dispose() {
    stockController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    context.read<SupplierBloc>().add(
      SupplierStockAdjusted(
        offer: offer,
        newStock: int.parse(stockController.text.trim()),
        reason: reason,
        notes: notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = context.read<SupplierBloc>().productForOffer(offer);
    return BlocListener<SupplierBloc, SupplierState>(
      listenWhen: (previous, current) =>
          !previous.closePage && current.closePage,
      listener: (context, state) => AppNav.pop(),
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(title: Text('update_stock'.tr)),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            children: [
              GlossyCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? offer.productId,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${'current_stock'.tr}: ${offer.stock} ${'units'.tr}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: stockController,
                label: 'new_stock_quantity'.tr,
                keyboardType: TextInputType.number,
                validator: Validators.wholeNumber(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: reason,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'stock_reason'.tr,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                items: [
                  for (final item in _reasons)
                    DropdownMenuItem(
                      value: item,
                      child: Text('stock_reason_${item.toLowerCase()}'.tr),
                    ),
                ],
                onChanged: (value) =>
                    setState(() => reason = value ?? _reasons.first),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: notesController,
                label: '${'notes'.tr} (${'optional'.tr})',
                maxLines: 3,
              ),
              const SizedBox(height: 22),
              BlocSelector<SupplierBloc, SupplierState, (bool, String)>(
                selector: (state) => (state.saving, state.errorMessage),
                builder: (context, data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomButton(
                      label: 'update_stock'.tr,
                      isLoading: data.$1,
                      onPressed: product == null ? null : _submit,
                    ),
                    InlineErrorText(message: data.$2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
