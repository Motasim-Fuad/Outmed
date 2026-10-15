import 'package:flutter_test/flutter_test.dart';
import 'package:outmed/core/validation/validators.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';
import 'package:outmed/features/profile/data/models/login_activity.dart';
import 'package:outmed/features/supplier/data/models/stock_log.dart';

void main() {
  test('product row keeps discount, list price, unit cost and SFDA code', () {
    final row = <String, Object?>{
      'id': 'p1',
      'name': 'Gloves',
      'slug': 'gloves',
      'sellingPrice': '100',
      'discountPrice': '80',
      'unitCostPrice': '50',
      'sfdaCode': 'SFDA-1',
      'stockQuantity': 5,
    };
    final product = ProductModel.tryParse(row)!;
    final offer = SupplierOfferModel.fromProductRow(row, product)!;

    expect(product.sfdaCode, 'SFDA-1');
    expect(product.slug, 'gloves');
    expect(offer.price, 80);
    expect(offer.discounted, isTrue);
    expect(offer.sellingPrice, 100);
    expect(offer.unitCost, 50);
  });

  test('discount equal to price is ignored', () {
    final row = <String, Object?>{
      'id': 'p2',
      'name': 'Mask',
      'sellingPrice': 10,
      'discountPrice': 10,
    };
    final offer = SupplierOfferModel.fromProductRow(
      row,
      ProductModel.tryParse(row)!,
    )!;

    expect(offer.discounted, isFalse);
    expect(offer.price, 10);
  });

  test('order keeps tracking number and courier', () {
    final order = OrderModel.tryParse({
      'id': 'o1',
      'status': 'SHIPPED',
      'trackingNumber': 'TRK-9',
      'courierName': 'Aramex',
    })!;

    expect(order.status, OrderStatus.inTransit);
    expect(order.trackingNumber, 'TRK-9');
    expect(order.courierName, 'Aramex');
  });

  test('stock log derives adjustment from quantities', () {
    final log = StockLog.tryParse({
      'id': 's1',
      'reason': 'RESTOCK',
      'previousQuantity': 10,
      'newQuantity': 25,
      'createdAt': '2026-10-15T04:30:05.260Z',
    })!;

    expect(log.adjustment, 15);
    expect(log.createdAt, isNotNull);
  });

  test('login activity detects device', () {
    final activity = LoginActivity.tryParse({
      'id': 'a1',
      'ipAddress': '1.2.3.4',
      'userAgent': 'Dart/3.9 (dart:io)',
      'deviceType': 'Mobile',
    })!;

    expect(activity.mobile, isTrue);
    expect(activity.deviceLabel, 'Mobile');
  });

  test('discount validator requires a lower value', () {
    final validate = Validators.discountBelow(() => '100');

    expect(validate(''), isNull);
    expect(validate('80'), isNull);
    expect(validate('100'), isNotNull);
    expect(validate('abc'), isNotNull);
  });
}
