import 'package:equatable/equatable.dart';
import 'package:outmed/features/messages/data/models/chat_thread.dart';

class ChatLookup extends Equatable {
  const ChatLookup({
    this.conversationId = '',
    this.senderId = '',
    this.senderName = '',
    this.preview = '',
  });

  final String conversationId;
  final String senderId;
  final String senderName;
  final String preview;

  ChatThread? match(List<ChatThread> threads) {
    ChatThread? find(bool Function(ChatThread thread) test) {
      for (final thread in threads) {
        if (test(thread)) return thread;
      }
      return null;
    }

    final text = preview.trim();
    final name = senderName.trim().toLowerCase();
    return (conversationId.isEmpty
            ? null
            : find((thread) => thread.id == conversationId)) ??
        (senderId.isEmpty
            ? null
            : find((thread) => thread.participantUserId == senderId)) ??
        (name.isEmpty
            ? null
            : find((thread) => thread.title.toLowerCase() == name)) ??
        (text.isEmpty
            ? null
            : find(
                (thread) => thread.unread > 0 && thread.preview.trim() == text,
              )) ??
        (text.isEmpty
            ? null
            : find((thread) => thread.preview.trim() == text)) ??
        find((thread) => thread.unread > 0) ??
        (threads.length == 1 ? threads.first : null);
  }

  @override
  List<Object?> get props => [conversationId, senderId, senderName, preview];
}
