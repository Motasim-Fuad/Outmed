import 'package:flutter_test/flutter_test.dart';
import 'package:outmed/features/messages/data/models/chat_realtime_event.dart';

void main() {
  test('parses socket newMessage payload', () {
    final event = ChatRealtimeEvent.tryParse('newMessage', {
      'id': 'm1',
      'conversationId': 'c1',
      'senderId': 'u1',
      'content': 'hello',
      'createdAt': '2026-10-15T06:26:06.956Z',
    });

    expect(event, isA<ChatRealtimeNewMessage>());
    expect((event! as ChatRealtimeNewMessage).conversationId, 'c1');
  });

  test('parses wrapped ack-style payload list', () {
    final event = ChatRealtimeEvent.tryParse('userTyping', [
      {'conversationId': 'c1', 'userId': 'u2', 'isTyping': true},
    ]);

    expect(
      event,
      const ChatRealtimeTyping(
        conversationId: 'c1',
        userId: 'u2',
        isTyping: true,
      ),
    );
  });

  test('parses messagesRead', () {
    final event = ChatRealtimeEvent.tryParse('messagesRead', {
      'conversationId': 'c1',
      'userId': 'u2',
    });

    expect(event, const ChatRealtimeRead(conversationId: 'c1', userId: 'u2'));
  });
}
