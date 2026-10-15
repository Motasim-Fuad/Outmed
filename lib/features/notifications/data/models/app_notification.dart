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
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime? createdAt;

  static AppNotification? tryParse(Map<String, Object?> json) {
    final id = ApiJson.text(json, const ['id']);
    final title = ApiJson.text(json, const ['title', 'subject']);
    final body = ApiJson.text(json, const ['body', 'message', 'content']);
    if (id == null || (title == null && body == null)) return null;
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
    );
  }

  AppNotification markRead() => AppNotification(
    id: id,
    title: title,
    body: body,
    type: type,
    read: true,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [id, title, body, type, read, createdAt];
}
