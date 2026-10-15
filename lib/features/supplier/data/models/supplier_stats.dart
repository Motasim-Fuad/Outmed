import 'package:equatable/equatable.dart';
import 'package:outmed/core/network/api_json.dart';

class SupplierStats extends Equatable {
  const SupplierStats({
    this.totalOrders,
    this.pendingOrders,
    this.revenue,
    this.todayRevenue,
    this.todayOrders,
  });

  factory SupplierStats.parse(Object? body) {
    final json = ApiJson.asMap(ApiJson.unwrap(body)) ?? const {};
    final byStatus =
        ApiJson.asMap(json['byStatus']) ??
        ApiJson.asMap(json['statusCounts']) ??
        const {};
    return SupplierStats(
      totalOrders: ApiJson.integer(json, const [
        'totalOrders',
        'ordersCount',
        'total',
      ]),
      pendingOrders:
          ApiJson.integer(json, const ['pendingOrders', 'pending']) ??
          ApiJson.integer(byStatus, const ['PENDING']),
      revenue: ApiJson.number(json, const [
        'totalRevenue',
        'revenue',
        'totalSales',
      ]),
      todayRevenue: ApiJson.number(json, const [
        'todayRevenue',
        'todaysRevenue',
        'revenueToday',
      ]),
      todayOrders: ApiJson.integer(json, const [
        'todayOrders',
        'todaysOrders',
        'ordersToday',
      ]),
    );
  }

  final int? totalOrders;
  final int? pendingOrders;
  final double? revenue;
  final double? todayRevenue;
  final int? todayOrders;

  bool get isEmpty =>
      totalOrders == null &&
      pendingOrders == null &&
      revenue == null &&
      todayRevenue == null;

  @override
  List<Object?> get props => [
    totalOrders,
    pendingOrders,
    revenue,
    todayRevenue,
    todayOrders,
  ];
}
