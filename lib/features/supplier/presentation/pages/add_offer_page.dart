import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/supplier/presentation/controllers/supplier_controller.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';
import 'package:outmed/shared/widgets/custom_button.dart';

class AddOfferPage extends StatefulWidget {
  const AddOfferPage({super.key});

  @override
  State<AddOfferPage> createState() => _AddOfferPageState();
}

class _AddOfferPageState extends State<AddOfferPage> {
  final supplier = Get.find<SupplierController>();
  final formKey = GlobalKey<FormState>();
  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final categoryController = TextEditingController();
  final manufacturerController = TextEditingController();
  final referenceController = TextEditingController();
  final specificationsController = TextEditingController();
  final packSizeController = TextEditingController();
  final barcodeController = TextEditingController();
  final countryController = TextEditingController();
  final storageController = TextEditingController();
  final documentController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();
  final minimumOrderController = TextEditingController(text: '1');
  final preparationController = TextEditingController(text: '2');
  SupplierOfferModel? existing;
  bool showCreateForm = false;
  Uint8List? selectedImageBytes;

  @override
  void initState() {
    super.initState();
    if (Get.arguments case final SupplierOfferModel offer) {
      existing = offer;
      final product = supplier.productForOffer(offer);
      if (product != null) supplier.selectProduct(product);
      priceController.text = offer.price.toStringAsFixed(2);
      stockController.text = '${offer.stock}';
      descriptionController.text = offer.description;
      minimumOrderController.text = '${offer.minimumOrder}';
      preparationController.text = '${offer.preparationDays}';
    } else {
      supplier.clearSelection();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    nameController.dispose();
    brandController.dispose();
    categoryController.dispose();
    manufacturerController.dispose();
    referenceController.dispose();
    specificationsController.dispose();
    packSizeController.dispose();
    barcodeController.dispose();
    countryController.dispose();
    storageController.dispose();
    documentController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
    minimumOrderController.dispose();
    preparationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          existing == null ? 'add_product_offer'.tr : 'edit_offer'.tr,
        ),
      ),
      body: Form(
        key: formKey,
        child: Obx(
          () => ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              if (supplier.selectedProduct.value == null) ...[
                _SectionHeader(
                  title: 'search_before_create'.tr,
                  subtitle: 'select_master_product_hint'.tr,
                ),
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    supplier.searchQuery.value = value;
                    setState(() => showCreateForm = false);
                  },
                  decoration: InputDecoration(
                    hintText: 'search_catalog'.tr,
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (searchController.text.isNotEmpty &&
                    supplier.searchResults.isNotEmpty)
                  ...supplier.searchResults.map(
                    (product) => _SearchProductTile(
                      product: product,
                      onTap: () {
                        supplier.selectProduct(product);
                        setState(() => showCreateForm = false);
                      },
                    ),
                  ),
                if (searchController.text.isNotEmpty &&
                    supplier.searchResults.isEmpty &&
                    !showCreateForm)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          color: AppColors.muted,
                          size: 34,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'no_product_found'.tr,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'create_only_if_missing'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        CustomButton(
                          label: 'create_new_product'.tr,
                          outlined: true,
                          onPressed: () {
                            nameController.text = searchController.text;
                            setState(() => showCreateForm = true);
                          },
                        ),
                      ],
                    ),
                  ),
                if (showCreateForm) _buildCreateForm(),
              ] else ...[
                _buildLockedProduct(supplier.selectedProduct.value!),
                const SizedBox(height: 20),
                _buildOfferForm(supplier.selectedProduct.value!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _SectionHeader(
          title: 'create_new_product'.tr,
          subtitle: 'canonical_locked'.tr,
        ),
        InkWell(
          onTap: _pickProductImage,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selectedImageBytes == null
                    ? AppColors.border
                    : AppColors.primary,
              ),
            ),
            child: selectedImageBytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: AppColors.primarySoft,
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'upload_product_image'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'product_image'.tr,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.memory(
                          selectedImageBytes!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      PositionedDirectional(
                        top: 8,
                        end: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.ink.withValues(alpha: .78),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'change_product_image'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: nameController,
          label: 'product_name'.tr,
          validator: _required,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: brandController,
          label: 'brand'.tr,
          validator: _required,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: categoryController,
          label: 'category'.tr,
          validator: _required,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: manufacturerController,
          label: 'manufacturer'.tr,
          validator: _required,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: referenceController,
          label: 'model_number'.tr,
          validator: _required,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: specificationsController,
          label: 'specifications'.tr,
          validator: _required,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: packSizeController,
          label: 'pack_size'.tr,
          validator: _required,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: barcodeController,
          label: 'barcode_udi'.tr,
          validator: _required,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: countryController,
          label: 'country_of_origin'.tr,
          validator: _required,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: storageController,
          label: 'storage_requirements'.tr,
          maxLines: 2,
          validator: _required,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: documentController,
          label: 'product_documents'.tr,
          hint: 'upload_product_document'.tr,
        ),
        const SizedBox(height: 16),
        CustomButton(
          label: 'create_new_product'.tr,
          onPressed: () {
            if (!(formKey.currentState?.validate() ?? false)) return;
            if (selectedImageBytes == null) {
              Get.snackbar('app_name'.tr, 'image_required'.tr);
              return;
            }
            try {
              supplier.createMasterProduct(
                name: nameController.text,
                brand: brandController.text,
                category: categoryController.text,
                manufacturer: manufacturerController.text,
                reference: referenceController.text,
                specifications: specificationsController.text,
                packSize: packSizeController.text,
                barcode: barcodeController.text,
                countryOfOrigin: countryController.text,
                storageRequirements: storageController.text,
                documentName: documentController.text,
                imageBytes: selectedImageBytes!,
              );
              Get.snackbar('app_name'.tr, 'product_created'.tr);
            } on StateError {
              Get.snackbar(
                'app_name'.tr,
                'duplicate_product'.tr,
                backgroundColor: AppColors.danger,
                colorText: Colors.white,
              );
            }
          },
        ),
      ],
    );
  }

  Future<void> _pickProductImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1400,
    );
    if (image == null || !mounted) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() => selectedImageBytes = bytes);
  }

  Widget _buildLockedProduct(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppAssetImage(
                  product.imageAsset,
                  bytes: product.imageBytes,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'canonical_product'.tr,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${product.manufacturer} · ${product.reference}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
            ],
          ),
          const Divider(height: 26),
          Text(
            'canonical_locked'.tr,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
          if (existing == null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: supplier.clearSelection,
              icon: const Icon(Icons.swap_horiz_rounded),
              label: Text('select_product'.tr),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOfferForm(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'offer_information'.tr,
          subtitle: 'supplier_editable_fields'.tr,
        ),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: priceController,
                label: 'price'.tr,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _required,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppTextField(
                controller: stockController,
                label: 'stock'.tr,
                keyboardType: TextInputType.number,
                validator: _required,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: descriptionController,
          label: 'description'.tr,
          maxLines: 4,
          validator: _required,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: minimumOrderController,
                label: 'minimum_order'.tr,
                keyboardType: TextInputType.number,
                validator: _required,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppTextField(
                controller: preparationController,
                label: 'preparation_days'.tr,
                keyboardType: TextInputType.number,
                validator: _required,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        CustomButton(
          label: existing == null ? 'save_offer'.tr : 'update_offer'.tr,
          onPressed: () {
            if (!(formKey.currentState?.validate() ?? false)) return;
            supplier.saveOffer(
              product: product,
              price: double.parse(priceController.text),
              stock: int.parse(stockController.text),
              description: descriptionController.text,
              minimumOrder: int.parse(minimumOrderController.text),
              preparationDays: int.parse(preparationController.text),
              existing: existing,
            );
            Get.back<void>();
            Get.snackbar('app_name'.tr, 'offer_saved'.tr);
          },
        ),
      ],
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'required_field'.tr : null;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SearchProductTile extends StatelessWidget {
  const _SearchProductTile({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: SizedBox(
          width: 52,
          child: AppAssetImage(product.imageAsset, bytes: product.imageBytes),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('${product.manufacturer} · ${product.reference}'),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
