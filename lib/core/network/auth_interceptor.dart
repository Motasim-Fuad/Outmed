import 'package:dio/dio.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_json.dart';
import 'package:outmed/core/storage/token_store.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokens, required this.onRefreshFailed});

  final TokenStore tokens;
  final void Function() onRefreshFailed;
  Future<void>? _refreshing;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokens.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;
    if (status != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }
    try {
      _refreshing ??= _refresh().whenComplete(() => _refreshing = null);
      await _refreshing;
      final request = err.requestOptions;
      request.extra['retried'] = true;
      request.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      final response = await Dio(
        BaseOptions(baseUrl: AppEnv.apiBaseUrl),
      ).fetch<dynamic>(request);
      handler.resolve(response);
    } on Object catch (error) {
      AppLogger.log('AuthInterceptor: refresh failed $error');
      tokens.clear();
      onRefreshFailed();
      handler.next(err);
    }
  }

  Future<void> _refresh() async {
    final refresh = tokens.refreshToken;
    if (refresh == null || refresh.isEmpty) {
      throw Exception('missing refresh token');
    }
    final dio = Dio(BaseOptions(baseUrl: AppEnv.apiBaseUrl));
    final response = await dio.post<dynamic>(
      ApiEndpoints.refresh,
      data: {'refreshToken': refresh},
    );
    final access = ApiJson.accessToken(response.data);
    if (access == null) {
      throw Exception('invalid refresh payload');
    }
    await tokens.save(
      access: access,
      refresh: ApiJson.refreshToken(response.data) ?? refresh,
    );
  }
}
