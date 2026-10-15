import 'package:flutter_test/flutter_test.dart';
import 'package:outmed/features/supplier/data/models/category_option.dart';

void main() {
  test('flattens category tree from the API envelope', () {
    final categories = CategoryOption.parseList({
      'success': true,
      'statusCode': 200,
      'data': [
        {
          'id': 'root',
          'name': 'Surgical',
          'slug': 'surgical',
          '_count': {'products': 3},
          'children': [
            {'id': 'child', 'name': 'Scalpels', 'parentId': 'root'},
          ],
        },
      ],
    });

    expect(categories.map((item) => item.id), ['root', 'child']);
    expect(categories.first.productCount, 3);
    expect(categories.last.isRoot, isFalse);
  });
}
