import 'package:equatable/equatable.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';

class OrderState extends Equatable {
  const OrderState({
    this.orders = const [],
    this.status = LoadStatus.initial,
    this.errorMessage = '',
    this.placedOrder,
    this.revision = 0,
  });

  final List<OrderModel> orders;
  final LoadStatus status;
  final String errorMessage;
  final OrderModel? placedOrder;
  final int revision;

  OrderState copyWith({
    List<OrderModel>? orders,
    LoadStatus? status,
    String? errorMessage,
    OrderModel? placedOrder,
    bool clearPlaced = false,
    int? revision,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      placedOrder: clearPlaced ? null : placedOrder ?? this.placedOrder,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [revision, status, errorMessage, placedOrder?.id];
}
