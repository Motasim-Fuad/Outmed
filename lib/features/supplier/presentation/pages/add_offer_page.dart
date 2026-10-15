import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/router/route_args.dart';
import 'package:outmed/core/validation/validators.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_event.dart';
import 'package:outmed/features/supplier/presentation/bloc/supplier_state.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/catalog_search_empty.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/category_dropdown.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/form_section_title.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/locked_product_card.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/product_image_picker_box.dart';
import 'package:outmed/features/supplier/presentation/pages/widgets/search_product_tile.dart';
import 'package:outmed/shared/widgets/app_text_field.dart';
import 'package:outmed/shared/widgets/custom_button.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class AddOfferPage extends StatefulWidget {
  const AddOfferPage({super.key});

  @override
  State<AddOfferPage> createState() => _AddOfferPageState();
}

class _AddOfferPageState extends State<AddOfferPage> {
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
  final discountController = TextEditingController();
  final unitCostController = TextEditingController();
  final sfdaController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();
  final minimumOrderController = TextEditingController(text: '1');
  final preparationController = TextEditingController(text: '2');
  SupplierOfferModel? existing;
  bool showCreateForm = false;
  Uint8List? selectedImageBytes;
  String categoryId = '';
  bool _hydrated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;
    _hydrated = true;
    final supplier = context.read<SupplierBloc>()
      ..add(const SupplierFeedbackCleared());
    if (RouteArgs.maybe<Object>(context) case final SupplierOfferModel offer) {
      existing = offer;
      final product = supplier.productForOffer(offer);
      if (product != null) supplier.add(SupplierProductSelected(product));
      priceController.text = offer.sellingPrice.toStringAsFixed(2);
      if (offer.discounted) {
        discountController.text = offer.price.toStringAsFixed(2);
      }
      final cost = offer.unitCost;
      if (cost != null) unitCostController.text = cost.toStringAsFixed(2);
      stockController.text = '${offer.stock}';
      descriptionController.text = offer.description;
      minimumOrderController.text = '${offer.minimumOrder}';
      preparationController.text = '${offer.preparationDays}';
    } else {
      supplier.add(const SupplierSelectionCleared());
    }
  }

  @override
  void dispose() {
    for (final controller in [
      searchController,
      nameController,
      brandController,
      categoryController,
      manufacturerController,
      referenceController,
      specificationsController,
      packSizeController,
      barcodeController,
      countryController,
      storageController,
      documentController,
      priceController,
      discountController,
      unitCostController,
      sfdaController,
      stockController,
      descriptionController,
      minimumOrderController,
      preparationController,
    ]) {
      controller.dispose();
    }
    super.dispose();
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

  void _createProduct() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    context.read<SupplierBloc>().add(
      SupplierProductCreateRequested(
        name: nameController.text,
        brand: brandController.text,
        category: categoryController.text,
        categoryId: categoryId,
        manufacturer: manufacturerController.text,
        reference: referenceController.text,
        specifications: specificationsController.text,
        packSize: packSizeController.text,
        barcode: barcodeController.text,
        countryOfOrigin: countryController.text,
        storageRequirements: storageController.text,
        documentName: documentController.text,
        sfdaCode: sfdaController.text,
        imageBytes: selectedImageBytes,
      ),
    );
  }

  void _saveOffer(ProductModel product) {
    if (!(formKey.currentState?.validate() ?? false)) return;
    context.read<SupplierBloc>().add(
      SupplierOfferSaveRequested(
        product: product,
        price: double.parse(priceController.text.trim()),
        stock: int.parse(stockController.text.trim()),
        description: descriptionController.text,
        minimumOrder: int.parse(minimumOrderController.text.trim()),
        preparationDays: int.parse(preparationController.text.trim()),
        existing: existing,
        discountPrice: double.tryParse(discountController.text.trim()),
        unitCost: double.tryParse(unitCostController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupplierBloc, SupplierState>(
      listenWhen: (previous, current) =>
          !previous.closePage && current.closePage,
      listener: (context, state) => AppNav.pop(),
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          title: Text(
            existing == null ? 'add_product_offer'.tr : 'edit_offer'.tr,
          ),
        ),
        body: Form(
          key: formKey,
          child: BlocSelector<SupplierBloc, SupplierState, ProductModel?>(
            selector: (state) => state.selectedProduct,
            builder: (context, selected) => ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
              children: selected == null
                  ? _searchSection()
                  : [
                      LockedProductCard(
                        product: selected,
                        onChange: existing == null
                            ? () => context.read<SupplierBloc>().add(
                                const SupplierSelectionCleared(),
                              )
                            : null,
                      ),
                      const SizedBox(height: 20),
                      ..._offerForm(selected),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _searchSection() {
    return [
      FormSectionTitle(
        title: 'search_before_create'.tr,
        subtitle: 'select_master_product_hint'.tr,
      ),
      TextField(
        controller: searchController,
        onChanged: (value) {
          context.read<SupplierBloc>().add(SupplierSearchChanged(value));
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
      BlocSelector<SupplierBloc, SupplierState, List<ProductModel>>(
        selector: (state) => state.searchResults,
        builder: (context, results) {
          if (searchController.text.isEmpty) return const SizedBox.shrink();
          if (results.isEmpty) {
            if (showCreateForm) return const SizedBox.shrink();
            return CatalogSearchEmpty(
              onCreate: () {
                nameController.text = searchController.text;
                setState(() => showCreateForm = true);
              },
            );
          }
          return Column(
            children: [
              for (final product in results)
                SearchProductTile(
                  product: product,
                  onTap: () {
                    context.read<SupplierBloc>().add(
                      SupplierProductSelected(product),
                    );
                    setState(() => showCreateForm = false);
                  },
                ),
            ],
          );
        },
      ),
      if (showCreateForm) ..._createForm(),
    ];
  }

  List<Widget> _createForm() {
    return [
      const SizedBox(height: 20),
      FormSectionTitle(
        title: 'create_new_product'.tr,
        subtitle: 'canonical_locked'.tr,
      ),
      ProductImagePickerBox(
        bytes: selectedImageBytes,
        onTap: _pickProductImage,
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: nameController,
        label: 'product_name'.tr,
        validator: Validators.required,
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: brandController,
        label: 'brand'.tr,
        validator: Validators.required,
      ),
      const SizedBox(height: 12),
      CategoryDropdown(
        selectedId: categoryId,
        onChanged: (category) => setState(() {
          categoryId = category.id;
          categoryController.text = category.name;
        }),
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: manufacturerController,
        label: '${'manufacturer'.tr} (${'optional'.tr})',
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: referenceController,
        label: 'model_number'.tr,
        validator: Validators.required,
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: specificationsController,
        label: 'specifications'.tr,
        validator: Validators.required,
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: packSizeController,
        label: 'pack_size'.tr,
        validator: Validators.required,
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: barcodeController,
        label: '${'barcode_udi'.tr} (${'optional'.tr})',
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: countryController,
        label: 'country_of_origin'.tr,
        validator: Validators.required,
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: sfdaController,
        label: '${'sfda_code'.tr} (${'optional'.tr})',
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: storageController,
        label: '${'storage_requirements'.tr} (${'optional'.tr})',
        maxLines: 2,
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: documentController,
        label: '${'product_documents'.tr} (${'optional'.tr})',
        hint: 'upload_product_document'.tr,
      ),
      const SizedBox(height: 16),
      CustomButton(label: 'create_new_product'.tr, onPressed: _createProduct),
      BlocSelector<SupplierBloc, SupplierState, String>(
        selector: (state) => state.errorMessage,
        builder: (context, message) => InlineErrorText(message: message),
      ),
    ];
  }

  List<Widget> _offerForm(ProductModel product) {
    return [
      FormSectionTitle(
        title: 'offer_information'.tr,
        subtitle: 'supplier_editable_fields'.tr,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppTextField(
              controller: priceController,
              label: 'price'.tr,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: Validators.price,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppTextField(
              controller: stockController,
              label: 'stock'.tr,
              keyboardType: TextInputType.number,
              validator: Validators.wholeNumber(),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppTextField(
              controller: discountController,
              label: '${'discount_price'.tr} (${'optional'.tr})',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: Validators.discountBelow(
                () => priceController.text,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppTextField(
              controller: unitCostController,
              label: '${'unit_cost'.tr} (${'optional'.tr})',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: Validators.optionalPrice,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: descriptionController,
        label: '${'description'.tr} (${'optional'.tr})',
        maxLines: 4,
      ),
      const SizedBox(height: 12),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppTextField(
              controller: minimumOrderController,
              label: 'minimum_order'.tr,
              keyboardType: TextInputType.number,
              validator: Validators.wholeNumber(min: 1),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppTextField(
              controller: preparationController,
              label: 'preparation_days'.tr,
              keyboardType: TextInputType.number,
              validator: Validators.wholeNumber(),
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      BlocSelector<SupplierBloc, SupplierState, (bool, String)>(
        selector: (state) => (state.saving, state.errorMessage),
        builder: (context, data) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomButton(
              label: existing == null ? 'save_offer'.tr : 'update_offer'.tr,
              isLoading: data.$1,
              onPressed: () => _saveOffer(product),
            ),
            InlineErrorText(message: data.$2),
          ],
        ),
      ),
    ];
  }
}
