import 'package:flutter_test/flutter_test.dart';
import 'package:outmed/core/validation/validators.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';

void main() {
  test('parses nested API order with items and status', () {
    final order = OrderModel.tryParse({
      'id': 'f2c1',
      'orderNumber': 'OM-1001',
      'status': 'SHIPPED',
      'totalAmount': '320.50',
      'createdAt': '2026-10-10T08:00:00.000Z',
      'buyer': {'organizationName': 'Riyadh Clinic'},
      'items': [
        {
          'quantity': 2,
          'productName': 'Syringe 5ml',
          'product': {'id': 'p1', 'name': 'Syringe 5ml'},
          'supplier': {'companyName': 'Marsh Medical'},
        },
        {'quantity': 3, 'productId': 'p2'},
      ],
    });
    expect(order, isNotNull);
    expect(order!.displayId, 'OM-1001');
    expect(order.status, OrderStatus.inTransit);
    expect(order.total, 320.5);
    expect(order.quantity, 5);
    expect(order.buyerName, 'Riyadh Clinic');
    expect(order.supplierName, 'Marsh Medical');
    expect(order.productId, 'p1');
  });

  test('cancelled orders are flagged', () {
    final order = OrderModel.tryParse({'id': 'x', 'status': 'CANCELLED'});
    expect(order!.cancelled, isTrue);
  });

  test('remote status flow skips ready for pickup', () {
    expect(
      OrderModel.nextRemoteStatus(OrderStatus.preparing),
      OrderStatus.inTransit,
    );
    expect(OrderModel.statusWireName(OrderStatus.confirmed), 'ACCEPTED');
  });

  test('number validators reject invalid input', () {
    expect(Validators.price('0'), isNotNull);
    expect(Validators.price('12.5'), isNull);
    expect(Validators.wholeNumber(min: 1)('0'), isNotNull);
    expect(Validators.wholeNumber()('4'), isNull);
  });
}
