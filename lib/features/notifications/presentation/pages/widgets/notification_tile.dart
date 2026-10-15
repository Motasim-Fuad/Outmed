import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/extensions/date_label.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_bloc.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_state.dart';
import 'package:outmed/features/notifications/data/models/app_notification.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_event.dart';
import 'package:outmed/features/notifications/presentation/notification_navigator.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({required this.notification, super.key});

  final AppNotification notification;

  IconData get _icon => switch (notification.kind) {
    'chat' => Icons.chat_bubble_outline_rounded,
    'order' => Icons.receipt_long_outlined,
    'stock' => Icons.inventory_2_outlined,
    'product' => Icons.medical_services_outlined,
    'account' => Icons.verified_user_outlined,
    'support' => Icons.support_agent_rounded,
    _ =>
      notification.read
          ? Icons.notifications_none_rounded
          : Icons.notifications_active_rounded,
  };

  void _open(BuildContext context) {
    if (!notification.read) {
      context.read<NotificationBloc>().add(NotificationRead(notification.id));
    }
    NotificationNavigator.open(context, notification);
  }

  @override
  Widget build(BuildContext context) {
    final openable = NotificationNavigator.canOpen(notification);
    return GlossyCard(
      onTap: openable || !notification.read ? () => _open(context) : null,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primarySoft,
            child: Icon(
              _icon,
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
                  BlocSelector<ChatBloc, ChatState, String>(
                    selector: (state) {
                      if (notification.senderName.isNotEmpty) {
                        return notification.senderName;
                      }
                      if (notification.conversationId.isEmpty) return '';
                      for (final thread in state.threads) {
                        if (thread.id == notification.conversationId) {
                          return thread.title;
                        }
                      }
                      return '';
                    },
                    builder: (context, sender) => Text(
                      sender.isEmpty || notification.title.contains(sender)
                          ? notification.body
                          : '$sender: ${notification.body}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
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
              if (openable) ...[
                const SizedBox(height: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.muted,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
