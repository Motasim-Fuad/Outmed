import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF00897B);
  static const primaryDark = Color(0xFF00695C);
  static const primarySoft = Color(0xFFE5F5F3);
  static const accent = Color(0xFFFF775F);
  static const ink = Color(0xFF182527);
  static const muted = Color(0xFF748082);
  static const canvas = Color(0xFFF7F9F9);
  static const mint = Color(0xFFE8F7F3);
  static const border = Color(0xFFE1E7E7);

  static List<BoxShadow> get glossyShadow => [
    BoxShadow(
      color: primary.withValues(alpha: .18),
      blurRadius: 28,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: const Color(0xFF182527).withValues(alpha: .06),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: .85),
      blurRadius: 1,
      offset: const Offset(0, -1),
    ),
  ];
  static const success = Color(0xFF1AAE76);
  static const warning = Color(0xFFF3A647);
  static const danger = Color(0xFFE25757);
}
