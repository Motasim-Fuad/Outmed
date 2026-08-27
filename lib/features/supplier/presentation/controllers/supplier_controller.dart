import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:outmed/core/constants/app_assets.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:outmed/features/catalog/presentation/controllers/catalog_controller.dart';

class SupplierController extends GetxController {
  SupplierController(this._repository);

  final CatalogRepository _repository;
  final searchQuery = ''.obs;
  final selectedProduct = Rxn<ProductModel>();
  final ownOffers = <SupplierOfferModel>[].obs;
  final shellIndex = 0.obs;

  static const supplierName = 'HealthCare Supplies';

  @override
  void onInit() {
    refreshOffers();
    super.onInit();
  }

  List<ProductModel> get searchResults =>
      _repository.searchProducts(searchQuery.value);

  void selectProduct(ProductModel product) {
    selectedProduct.value = product;
  }

  void clearSelection() {
    selectedProduct.value = null;
    searchQuery.value = '';
  }

  ProductModel createMasterProduct({
    required String name,
    required String category,
    required String manufacturer,
    required String reference,
    required String packSize,
    required String brand,
    required String specifications,
    required String barcode,
    required String countryOfOrigin,
    required String storageRequirements,
    required String documentName,
    required Uint8List imageBytes,
  }) {
    final product = ProductModel(
      id: 'product-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      category: category.trim(),
      manufacturer: manufacturer.trim(),
      reference: reference.trim(),
      packSize: packSize.trim(),
      imageAsset: AppAssets.diagnosticKit,
      imageBytes: imageBytes,
      brand: brand.trim(),
      specifications: specifications.trim(),
      barcode: barcode.trim(),
      countryOfOrigin: countryOfOrigin.trim(),
      storageRequirements: storageRequirements.trim(),
      documentName: documentName.trim(),
    );
    final created = _repository.createMasterProduct(product);
    selectedProduct.value = created;
    Get.find<CatalogController>().refreshCatalog();
    return created;
  }

  SupplierOfferModel saveOffer({
    required ProductModel product,
    required double price,
    required int stock,
    required String description,
    required int minimumOrder,
    required int preparationDays,
    SupplierOfferModel? existing,
  }) {
    final offer = SupplierOfferModel(
      id: existing?.id ?? 'offer-${DateTime.now().microsecondsSinceEpoch}',
      productId: product.id,
      supplierName: supplierName,
      price: price,
      stock: stock,
      description: description.trim(),
      minimumOrder: minimumOrder,
      preparationDays: preparationDays,
    );
    final saved = _repository.saveOffer(offer);
    refreshOffers();
    Get.find<CatalogController>().refreshCatalog();
    return saved;
  }

  bool deleteOffer(String id) {
    final removed = _repository.deleteOffer(id);
    if (removed) {
      refreshOffers();
      Get.find<CatalogController>().refreshCatalog();
    }
    return removed;
  }

  void refreshOffers() {
    ownOffers.assignAll(
      _repository.getOffers().where(
        (offer) => offer.supplierName == supplierName,
      ),
    );
  }

  ProductModel? productForOffer(SupplierOfferModel offer) {
    return _repository.findProduct(offer.productId);
  }
}
