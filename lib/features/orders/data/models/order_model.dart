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
    this.productId = '',
    this.offerId = '',
  });

  final String id;
  final String buyerName;
  final String supplierName;
  final String productName;
  final int quantity;
  final double total;
  final DateTime createdAt;
  final OrderStatus status;
  final String productId;
  final String offerId;

  OrderModel copyWith({OrderStatus? status}) => OrderModel(
    id: id,
    buyerName: buyerName,
    supplierName: supplierName,
    productName: productName,
    quantity: quantity,
    total: total,
    createdAt: createdAt,
    status: status ?? this.status,
    productId: productId,
    offerId: offerId,
  );
}
