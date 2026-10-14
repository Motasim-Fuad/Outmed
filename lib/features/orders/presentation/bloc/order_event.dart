import 'package:equatable/equatable.dart';
import 'package:outmed/features/cart/presentation/bloc/cart_state.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class OrderStarted extends OrderEvent {
  const OrderStarted();
}

class OrderPlaceRequested extends OrderEvent {
  const OrderPlaceRequested(this.cart);

  final CartState cart;

  @override
  List<Object?> get props => [cart.revision];
}

class OrderBuyAgainRequested extends OrderEvent {
  const OrderBuyAgainRequested(this.order);

  final OrderModel order;

  @override
  List<Object?> get props => [order.id];
}

class OrderStatusAdvanced extends OrderEvent {
  const OrderStatusAdvanced(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
