import 'package:flutter_test/flutter_test.dart';
import 'package:outmed/core/config/localization/ar_sa.dart';
import 'package:outmed/core/config/localization/en_us.dart';

void main() {
  test('English and Arabic localization keys stay in sync', () {
    expect(arSa.keys.toSet(), enUs.keys.toSet());
    expect(arSa.values.every((value) => value.trim().isNotEmpty), isTrue);
  });
}
