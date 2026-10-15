import 'package:equatable/equatable.dart';
import 'package:outmed/core/network/api_json.dart';

class ChatThread extends Equatable {
  const ChatThread({
    required this.title,
    this.id = '',
    this.preview = '',
    this.updatedAt,
    this.unread = 0,
    this.participantUserId = '',
    this.orderId = '',
  });

  final String id;
  final String title;
  final String preview;
  final DateTime? updatedAt;
  final int unread;
  final String participantUserId;
  final String orderId;

  static ChatThread? tryParse(Map<String, Object?> json, String myUserId) {
    final id = ApiJson.text(json, const ['id', 'conversationId']);
    if (id == null) return null;
    final other = _otherParticipant(json, myUserId);
    final last = ApiJson.asMap(json['lastMessage']) ?? _lastFromList(json);
    return ChatThread(
      id: id,
      title: other.$2.isEmpty ? 'OutMed' : other.$2,
      participantUserId: other.$1,
      preview: last == null
          ? ''
          : ApiJson.text(last, const ['content', 'text']) ?? '',
      updatedAt: DateTime.tryParse(
        (last == null
                ? null
                : ApiJson.text(last, const ['createdAt', 'sentAt'])) ??
            ApiJson.text(json, const [
              'lastMessageAt',
              'updatedAt',
              'createdAt',
            ]) ??
            '',
      ),
      unread:
          ApiJson.integer(json, const [
            'unreadCount',
            'unread',
            'unreadMessages',
          ]) ??
          0,
      orderId: ApiJson.text(json, const ['orderId']) ?? '',
    );
  }

  static Map<String, Object?>? _lastFromList(Map<String, Object?> json) {
    final messages = json['messages'];
    if (messages is! List || messages.isEmpty) return null;
    return ApiJson.asMap(messages.first);
  }

  static (String, String) _otherParticipant(
    Map<String, Object?> json,
    String myUserId,
  ) {
    for (final key in const ['otherParticipant', 'participant', 'otherUser']) {
      final map = ApiJson.asMap(json[key]);
      if (map != null) return _identity(map);
    }
    final participants = json['participants'];
    if (participants is List) {
      for (final item in participants) {
        final map = ApiJson.asMap(item);
        if (map == null) continue;
        final identity = _identity(map);
        if (identity.$1 != myUserId) return identity;
      }
    }
    return ('', ApiJson.text(json, const ['title', 'name']) ?? '');
  }

  static (String, String) _identity(Map<String, Object?> map) {
    final user = ApiJson.asMap(map['user']) ?? map;
    final profile =
        ApiJson.asMap(user['supplierProfile']) ??
        ApiJson.asMap(user['buyerProfile']);
    final name =
        (profile == null
            ? null
            : ApiJson.text(profile, const [
                'companyName',
                'organizationName',
              ])) ??
        ApiJson.text(user, const [
          'companyName',
          'organizationName',
          'fullName',
          'name',
          'email',
        ]) ??
        '';
    final id =
        ApiJson.text(map, const ['userId']) ??
        ApiJson.text(user, const ['id']) ??
        '';
    return (id, name);
  }

  ChatThread copyWith({
    String? id,
    String? preview,
    DateTime? updatedAt,
    int? unread,
  }) {
    return ChatThread(
      id: id ?? this.id,
      title: title,
      preview: preview ?? this.preview,
      updatedAt: updatedAt ?? this.updatedAt,
      unread: unread ?? this.unread,
      participantUserId: participantUserId,
      orderId: orderId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    preview,
    updatedAt,
    unread,
    participantUserId,
    orderId,
  ];
}
