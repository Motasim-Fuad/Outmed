import 'dart:io';

import 'package:flutter/foundation.dart';

abstract final class AppEnv {
  static const name = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://janet-produces-echo-bonus.trycloudflare.com',
  );
  static const stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );
  static const firebaseEnabled = bool.fromEnvironment('FIREBASE_ENABLED');
  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
  static const googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );
  static const appleSignInEnabled = bool.fromEnvironment(
    'APPLE_SIGN_IN_ENABLED',
  );

  static bool get isMock => name == 'mock';

  static bool get useRemote => !isMock && !isTest;

  static bool get isTest =>
      !kIsWeb && Platform.environment['FLUTTER_TEST'] == 'true';
}
