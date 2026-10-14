import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';

class AppErrorScreen extends StatelessWidget {
  const AppErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ColoredBox(
        color: AppColors.canvas,
        child: Center(
          child: Text(
            'unexpected_error'.tr,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
