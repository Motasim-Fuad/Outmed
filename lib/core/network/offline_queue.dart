import 'package:dio/dio.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/storage/app_database.dart';

class OfflineQueue {
  OfflineQueue(this._dio);

  static const _bucket = 'mutation';

  final Dio _dio;
  AppDatabase? _database;
  bool _flushing = false;

  Future<void> bind(AppDatabase database) async => _database = database;

  Future<Object?> send(
    String method,
    String path, {
    Map<String, Object?>? body,
  }) async {
    if (!AppEnv.useRemote) return null;
    try {
      final response = await _dio.request<dynamic>(
        path,
        data: body,
        options: Options(method: method),
      );
      return response.data;
    } on DioException catch (error) {
      final database = _database;
      if (error.response != null || database == null) rethrow;
      await database.enqueue(_bucket, {
        'method': method,
        'path': path,
        'body': body,
      });
      AppLogger.log('OfflineQueue: queued $method $path');
      return null;
    }
  }

  Future<void> flush() async {
    final database = _database;
    if (_flushing || database == null || !AppEnv.useRemote) return;
    _flushing = true;
    try {
      for (final row in await database.pending()) {
        if (row['bucket'] != _bucket) continue;
        final payload = Map<String, Object?>.from(row['payload']! as Map);
        try {
          await _dio.request<dynamic>(
            payload['path']! as String,
            data: payload['body'],
            options: Options(method: payload['method']! as String),
          );
        } on DioException catch (error) {
          if (error.response == null) return;
          AppLogger.log(
            'OfflineQueue: dropped ${payload['path']} ${error.response?.statusCode}',
          );
        }
        await database.removeQueued(row['id']! as int);
      }
    } finally {
      _flushing = false;
    }
  }
}
