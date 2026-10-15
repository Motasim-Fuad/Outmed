class ApiJson {
  static Map<String, Object?>? asMap(Object? value) {
    if (value is! Map) return null;
    return value.map((key, item) => MapEntry(key.toString(), item as Object?));
  }

  static List<Map<String, Object?>> maps(Object? body) {
    final result = <Map<String, Object?>>[];
    for (final item in _list(unwrap(body))) {
      final map = asMap(item);
      if (map != null) result.add(map);
    }
    return result;
  }

  static Object? unwrap(Object? body) {
    final map = asMap(body);
    if (map == null || map['success'] != true || !map.containsKey('data')) {
      return body;
    }
    return unwrap(map['data']);
  }

  static String? text(Map<String, Object?> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is num) return value.toString();
    }
    return null;
  }

  static double? number(Map<String, Object?> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
    }
    return null;
  }

  static int? integer(Map<String, Object?> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.round();
      if (value is String) return int.tryParse(value);
    }
    return null;
  }

  static String? accessToken(Object? body) {
    return _token(body, const ['access_token', 'accessToken', 'token']);
  }

  static String? refreshToken(Object? body) {
    return _token(body, const ['refresh_token', 'refreshToken']);
  }

  static String? resetToken(Object? body) {
    return _token(body, const ['resetToken', 'reset_token']);
  }

  static String? _token(Object? body, List<String> keys) {
    final map = asMap(body);
    if (map == null) return null;
    final direct = text(map, keys);
    if (direct != null) return direct;
    final nested = asMap(map['data']);
    if (nested == null) return null;
    return text(nested, keys);
  }

  static List<Object?> _list(Object? body) {
    if (body is List) return body;
    final map = asMap(body);
    if (map == null) return const [];
    for (final key in const [
      'data',
      'items',
      'results',
      'products',
      'offers',
      'orders',
    ]) {
      final value = map[key];
      if (value is List) return value;
    }
    if (map.containsKey('id') || map.containsKey('name')) return [map];
    return const [];
  }
}
