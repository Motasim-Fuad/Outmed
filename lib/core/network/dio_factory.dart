import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/network/auth_interceptor.dart';
import 'package:outmed/core/network/retry_interceptor.dart';
import 'package:outmed/core/storage/token_store.dart';

class DioFactory {
  static Dio create({
    required TokenStore tokens,
    required void Function() onRefreshFailed,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEnv.apiBaseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
        headers: const {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(
      AuthInterceptor(tokens: tokens, onRefreshFailed: onRefreshFailed),
    );
    dio.interceptors.add(RetryInterceptor(dio));
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          logPrint: (object) => AppLogger.log('Dio: $object'),
        ),
      );
    }
    return dio;
  }
}
