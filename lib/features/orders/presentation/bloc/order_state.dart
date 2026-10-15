import 'package:equatable/equatable.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';

class OrderState extends Equatable {
  const OrderState({
    this.orders = const [],
    this.status = LoadStatus.initial,
    this.errorMessage = '',
    this.placedOrder,
    this.placing = false,
    this.updatingId = '',
    this.revision = 0,
  });

  final List<OrderModel> orders;
  final LoadStatus status;
  final String errorMessage;
  final OrderModel? placedOrder;
  final bool placing;
  final String updatingId;
  final int revision;

  bool get loading => status == LoadStatus.loading && orders.isEmpty;

  OrderModel? byId(String id) {
    for (final order in orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  OrderState copyWith({
    List<OrderModel>? orders,
    LoadStatus? status,
    String? errorMessage,
    OrderModel? placedOrder,
    bool clearPlaced = false,
    bool? placing,
    String? updatingId,
    int? revision,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      placedOrder: clearPlaced ? null : placedOrder ?? this.placedOrder,
      placing: placing ?? this.placing,
      updatingId: updatingId ?? this.updatingId,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [
    revision,
    status,
    errorMessage,
    placedOrder?.id,
    placing,
    updatingId,
  ];
}
