import 'package:flutter/widgets.dart';
import 'package:outmed/core/config/localization/ar_sa.dart';
import 'package:outmed/core/config/localization/en_us.dart';
import 'package:outmed/core/config/localization/localization_config.dart';

class AppLocale extends ChangeNotifier {
  AppLocale._();

  static final instance = AppLocale._();

  Locale locale = LocalizationConfig.fallbackLocale;

  static Map<String, String> get _map =>
      instance.locale.languageCode == 'ar' ? arSa : enUs;

  static String translate(String key, [Map<String, String>? params]) {
    var value = _map[key] ?? enUs[key] ?? key;
    if (params != null) {
      for (final entry in params.entries) {
        value = value.replaceAll('@${entry.key}', entry.value);
      }
    }
    return value;
  }

  void setLocale(Locale value) {
    if (value == locale) return;
    locale = value;
    notifyListeners();
  }
}
