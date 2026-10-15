import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/logger/app_logger.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  String? accessToken;
  String? refreshToken;

  String get userId {
    final parts = accessToken?.split('.') ?? const <String>[];
    if (parts.length != 3) return '';
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map) return '';
      final id = payload['sub'] ?? payload['userId'] ?? payload['id'];
      return id?.toString() ?? '';
    } on FormatException {
      return '';
    }
  }

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

  Future<String?> load() async {
    if (AppEnv.isTest) return null;
    try {
      accessToken = await _storage.read(key: 'access_token');
      refreshToken = await _storage.read(key: 'refresh_token');
      return await _storage.read(key: 'role');
    } on Object catch (error) {
      AppLogger.log('TokenStore: $error');
      return null;
    }
  }

  Future<void> saveRole(String role) async {
    if (AppEnv.isTest) return;
    try {
      await _storage.write(key: 'role', value: role);
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
    unawaited(_storage.delete(key: 'role'));
  }
}
