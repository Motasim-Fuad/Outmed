import 'package:equatable/equatable.dart';
import 'package:outmed/core/network/api_json.dart';

sealed class ChatRealtimeEvent extends Equatable {
  const ChatRealtimeEvent();

  static ChatRealtimeEvent? tryParse(String event, Object? data) {
    final json = mapOf(data);
    return switch (event) {
      'connect' => const ChatRealtimeConnected(),
      'disconnect' => const ChatRealtimeDisconnected(),
      'newMessage' => json == null ? null : ChatRealtimeNewMessage(json),
      'userTyping' => json == null ? null : ChatRealtimeTyping.tryParse(json),
      'messagesRead' => json == null ? null : ChatRealtimeRead.tryParse(json),
      _ => null,
    };
  }

  static Map<String, Object?>? mapOf(Object? data) {
    if (data is List && data.isNotEmpty) return ApiJson.asMap(data.first);
    return ApiJson.asMap(data);
  }

  @override
  List<Object?> get props => [];
}

class ChatRealtimeConnected extends ChatRealtimeEvent {
  const ChatRealtimeConnected();
}

class ChatRealtimeDisconnected extends ChatRealtimeEvent {
  const ChatRealtimeDisconnected();
}

class ChatRealtimeNewMessage extends ChatRealtimeEvent {
  const ChatRealtimeNewMessage(this.json);

  final Map<String, Object?> json;

  String get conversationId =>
      ApiJson.text(json, const ['conversationId', 'conversation_id']) ?? '';

  @override
  List<Object?> get props => [json];
}

class ChatRealtimeTyping extends ChatRealtimeEvent {
  const ChatRealtimeTyping({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
  });

  final String conversationId;
  final String userId;
  final bool isTyping;

  static ChatRealtimeTyping? tryParse(Map<String, Object?> json) {
    final conversationId = ApiJson.text(json, const [
      'conversationId',
      'conversation_id',
    ]);
    if (conversationId == null) return null;
    return ChatRealtimeTyping(
      conversationId: conversationId,
      userId: ApiJson.text(json, const ['userId', 'user_id']) ?? '',
      isTyping: json['isTyping'] == true,
    );
  }

  @override
  List<Object?> get props => [conversationId, userId, isTyping];
}

class ChatRealtimeRead extends ChatRealtimeEvent {
  const ChatRealtimeRead({required this.conversationId, required this.userId});

  final String conversationId;
  final String userId;

  static ChatRealtimeRead? tryParse(Map<String, Object?> json) {
    final conversationId = ApiJson.text(json, const [
      'conversationId',
      'conversation_id',
    ]);
    if (conversationId == null) return null;
    return ChatRealtimeRead(
      conversationId: conversationId,
      userId: ApiJson.text(json, const ['userId', 'user_id']) ?? '',
    );
  }

  @override
  List<Object?> get props => [conversationId, userId];
}
