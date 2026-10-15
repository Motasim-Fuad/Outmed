import 'package:equatable/equatable.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/messages/data/models/chat_message.dart';
import 'package:outmed/features/messages/data/models/chat_thread.dart';

class ChatState extends Equatable {
  const ChatState({
    this.threads = const [],
    this.threadsStatus = LoadStatus.initial,
    this.filter = 'all',
    this.query = '',
    this.active,
    this.messages = const [],
    this.messagesStatus = LoadStatus.initial,
    this.sending = false,
    this.errorMessage = '',
  });

  final List<ChatThread> threads;
  final LoadStatus threadsStatus;
  final String filter;
  final String query;
  final ChatThread? active;
  final List<ChatMessage> messages;
  final LoadStatus messagesStatus;
  final bool sending;
  final String errorMessage;

  List<ChatThread> get visibleThreads {
    final text = query.trim().toLowerCase();
    return threads
        .where((thread) {
          if (filter == 'unread' && thread.unread == 0) return false;
          if (filter == 'order' && thread.orderId.isEmpty) return false;
          if (text.isEmpty) return true;
          return thread.title.toLowerCase().contains(text) ||
              thread.preview.toLowerCase().contains(text);
        })
        .toList(growable: false);
  }

  int get unreadTotal =>
      threads.fold(0, (total, thread) => total + thread.unread);

  ChatState copyWith({
    List<ChatThread>? threads,
    LoadStatus? threadsStatus,
    String? filter,
    String? query,
    ChatThread? active,
    List<ChatMessage>? messages,
    LoadStatus? messagesStatus,
    bool? sending,
    String? errorMessage,
  }) {
    return ChatState(
      threads: threads ?? this.threads,
      threadsStatus: threadsStatus ?? this.threadsStatus,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      active: active ?? this.active,
      messages: messages ?? this.messages,
      messagesStatus: messagesStatus ?? this.messagesStatus,
      sending: sending ?? this.sending,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    threads,
    threadsStatus,
    filter,
    query,
    active,
    messages,
    messagesStatus,
    sending,
    errorMessage,
  ];
}
