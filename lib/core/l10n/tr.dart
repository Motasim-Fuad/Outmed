import 'package:outmed/core/l10n/app_locale.dart';

extension Tr on String {
  String get tr => AppLocale.translate(this);

  String trParams(Map<String, String> params) => AppLocale.translate(this, params);
}
