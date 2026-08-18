import 'package:get/get.dart';
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

class CartController extends GetxController {
  final items = <CartItem>[].obs;

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.offer.price * item.quantity);
  double get vat => subtotal * .15;
  double get deliveryFee => items.isEmpty ? 0 : 25;
  double get total => subtotal + vat + deliveryFee;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  void add({
    required ProductModel product,
    required SupplierOfferModel offer,
    int quantity = 1,
  }) {
    final index = items.indexWhere((item) => item.offer.id == offer.id);
    if (index >= 0) {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + quantity,
      );
      items.refresh();
      return;
    }
    items.add(CartItem(product: product, offer: offer, quantity: quantity));
  }

  void changeQuantity(String offerId, int delta) {
    final index = items.indexWhere((item) => item.offer.id == offerId);
    if (index < 0) return;
    final next = items[index].quantity + delta;
    if (next <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: next);
      items.refresh();
    }
  }

  void clear() => items.clear();
}
