import 'package:outmed/features/catalog/data/models/product_model.dart';

class DuplicateProductException implements Exception {
  const DuplicateProductException();
}

abstract interface class CatalogRepository {
  List<ProductModel> getProducts();
  List<SupplierOfferModel> getOffers();
  ProductModel? findProduct(String productId);
  List<ProductModel> searchProducts(String query);
  bool productExists({required String name, required String reference});
  ProductModel createMasterProduct(ProductModel product);
  SupplierOfferModel saveOffer(SupplierOfferModel offer);
  bool deleteOffer(String id);
  List<SupplierOfferModel> ownOffers(String supplierName);
  void replaceOwn(List<ProductModel> products, List<SupplierOfferModel> offers);
  void replaceProductId(String oldId, ProductModel product);
  Future<void> refreshRemote();
}
