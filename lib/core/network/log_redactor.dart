abstract final class LogRedactor {
  static final _bearer = RegExp(r'Bearer\s+[A-Za-z0-9\-_\.]+');
  static final _secrets = RegExp(
    '("?(?:accessToken|refreshToken|access_token|refresh_token|token|'
    'resetToken|password|currentPassword|newPassword|confirmPassword|otp)"?'
    r'\s*[:=]\s*)("[^"]*"|[^,\s}]+)',
    caseSensitive: false,
  );

  static String redact(String message) {
    return message
        .replaceAll(_bearer, 'Bearer ***')
        .replaceAllMapped(_secrets, (match) => '${match[1]}***');
  }
}
