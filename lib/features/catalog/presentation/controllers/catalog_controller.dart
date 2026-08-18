import 'package:get/get.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogController extends GetxController {
  CatalogController(this._repository);

  final CatalogRepository _repository;

  final products = <ProductModel>[].obs;
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    products.assignAll(_repository.getProducts());
    super.onInit();
  }

  List<ProductModel> get visibleProducts {
    final query = searchQuery.value.trim().toLowerCase();
    return products
        .where((product) {
          final matchesSearch =
              query.isEmpty || product.searchableText.contains(query);
          final matchesCategory =
              selectedCategory.value == 'All' ||
              product.category == selectedCategory.value;
          return matchesSearch && matchesCategory;
        })
        .toList(growable: false);
  }

  List<SupplierOfferModel> offersFor(String productId) {
    return _repository
        .getOffers()
        .where((offer) => offer.productId == productId)
        .toList(growable: false)
      ..sort((a, b) => a.price.compareTo(b.price));
  }

  SupplierOfferModel? bestOfferFor(String productId) {
    final offers = offersFor(productId);
    return offers.isEmpty ? null : offers.first;
  }

  ProductModel? productById(String id) => _repository.findProduct(id);

  List<ProductModel> searchMasterCatalog(String query) {
    return _repository.searchProducts(query);
  }

  void refreshCatalog() => products.assignAll(_repository.getProducts());
}
