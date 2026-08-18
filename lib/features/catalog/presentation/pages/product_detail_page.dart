import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/features/catalog/data/models/marketplace_supplier.dart';
import 'package:outmed/features/cart/presentation/controllers/cart_controller.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';
import 'package:outmed/shared/widgets/custom_button.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final ProductModel product;
  late final List<SupplierOfferModel> offers;
  late SupplierOfferModel selectedOffer;
  String selectedSize = 'M';
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    product = Get.arguments as ProductModel;
    offers = Get.find<CatalogController>().offersFor(product.id);
    selectedOffer = offers.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border_rounded),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
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
                      product.imageAsset,
                      bytes: product.imageBytes,
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
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => Get.toNamed(
                      AppRoutes.supplierProfile,
                      arguments: MarketplaceSupplier.byName(
                        selectedOffer.supplierName,
                      ),
                    ),
                    child: Text(
                      selectedOffer.supplierName,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${'sar'.tr} ${selectedOffer.price.toStringAsFixed(2)}',
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 4,
                        backgroundColor: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'in_stock'.tr,
                        style: const TextStyle(
                          color: AppColors.success,
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
                    children: ['S', 'M', 'L', 'XL']
                        .map(
                          (size) => Padding(
                            padding: const EdgeInsetsDirectional.only(end: 8),
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
                        )
                        .toList(growable: false),
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
                      _QuantityButton(
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
                      _QuantityButton(
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
                    '${selectedOffer.description}\n\n'
                    '${product.manufacturer} · ${product.reference} · ${product.packSize}',
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
                  ...offers.map(
                    (offer) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() => selectedOffer = offer),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: offer.id == selectedOffer.id
                                ? AppColors.primarySoft
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: offer.id == selectedOffer.id
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      offer.supplierName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${offer.preparationDays} ${'days'.tr} · ${'minimum_short'.tr} ${offer.minimumOrder}',
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${'sar'.tr} ${offer.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Get.toNamed(
                                  AppRoutes.supplierProfile,
                                  arguments: MarketplaceSupplier.byName(
                                    offer.supplierName,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.storefront_outlined,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
              child: CustomButton(
                label: 'add_to_cart'.tr,
                icon: Icons.shopping_cart_outlined,
                onPressed: () {
                  Get.find<CartController>().add(
                    product: product,
                    offer: selectedOffer,
                    quantity: quantity,
                  );
                  Get.snackbar(
                    'app_name'.tr,
                    'added_to_cart'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
