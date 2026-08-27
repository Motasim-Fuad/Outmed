import 'package:outmed/features/catalog/data/models/product_model.dart';

abstract interface class CatalogRepository {
  List<ProductModel> getProducts();
  List<SupplierOfferModel> getOffers();
  ProductModel? findProduct(String productId);
  List<ProductModel> searchProducts(String query);
  bool productExists({required String name, required String reference});
  ProductModel createMasterProduct(ProductModel product);
  SupplierOfferModel saveOffer(SupplierOfferModel offer);
  bool deleteOffer(String id);
}
