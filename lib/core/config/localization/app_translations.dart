import 'package:get/get.dart';
import 'package:outmed/core/config/localization/ar_sa.dart';
import 'package:outmed/core/config/localization/en_us.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUs, 'ar_SA': arSa};
}
