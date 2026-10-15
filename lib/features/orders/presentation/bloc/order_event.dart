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

class OrderDetailRequested extends OrderEvent {
  const OrderDetailRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class OrderPlaceRequested extends OrderEvent {
  const OrderPlaceRequested(this.cart, {this.phone = '', this.notes = ''});

  final CartState cart;
  final String phone;
  final String notes;

  @override
  List<Object?> get props => [cart.revision, phone, notes];
}

class OrderBuyAgainRequested extends OrderEvent {
  const OrderBuyAgainRequested(this.order);

  final OrderModel order;

  @override
  List<Object?> get props => [order.id];
}

class OrderStatusAdvanced extends OrderEvent {
  const OrderStatusAdvanced(
    this.id, {
    this.trackingNumber = '',
    this.courierName = '',
  });

  final String id;
  final String trackingNumber;
  final String courierName;

  @override
  List<Object?> get props => [id, trackingNumber, courierName];
}

class OrderCancelRequested extends OrderEvent {
  const OrderCancelRequested(this.id, {this.reason = ''});

  final String id;
  final String reason;

  @override
  List<Object?> get props => [id, reason];
}

class OrderFeedbackCleared extends OrderEvent {
  const OrderFeedbackCleared();
}

class OrderReset extends OrderEvent {
  const OrderReset();
}
