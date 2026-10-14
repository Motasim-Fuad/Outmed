import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';

class AppToast {
  static void show(BuildContext context, String message) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: 24,
        right: 24,
        bottom: 32,
        child: Material(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future<void>.delayed(const Duration(seconds: 2), entry.remove);
  }
}
