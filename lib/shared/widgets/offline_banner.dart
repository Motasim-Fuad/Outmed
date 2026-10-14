import 'package:flutter/material.dart';
import 'package:outmed/core/connectivity/connectivity_service.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityService.instance.online,
      builder: (context, online, _) {
        if (online) return const SizedBox.shrink();
        return Material(
          color: AppColors.ink,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'offline_banner'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }
}
