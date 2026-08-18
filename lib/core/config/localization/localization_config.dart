import 'dart:ui';

abstract final class LocalizationConfig {
  static const fallbackLocale = Locale('en', 'US');
  static const supportedLocales = [Locale('en', 'US'), Locale('ar', 'SA')];
}
