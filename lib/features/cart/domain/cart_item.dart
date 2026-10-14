import 'package:outmed/features/catalog/data/models/product_model.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.offer,
    required this.quantity,
  });

  final ProductModel product;
  final SupplierOfferModel offer;
  final int quantity;

  CartItem copyWith({int? quantity}) => CartItem(
    product: product,
    offer: offer,
    quantity: quantity ?? this.quantity,
  );

  double get total => offer.price * quantity;
}
