import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/extensions/date_label.dart';
import 'package:outmed/features/profile/data/models/login_activity.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class LoginActivityTile extends StatelessWidget {
  const LoginActivityTile({required this.activity, super.key});

  final LoginActivity activity;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (activity.ipAddress.isNotEmpty) activity.ipAddress,
      if (activity.location.isNotEmpty) activity.location,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlossyCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primarySoft,
              child: Icon(
                activity.mobile
                    ? Icons.phone_iphone_rounded
                    : Icons.laptop_mac_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.deviceLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      details,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    activity.createdAt.dateTimeLabel,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
