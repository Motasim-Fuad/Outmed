import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/logger/app_logger.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  String? accessToken;
  String? refreshToken;

  Future<void> save({required String access, String? refresh}) async {
    accessToken = access;
    refreshToken = refresh ?? refreshToken;
    if (AppEnv.isTest) return;
    try {
      await _storage.write(key: 'access_token', value: accessToken);
      if (refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }
    } on Object catch (error) {
      AppLogger.log('TokenStore: $error');
    }
  }

  void clear() {
    accessToken = null;
    refreshToken = null;
    if (AppEnv.isTest) return;
    unawaited(_storage.delete(key: 'access_token'));
    unawaited(_storage.delete(key: 'refresh_token'));
  }
}
