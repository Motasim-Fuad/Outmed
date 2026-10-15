import 'package:flutter_test/flutter_test.dart';
import 'package:outmed/features/messages/data/models/chat_lookup.dart';
import 'package:outmed/features/messages/data/models/chat_thread.dart';
import 'package:outmed/features/notifications/data/models/app_notification.dart';

void main() {
  test('message notification links to its conversation', () {
    final item = AppNotification.tryParse(const {
      'id': 'n1',
      'title': 'New Message',
      'body': 'hi',
      'type': 'NEW_MESSAGE',
      'data': {'conversationId': 'c1', 'senderName': 'Acme'},
    })!;

    expect(item.kind, 'chat');
    expect(item.conversationId, 'c1');
    expect(item.senderName, 'Acme');
  });

  test('reference id resolves by reference type', () {
    final item = AppNotification.tryParse(const {
      'id': 'n2',
      'title': 'Order shipped',
      'type': 'ORDER_STATUS',
      'referenceType': 'ORDER',
      'referenceId': 'o9',
    })!;

    expect(item.kind, 'order');
    expect(item.orderId, 'o9');
    expect(item.conversationId, isEmpty);
  });

  test('unknown type has no target', () {
    final item = AppNotification.tryParse(const {
      'id': 'n3',
      'title': 'Welcome',
      'type': 'SYSTEM',
    })!;

    expect(item.kind, isEmpty);
  });
  test('nested sender is parsed', () {
    final item = AppNotification.tryParse(const {
      'id': 'n4',
      'title': 'New Message',
      'body': 'hi',
      'type': 'NEW_MESSAGE',
      'data': {
        'sender': {'id': 'u7', 'fullName': 'Rahim'},
      },
    })!;

    expect(item.senderId, 'u7');
    expect(item.senderName, 'Rahim');
  });

  test('chat lookup finds thread by sender, then by unread preview', () {
    const threads = [
      ChatThread(id: 'c1', title: 'Acme', participantUserId: 'u1'),
      ChatThread(id: 'c2', title: 'Rahim', preview: 'hi', unread: 1),
    ];

    expect(const ChatLookup(senderId: 'u1').match(threads)?.id, 'c1');
    expect(const ChatLookup(preview: 'hi').match(threads)?.title, 'Rahim');
    expect(const ChatLookup(conversationId: 'c1').match(threads)?.id, 'c1');
  });

  test('backend link carries the conversation id', () {
    final item = AppNotification.tryParse(const {
      'id': 'n5',
      'title': 'New Message',
      'message': 'Cobb',
      'type': 'CHAT',
      'link': '/chat/6b9b6f2c-4bda-4b99-9f33-b86f21686d01',
    })!;

    expect(item.kind, 'chat');
    expect(item.body, 'Cobb');
    expect(item.conversationId, '6b9b6f2c-4bda-4b99-9f33-b86f21686d01');
  });
}
