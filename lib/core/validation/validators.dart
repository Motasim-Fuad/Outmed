import 'package:outmed/core/l10n/tr.dart';

abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _password = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[\d\W]).{8,}$');

  static String? required(String? value) {
    return value == null || value.trim().isEmpty ? 'required_field'.tr : null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'required_field'.tr;
    return _email.hasMatch(text) ? null : 'invalid_email'.tr;
  }

  static String? strongPassword(String? value) {
    return _password.hasMatch(value ?? '') ? null : 'password_rules'.tr;
  }

  static String? year(String? value) {
    final year = int.tryParse(value?.trim() ?? '');
    if (year == null || year < 1800 || year > DateTime.now().year) {
      return 'invalid_year'.tr;
    }
    return null;
  }

  static String? optionalWebsite(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;
    final uri = Uri.tryParse(raw.contains('://') ? raw : 'https://$raw');
    if (uri == null || !uri.host.contains('.')) return 'invalid_website'.tr;
    return null;
  }

  static String? phone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 8 || digits.length > 15) return 'invalid_phone'.tr;
    return null;
  }

  static String? price(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    return number == null || number <= 0 ? 'invalid_number'.tr : null;
  }

  static String? optionalPrice(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return price(value);
  }

  static String? Function(String?) discountBelow(String Function() price) {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;
      final discount = double.tryParse(value.trim());
      final selling = double.tryParse(price().trim());
      if (discount == null || discount <= 0) return 'invalid_number'.tr;
      if (selling != null && discount >= selling) {
        return 'discount_below_price'.tr;
      }
      return null;
    };
  }

  static String? Function(String?) wholeNumber({int min = 0}) {
    return (value) {
      final number = int.tryParse(value?.trim() ?? '');
      return number == null || number < min ? 'invalid_number'.tr : null;
    };
  }
}
