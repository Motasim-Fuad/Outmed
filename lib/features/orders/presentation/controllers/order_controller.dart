import 'package:get/get.dart';
import 'package:outmed/features/cart/presentation/controllers/cart_controller.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';

class OrderController extends GetxController {
  final orders = <OrderModel>[
    OrderModel(
      id: 'ORD-2024-1058',
      buyerName: 'King Fahad Hospital',
      supplierName: 'HealthCare Supplies',
      productName: 'Nitrile Examination Gloves (M)',
      quantity: 12,
      total: 540,
      createdAt: DateTime(2026, 8, 18, 9, 32),
      status: OrderStatus.pending,
    ),
    OrderModel(
      id: 'ORD-2024-1059',
      buyerName: 'Riyadh Medical Center',
      supplierName: 'HealthCare Supplies',
      productName: 'Disposable Syringe 5ml',
      quantity: 8,
      total: 256,
      createdAt: DateTime(2026, 8, 17, 14, 10),
      status: OrderStatus.confirmed,
    ),
    OrderModel(
      id: 'ORD-2024-1060',
      buyerName: 'Al Salma Hospital',
      supplierName: 'HealthCare Supplies',
      productName: 'Clinical Diagnostic Kit',
      quantity: 3,
      total: 435,
      createdAt: DateTime(2026, 8, 16, 11, 45),
      status: OrderStatus.inTransit,
    ),
  ].obs;

  OrderModel placeOrder(CartController cart) {
    final first = cart.items.first;
    final order = OrderModel(
      id: 'OM-${24020 + orders.length}',
      buyerName: 'Al Noor Medical Center',
      supplierName: first.offer.supplierName,
      productName: first.product.name,
      quantity: cart.itemCount,
      total: cart.total,
      createdAt: DateTime.now(),
      status: OrderStatus.pending,
    );
    orders.insert(0, order);
    cart.clear();
    return order;
  }

  void advanceStatus(String id) {
    final index = orders.indexWhere((order) => order.id == id);
    if (index < 0) return;
    final current = orders[index].status.index;
    if (current >= OrderStatus.values.length - 1) return;
    orders[index] = orders[index].copyWith(
      status: OrderStatus.values[current + 1],
    );
    orders.refresh();
  }
}
