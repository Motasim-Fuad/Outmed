import 'package:intl/intl.dart';
import 'package:outmed/core/l10n/app_locale.dart';

extension DateLabel on DateTime? {
  String get shortLabel {
    final value = this?.toLocal();
    if (value == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(value.year, value.month, value.day);
    final locale = AppLocale.instance.locale.languageCode;
    if (day == today) return DateFormat.Hm(locale).format(value);
    if (today.difference(day).inDays == 1) {
      return AppLocale.translate('yesterday');
    }
    if (today.difference(day).inDays < 7) {
      return DateFormat.E(locale).format(value);
    }
    return DateFormat.MMMd(locale).format(value);
  }

  String get dateTimeLabel {
    final value = this?.toLocal();
    if (value == null) return '';
    final locale = AppLocale.instance.locale.languageCode;
    return '${DateFormat.yMMMd(locale).format(value)} · '
        '${DateFormat.Hm(locale).format(value)}';
  }

  String get mediumLabel {
    final value = this?.toLocal();
    if (value == null) return '';
    return DateFormat.yMMMd(
      AppLocale.instance.locale.languageCode,
    ).format(value);
  }
}
