import 'package:dio/dio.dart';
import 'package:outmed/core/l10n/app_locale.dart';
import 'package:outmed/core/network/api_response.dart';

abstract final class ApiError {
  static String message(Object error) {
    if (error is StateError) return error.message;
    if (error is! DioException) return AppLocale.translate('unexpected_error');
    if (error.response == null) {
      return AppLocale.translate('server_unreachable');
    }
    return ApiResponse.detailMessage(
      error.response?.data,
      AppLocale.translate('request_failed'),
    );
  }
}
