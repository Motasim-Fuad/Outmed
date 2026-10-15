import 'package:equatable/equatable.dart';
import 'package:outmed/features/cart/domain/cart_item.dart';

class CartState extends Equatable {
  const CartState({this.items = const [], this.revision = 0});

  final List<CartItem> items;
  final int revision;

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get vat => subtotal * .15;
  double get deliveryFee => items.isEmpty ? 0 : 25;
  double get total => subtotal + vat + deliveryFee;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  int quantityOf(String offerId) {
    for (final item in items) {
      if (item.offer.id == offerId) return item.quantity;
    }
    return 0;
  }

  CartState copyWith({List<CartItem>? items, int? revision}) {
    return CartState(
      items: items ?? this.items,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [revision];
}
