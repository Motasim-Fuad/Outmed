import 'package:equatable/equatable.dart';
import 'package:outmed/core/network/api_json.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    this.body = '',
    this.type = '',
    this.read = false,
    this.createdAt,
    this.orderId = '',
    this.conversationId = '',
    this.productId = '',
    this.senderName = '',
    this.senderId = '',
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime? createdAt;
  final String orderId;
  final String conversationId;
  final String productId;
  final String senderName;
  final String senderId;

  String get kind {
    final text = type.toUpperCase();
    if (conversationId.isNotEmpty ||
        text.contains('MESSAGE') ||
        text.contains('CHAT')) {
      return 'chat';
    }
    if (orderId.isNotEmpty || text.contains('ORDER')) return 'order';
    if (text.contains('STOCK') || text.contains('INVENTORY')) return 'stock';
    if (productId.isNotEmpty || text.contains('PRODUCT')) return 'product';
    if (text.contains('VERIF') || text.contains('ACCOUNT')) return 'account';
    if (text.contains('SUPPORT') || text.contains('TICKET')) return 'support';
    return '';
  }

  static AppNotification? tryParse(Map<String, Object?> json) {
    final id = ApiJson.text(json, const ['id']);
    final title = ApiJson.text(json, const ['title', 'subject']);
    final body = ApiJson.text(json, const ['body', 'message', 'content']);
    if (id == null || (title == null && body == null)) return null;
    final data =
        ApiJson.asMap(json['data']) ??
        ApiJson.asMap(json['metadata']) ??
        ApiJson.asMap(json['payload']) ??
        ApiJson.asMap(json['meta']) ??
        const <String, Object?>{};
    final referenceType =
        (ApiJson.text(json, const ['referenceType', 'entityType']) ??
                ApiJson.text(data, const ['referenceType', 'entityType']) ??
                '')
            .toUpperCase();
    final referenceId =
        ApiJson.text(json, const ['referenceId', 'entityId']) ??
        ApiJson.text(data, const ['referenceId', 'entityId', 'id']) ??
        '';
    final sender =
        ApiJson.asMap(data['sender']) ??
        ApiJson.asMap(json['sender']) ??
        ApiJson.asMap(data['fromUser']) ??
        const <String, Object?>{};
    const senderNameKeys = [
      'senderName',
      'sender_name',
      'fromName',
      'actorName',
    ];
    const senderIdKeys = ['senderId', 'sender_id', 'fromUserId', 'actorId'];
    final link = Uri.tryParse(
      ApiJson.text(json, const ['link', 'deepLink', 'url', 'actionUrl']) ??
          ApiJson.text(data, const ['link', 'deepLink', 'url']) ??
          '',
    );
    final segments = link?.pathSegments ?? const <String>[];
    String fromLink(List<String> prefixes) {
      for (var i = 0; i < segments.length - 1; i++) {
        if (prefixes.contains(segments[i].toLowerCase())) {
          return segments[i + 1];
        }
      }
      return '';
    }

    String pick(
      List<String> keys,
      String reference,
      List<String> linkPrefixes,
    ) {
      final direct =
          ApiJson.text(json, keys) ??
          ApiJson.text(data, keys) ??
          (referenceType.contains(reference) ? referenceId : '');
      return direct.isNotEmpty ? direct : fromLink(linkPrefixes);
    }

    return AppNotification(
      id: id,
      title: title ?? body!,
      body: title == null ? '' : body ?? '',
      type: ApiJson.text(json, const ['type']) ?? '',
      read:
          json['isRead'] == true ||
          json['read'] == true ||
          json['readAt'] != null,
      createdAt: DateTime.tryParse(
        ApiJson.text(json, const ['createdAt']) ?? '',
      ),
      orderId: pick(
        const ['orderId', 'order_id'],
        'ORDER',
        const ['orders', 'order'],
      ),
      conversationId: pick(
        const ['conversationId', 'conversation_id', 'chatId'],
        'CONVERSATION',
        const ['chat', 'chats', 'conversations', 'messages'],
      ),
      productId: pick(
        const ['productId', 'product_id'],
        'PRODUCT',
        const ['products', 'product'],
      ),
      senderName:
          ApiJson.text(data, senderNameKeys) ??
          ApiJson.text(json, senderNameKeys) ??
          ApiJson.text(sender, const [
            'companyName',
            'organizationName',
            'fullName',
            'name',
          ]) ??
          '',
      senderId:
          ApiJson.text(data, senderIdKeys) ??
          ApiJson.text(json, senderIdKeys) ??
          ApiJson.text(sender, const ['id', 'userId']) ??
          '',
    );
  }

  AppNotification markRead() => AppNotification(
    id: id,
    title: title,
    body: body,
    type: type,
    read: true,
    createdAt: createdAt,
    orderId: orderId,
    conversationId: conversationId,
    productId: productId,
    senderName: senderName,
    senderId: senderId,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    type,
    read,
    createdAt,
    orderId,
    conversationId,
    productId,
    senderName,
    senderId,
  ];
}
