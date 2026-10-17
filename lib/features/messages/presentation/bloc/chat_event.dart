import 'package:equatable/equatable.dart';
import 'package:outmed/features/messages/data/models/chat_lookup.dart';
import 'package:outmed/features/messages/data/models/chat_realtime_event.dart';
import 'package:outmed/features/messages/data/models/chat_thread.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatEvent {
  const ChatStarted();
}

class ChatFilterChanged extends ChatEvent {
  const ChatFilterChanged(this.filter);

  final String filter;

  @override
  List<Object?> get props => [filter];
}

class ChatSearchChanged extends ChatEvent {
  const ChatSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ChatThreadOpened extends ChatEvent {
  const ChatThreadOpened(this.thread);

  final ChatThread thread;

  @override
  List<Object?> get props => [thread];
}

class ChatNotificationOpened extends ChatEvent {
  const ChatNotificationOpened(this.lookup);

  final ChatLookup lookup;

  @override
  List<Object?> get props => [lookup];
}

class ChatMessageSent extends ChatEvent {
  const ChatMessageSent(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

class ChatTypingChanged extends ChatEvent {
  const ChatTypingChanged({required this.isTyping});

  final bool isTyping;

  @override
  List<Object?> get props => [isTyping];
}

class ChatRealtimeReceived extends ChatEvent {
  const ChatRealtimeReceived(this.event);

  final ChatRealtimeEvent event;

  @override
  List<Object?> get props => [event];
}

class ChatReset extends ChatEvent {
  const ChatReset();
}
