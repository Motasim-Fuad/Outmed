import 'package:flutter_test/flutter_test.dart';
import 'package:outmed/core/network/log_redactor.dart';

void main() {
  test('masks bearer tokens and secret fields', () {
    final output = LogRedactor.redact(
      'Authorization: Bearer eyJhbGciOi.abc-123_x '
      '{"accessToken":"aaa.bbb","password":"Password@123","email":"a@b.com"} '
      '{refreshToken: ccc.ddd, name: Fuad}',
    );

    expect(output, contains('Bearer ***'));
    expect(output, contains('"accessToken":***'));
    expect(output, contains('"password":***'));
    expect(output, contains('refreshToken: ***'));
    expect(output, contains('"email":"a@b.com"'));
    expect(output, contains('name: Fuad'));
    expect(output, isNot(contains('Password@123')));
    expect(output, isNot(contains('eyJhbGciOi')));
  });
}
