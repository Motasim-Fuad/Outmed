enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForPickup,
  inTransit,
  delivered,
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.buyerName,
    required this.supplierName,
    required this.productName,
    required this.quantity,
    required this.total,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String buyerName;
  final String supplierName;
  final String productName;
  final int quantity;
  final double total;
  final DateTime createdAt;
  final OrderStatus status;

  OrderModel copyWith({OrderStatus? status}) => OrderModel(
    id: id,
    buyerName: buyerName,
    supplierName: supplierName,
    productName: productName,
    quantity: quantity,
    total: total,
    createdAt: createdAt,
    status: status ?? this.status,
  );
}
