import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/extensions/date_label.dart';
import 'package:outmed/features/messages/data/models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({required this.message, this.seen = false, super.key});

  final ChatMessage message;
  final bool seen;

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    final meta = mine ? Colors.white70 : AppColors.muted;
    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.glossyShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: 1,
              child: Text(
                message.content,
                style: TextStyle(color: mine ? Colors.white : AppColors.ink),
              ),
            ),
            if (message.sentAt != null || message.pending) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.sentAt.shortLabel,
                    style: TextStyle(color: meta, fontSize: 10),
                  ),
                  if (message.pending) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.schedule_rounded, size: 12, color: meta),
                  ] else if (mine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      seen ? Icons.done_all_rounded : Icons.done_rounded,
                      size: 12,
                      color: meta,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
