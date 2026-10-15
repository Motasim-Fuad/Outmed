import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/extensions/date_label.dart';
import 'package:outmed/features/notifications/data/models/app_notification.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_event.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({required this.notification, super.key});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      onTap: notification.read
          ? null
          : () => context.read<NotificationBloc>().add(
              NotificationRead(notification.id),
            ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primarySoft,
            child: Icon(
              notification.read
                  ? Icons.notifications_none_rounded
                  : Icons.notifications_active_rounded,
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
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.read
                        ? FontWeight.w600
                        : FontWeight.w800,
                  ),
                ),
                if (notification.body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                notification.createdAt.shortLabel,
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
              if (!notification.read) ...[
                const SizedBox(height: 6),
                const CircleAvatar(
                  radius: 4,
                  backgroundColor: AppColors.primary,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
