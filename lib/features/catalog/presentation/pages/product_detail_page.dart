import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/router/route_args.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_event.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:outmed/features/catalog/presentation/bloc/catalog_state.dart';
import 'package:outmed/features/catalog/presentation/bloc/supplier_directory_bloc.dart';
import 'package:outmed/features/catalog/presentation/pages/widgets/offer_tile.dart';
import 'package:outmed/features/catalog/presentation/pages/widgets/quantity_square_button.dart';
import 'package:outmed/features/messages/data/models/chat_thread.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final ProductModel product;
  String _selectedOfferId = '';
  String selectedSize = 'M';
  int quantity = 1;
  String _error = '';
  bool _hydrated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;
    _hydrated = true;
    product = RouteArgs.maybe<Object>(context)! as ProductModel;
    final catalog = context.read<CatalogBloc>()
      ..add(CatalogProductRequested(product.id));
    final best = catalog.state.bestOfferFor(product.id);
    _selectedOfferId = best?.id ?? '';
    quantity = best?.minimumOrder ?? 1;
  }

  void _openSupplier(SupplierOfferModel offer) {
    final supplier = context.read<SupplierDirectoryBloc>().state.forProduct(
      product,
      offer.supplierName,
    );
    AppNav.push(AppRoutes.supplierProfile, extra: supplier);
  }

  void _messageSupplier(SupplierOfferModel offer) {
    AppNav.push(
      AppRoutes.chat,
      extra: ChatThread(
        title: offer.supplierName,
        participantUserId: product.supplierUserId,
      ),
    );
  }

  void _addToCart(SupplierOfferModel offer) {
    if (offer.stock <= 0) {
      setState(() => _error = 'out_of_stock'.tr);
      return;
    }
    if (quantity < offer.minimumOrder) {
      setState(
        () => _error = 'minimum_order_error'.trParams({
          'count': '${offer.minimumOrder}',
        }),
      );
      return;
    }
    setState(() => _error = '');
    context.read<CartBloc>().add(
      CartItemAdded(product: product, offer: offer, quantity: quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(product.name)),
      body: SafeArea(
        top: false,
        child:
            BlocSelector<
              CatalogBloc,
              CatalogState,
              (ProductModel, List<SupplierOfferModel>)
            >(
              selector: (state) => (
                state.productById(product.id) ?? product,
                state.offersFor(product.id),
              ),
              builder: (context, data) {
                final (details, offers) = data;
                SupplierOfferModel? selected;
                for (final offer in offers) {
                  if (offer.id == _selectedOfferId) selected = offer;
                }
                selected ??= offers.isEmpty ? null : offers.first;
                final offer = selected;
                final inStock = (offer?.stock ?? 0) > 0;
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                        children: [
                          Container(
                            height: 250,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: AppAssetImage(
                              details.imageAsset,
                              bytes: details.imageBytes,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            product.name,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 23,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (offer != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _openSupplier(offer),
                                    child: Text(
                                      offer.supplierName,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                if (product.supplierUserId.isNotEmpty)
                                  TextButton.icon(
                                    onPressed: () => _messageSupplier(offer),
                                    icon: const Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 16,
                                    ),
                                    label: Text('message_supplier'.tr),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${'sar'.tr} ${offer.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'price_includes_vat'.tr,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 4,
                                backgroundColor: inStock
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                inStock ? 'in_stock'.tr : 'out_of_stock'.tr,
                                style: TextStyle(
                                  color: inStock
                                      ? AppColors.success
                                      : AppColors.danger,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 30),
                          Text(
                            'size'.tr,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              for (final size in const ['S', 'M', 'L', 'XL'])
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    end: 8,
                                  ),
                                  child: ChoiceChip(
                                    label: Text(size),
                                    selected: selectedSize == size,
                                    onSelected: (_) =>
                                        setState(() => selectedSize = size),
                                    showCheckmark: false,
                                    selectedColor: AppColors.primary,
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                      color: selectedSize == size
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                    labelStyle: TextStyle(
                                      color: selectedSize == size
                                          ? Colors.white
                                          : AppColors.muted,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Divider(height: 30),
                          Text(
                            'select_quantity'.tr,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              QuantitySquareButton(
                                icon: Icons.remove,
                                onTap: () {
                                  if (quantity > 1) setState(() => quantity--);
                                },
                              ),
                              SizedBox(
                                width: 48,
                                child: Text(
                                  '$quantity',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              QuantitySquareButton(
                                icon: Icons.add,
                                onTap: () => setState(() => quantity++),
                              ),
                            ],
                          ),
                          const Divider(height: 30),
                          Text(
                            'product_information'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            [
                              if (details.description.isNotEmpty)
                                details.description
                              else if (offer != null &&
                                  offer.description.isNotEmpty)
                                offer.description,
                              [
                                details.manufacturer,
                                details.reference,
                                details.packSize,
                              ].where((part) => part.isNotEmpty).join(' · '),
                            ].join('\n\n'),
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'suppliers'.tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${offers.length} ${'offer_count'.tr}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          for (final item in offers)
                            OfferTile(
                              offer: item,
                              selected: item.id == offer?.id,
                              onSelect: () => setState(() {
                                _selectedOfferId = item.id;
                                _error = '';
                              }),
                              onOpenSupplier: () => _openSupplier(item),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomButton(
                            label: 'add_to_cart'.tr,
                            icon: Icons.shopping_cart_outlined,
                            onPressed: offer == null
                                ? null
                                : () => _addToCart(offer),
                          ),
                          InlineErrorText(message: _error),
                        ],
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
