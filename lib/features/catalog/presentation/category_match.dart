import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/supplier/data/models/category_option.dart';

extension CategoryMatch on CategoryOption {
  bool contains(ProductModel product) {
    if (product.categoryId.isNotEmpty && product.categoryId == id) return true;
    return product.category.toLowerCase() == name.toLowerCase();
  }
}
