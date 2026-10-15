import 'package:equatable/equatable.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartItemAdded extends CartEvent {
  const CartItemAdded({
    required this.product,
    required this.offer,
    this.quantity = 1,
  });

  final ProductModel product;
  final SupplierOfferModel offer;
  final int quantity;

  @override
  List<Object?> get props => [product.id, offer.id, quantity];
}

class CartQuantityChanged extends CartEvent {
  const CartQuantityChanged(this.offerId, this.delta);

  final String offerId;
  final int delta;

  @override
  List<Object?> get props => [offerId, delta];
}

class CartCleared extends CartEvent {
  const CartCleared();
}

class CartSyncRequested extends CartEvent {
  const CartSyncRequested();
}
