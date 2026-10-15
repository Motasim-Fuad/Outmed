import 'package:flutter/material.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/extensions/date_label.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/features/messages/data/models/chat_thread.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({required this.thread, super.key});

  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      onTap: () => AppNav.push(AppRoutes.chat, extra: thread),
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primarySoft,
            child: Text(
              thread.title.isEmpty ? '?' : thread.title.substring(0, 1),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  thread.preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                thread.updatedAt.shortLabel,
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
              if (thread.unread > 0) ...[
                const SizedBox(height: 6),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    '${thread.unread}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
