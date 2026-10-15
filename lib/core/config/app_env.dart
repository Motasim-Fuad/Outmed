import 'dart:io';

import 'package:flutter/foundation.dart';

abstract final class AppEnv {
  static const name = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://departure-logos-getting-paths.trycloudflare.com',
  );
  static const stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );
  static const firebaseEnabled = bool.fromEnvironment('FIREBASE_ENABLED');

  static bool get isMock => name == 'mock';

  static bool get useRemote => !isMock && !isTest;

  static bool get isTest =>
      !kIsWeb && Platform.environment['FLUTTER_TEST'] == 'true';
}
