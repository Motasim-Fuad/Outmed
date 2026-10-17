import 'dart:async';

import 'package:dio/dio.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/storage/app_database.dart';

class RemoteCache {
  RemoteCache(this._dio);

  static const _bucket = 'http';

  final Dio _dio;
  final Map<String, Object?> _memory = {};
  AppDatabase? _database;

  Future<void> bind(AppDatabase database) async {
    _database = database;
    final entries = await database.readEntries(_bucket);
    for (final entry in entries.entries) {
      _memory.putIfAbsent(entry.key, () => entry.value['body']);
    }
  }

  Object? peek(String path, {Map<String, Object?>? query}) =>
      _memory[_key(path, query)];

  Future<Object?> get(String path, {Map<String, Object?>? query}) async {
    final key = _key(path, query);
    if (!AppEnv.useRemote) return _memory[key];
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: query);
      final body = response.data;
      _memory[key] = body;
      final database = _database;
      if (database != null) {
        unawaited(database.writeEntry(_bucket, key, {'body': body}));
      }
      return body;
    } on DioException catch (error) {
      final code = error.response?.statusCode ?? 0;
      if (_memory.containsKey(key) && (error.response == null || code >= 500)) {
        AppLogger.log('RemoteCache: stale hit $key');
        return _memory[key];
      }
      rethrow;
    }
  }

  Future<void> clear() async {
    _memory.clear();
    await _database?.clearBucket(_bucket);
  }

  String _key(String path, Map<String, Object?>? query) {
    if (query == null || query.isEmpty) return path;
    final keys = query.keys.toList()..sort();
    return '$path?${keys.map((key) => '$key=${query[key]}').join('&')}';
  }
}
