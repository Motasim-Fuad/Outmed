class ApiResponse<T> {
  const ApiResponse({
    required this.isSuccess,
    required this.statusCode,
    this.message = '',
    this.data,
    this.error,
  });

  final bool isSuccess;
  final int statusCode;
  final String message;
  final T? data;
  final Object? error;

  bool get isUnauthorized => statusCode == 401;
  bool get isServerError => statusCode >= 500;
  bool get isNetworkError => statusCode == 0;

  static String detailMessage(Object? body, String fallback) {
    if (body is Map && body['detail'] != null) {
      final detail = body['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] is String) {
          return first['msg'] as String;
        }
        return first.toString();
      }
      return detail.toString();
    }
    if (body is Map && body['message'] is String) {
      return body['message'] as String;
    }
    return fallback;
  }
}
