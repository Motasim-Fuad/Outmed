import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  static void log(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'outmed');
    }
  }
}
