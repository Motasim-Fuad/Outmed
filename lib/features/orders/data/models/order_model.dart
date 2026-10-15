import 'package:outmed/core/network/api_json.dart';

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
    this.number = '',
    this.cancelled = false,
  });

  final String id;
  final String number;
  final String buyerName;
  final String supplierName;
  final String productName;
  final int quantity;
  final double total;
  final DateTime createdAt;
  final OrderStatus status;
  final String productId;
  final String offerId;
  final bool cancelled;

  String get displayId => number.isEmpty ? id : number;

  static OrderModel? tryParse(Map<String, Object?> json) {
    final id = ApiJson.text(json, const ['id', 'order_id', 'orderNumber']);
    if (id == null) return null;
    final items = _items(json);
    final first = items.isEmpty ? null : items.first;
    final product = first == null ? null : ApiJson.asMap(first['product']);
    final createdRaw = ApiJson.text(json, const ['created_at', 'createdAt']);
    final rawStatus = ApiJson.text(json, const ['status'])?.toUpperCase();
    final itemQuantity = items.fold<int>(
      0,
      (sum, item) => sum + (ApiJson.integer(item, const ['quantity']) ?? 0),
    );
    return OrderModel(
      id: id,
      number: ApiJson.text(json, const ['orderNumber', 'number']) ?? '',
      buyerName:
          ApiJson.text(json, const ['buyer_name', 'buyerName']) ??
          _nestedName(json['buyer']) ??
          '',
      supplierName:
          ApiJson.text(json, const ['supplier_name', 'supplierName']) ??
          _nestedName(json['supplier']) ??
          (first == null ? null : _nestedName(first['supplier'])) ??
          '',
      productName:
          ApiJson.text(json, const ['product_name', 'productName']) ??
          (first == null
              ? null
              : ApiJson.text(first, const ['productName', 'name'])) ??
          (product == null ? null : ApiJson.text(product, const ['name'])) ??
          id,
      quantity: itemQuantity > 0
          ? itemQuantity
          : ApiJson.integer(json, const ['quantity']) ?? 1,
      total:
          ApiJson.number(json, const [
            'totalAmount',
            'grandTotal',
            'total',
            'amount',
          ]) ??
          0,
      createdAt: DateTime.tryParse(createdRaw ?? '') ?? DateTime.now(),
      status: _status(rawStatus),
      productId:
          ApiJson.text(json, const ['product_id', 'productId']) ??
          (first == null ? null : ApiJson.text(first, const ['productId'])) ??
          (product == null ? null : ApiJson.text(product, const ['id'])) ??
          '',
      offerId: ApiJson.text(json, const ['offer_id', 'offerId']) ?? '',
      cancelled: rawStatus == 'CANCELLED' || rawStatus == 'REFUNDED',
    );
  }

  static List<Map<String, Object?>> _items(Map<String, Object?> json) {
    final raw = json['items'] ?? json['orderItems'];
    if (raw is! List) return const [];
    return raw.map(ApiJson.asMap).whereType<Map<String, Object?>>().toList();
  }

  static String? _nestedName(Object? value) {
    final map = ApiJson.asMap(value);
    if (map == null) return null;
    final profile =
        ApiJson.asMap(map['buyerProfile']) ??
        ApiJson.asMap(map['supplierProfile']);
    return ApiJson.text(map, const [
          'organizationName',
          'companyName',
          'fullName',
          'name',
        ]) ??
        (profile == null
            ? null
            : ApiJson.text(profile, const ['organizationName', 'companyName']));
  }

  Map<String, Object?> toApi() => {
    'buyer_name': buyerName,
    'supplier_name': supplierName,
    'product_name': productName,
    'quantity': quantity,
    'total': total,
    'status': _statusName(status),
    'product_id': productId,
    'offer_id': offerId,
  };

  static OrderStatus _status(String? raw) {
    switch (raw) {
      case 'ACCEPTED':
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'PROCESSING':
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'READY_FOR_PICKUP':
        return OrderStatus.readyForPickup;
      case 'SHIPPED':
      case 'IN_TRANSIT':
        return OrderStatus.inTransit;
      case 'DELIVERED':
        return OrderStatus.delivered;
      default:
        return OrderStatus.pending;
    }
  }

  static String statusWireName(OrderStatus status) => _statusName(status);

  static OrderStatus nextRemoteStatus(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => OrderStatus.confirmed,
      OrderStatus.confirmed => OrderStatus.preparing,
      OrderStatus.preparing ||
      OrderStatus.readyForPickup => OrderStatus.inTransit,
      OrderStatus.inTransit || OrderStatus.delivered => OrderStatus.delivered,
    };
  }

  static String _statusName(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => 'PENDING',
      OrderStatus.confirmed => 'ACCEPTED',
      OrderStatus.preparing || OrderStatus.readyForPickup => 'PROCESSING',
      OrderStatus.inTransit => 'SHIPPED',
      OrderStatus.delivered => 'DELIVERED',
    };
  }

  OrderModel copyWith({OrderStatus? status, bool? cancelled}) => OrderModel(
    id: id,
    number: number,
    buyerName: buyerName,
    supplierName: supplierName,
    productName: productName,
    quantity: quantity,
    total: total,
    createdAt: createdAt,
    status: status ?? this.status,
    productId: productId,
    offerId: offerId,
    cancelled: cancelled ?? this.cancelled,
  );
}
