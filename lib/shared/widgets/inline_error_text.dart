import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';

class InlineErrorText extends StatelessWidget {
  const InlineErrorText({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
