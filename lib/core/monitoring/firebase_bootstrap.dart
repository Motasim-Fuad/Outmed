import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/logger/app_logger.dart';

class FirebaseBootstrap {
  static Future<void> start() async {
    if (!AppEnv.firebaseEnabled || AppEnv.isTest) {
      AppLogger.log('FirebaseBootstrap: skipped');
      return;
    }
    try {
      await Firebase.initializeApp();
      if (kReleaseMode) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      }
      AppLogger.log('FirebaseBootstrap: ready');
    } on Object catch (error) {
      AppLogger.log('FirebaseBootstrap: $error');
    }
  }
}
