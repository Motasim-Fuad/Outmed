import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio);

  final Dio _dio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra['attempt'] as int?) ?? 0;
    final retryable =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.receiveTimeout;
    if (!retryable || attempt >= 2) {
      handler.next(err);
      return;
    }
    await Future<void>.delayed(Duration(milliseconds: 250 * (1 << attempt)));
    final request = err.requestOptions;
    request.extra['attempt'] = attempt + 1;
    try {
      final response = await _dio.fetch<dynamic>(request);
      handler.resolve(response);
    } on DioException catch (error) {
      handler.next(error);
    }
  }
}
