import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/router/route_args.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_event.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_state.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class UpdateStockPage extends StatefulWidget {
  const UpdateStockPage({super.key});

  @override
  State<UpdateStockPage> createState() => _UpdateStockPageState();
}

class _UpdateStockPageState extends State<UpdateStockPage> {
  late final SupplierOfferModel offer;
  late final TextEditingController stockController;
  var _hydrated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;
    _hydrated = true;
    offer = RouteArgs.maybe<Object>(context)! as SupplierOfferModel;
    stockController = TextEditingController(text: '${offer.stock}');
  }

  @override
  void dispose() {
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supplier = context.watch<SupplierBloc>();
    final product = supplier.productForOffer(offer);
    return BlocListener<SupplierBloc, SupplierState>(
      listenWhen: (previous, current) => !previous.closePage && current.closePage,
      listener: (context, state) => AppNav.pop(),
      child: Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text('update_stock'.tr)),
      body: ListView(
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
          ),
          const SizedBox(height: 22),
          CustomButton(
            label: 'update_stock'.tr,
            onPressed: () {
              supplier.add(
                SupplierOfferSaveRequested(
                  product: product!,
                  price: offer.price,
                  stock: int.parse(stockController.text),
                  description: offer.description,
                  minimumOrder: offer.minimumOrder,
                  preparationDays: offer.preparationDays,
                  existing: offer,
                ),
              );

            },
          ),
        ],
      ),
    ),
    );
  }
}
