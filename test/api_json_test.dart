import 'package:flutter_test/flutter_test.dart';
import 'package:outmed/core/network/api_json.dart';
import 'package:outmed/features/catalog/data/models/product_model.dart';
import 'package:outmed/features/orders/data/models/order_model.dart';

void main() {
  test('unwraps a FastAPI list and snake_case product', () {
    final rows = ApiJson.maps({
      'data': [
        {
          'id': 'glove-1',
          'name': 'Nitrile Gloves',
          'category': 'PPE',
          'pack_size': '100',
          'image_url': 'https://cdn.example/glove.png',
        },
      ],
    });

    final product = ProductModel.tryParse(rows.single);

    expect(product?.id, 'glove-1');
    expect(product?.packSize, '100');
    expect(product?.imageAsset, 'https://cdn.example/glove.png');
    expect(product?.toApi()['pack_size'], '100');

    final nested = ApiJson.maps({
      'success': true,
      'data': {
        'data': [
          {
            'id': 'p2',
            'name': 'Syringe',
            'brandName': 'OutMed',
            'sellingPrice': 12,
          },
        ],
      },
    });
    expect(ProductModel.tryParse(nested.single)?.brand, 'OutMed');
  });

  test('reads nested access token and order status', () {
    expect(
      ApiJson.accessToken({
        'data': {'accessToken': 'abc', 'refreshToken': 'def'},
      }),
      'abc',
    );
    expect(
      ApiJson.refreshToken({
        'data': {'refreshToken': 'def'},
      }),
      'def',
    );

    final order = OrderModel.tryParse({
      'id': 'OM-1',
      'product_name': 'Syringe',
      'status': 'ready_for_pickup',
      'quantity': '4',
      'total': '12.5',
    });

    expect(order?.status, OrderStatus.readyForPickup);
    expect(order?.quantity, 4);
    expect(order?.toApi()['status'], 'PROCESSING');
    expect(OrderModel.statusWireName(OrderStatus.readyForPickup), 'PROCESSING');
  });
}
