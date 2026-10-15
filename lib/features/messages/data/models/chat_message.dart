import 'package:equatable/equatable.dart';
import 'package:outmed/core/network/api_json.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.content,
    required this.mine,
    this.sentAt,
    this.pending = false,
  });

  final String id;
  final String content;
  final bool mine;
  final DateTime? sentAt;
  final bool pending;

  static ChatMessage? tryParse(Map<String, Object?> json, String myUserId) {
    final id = ApiJson.text(json, const ['id']);
    final content = ApiJson.text(json, const ['content', 'text', 'message']);
    if (id == null || content == null) return null;
    final sender = ApiJson.asMap(json['sender']);
    final senderId =
        ApiJson.text(json, const ['senderId', 'senderUserId', 'userId']) ??
        (sender == null ? null : ApiJson.text(sender, const ['id'])) ??
        '';
    return ChatMessage(
      id: id,
      content: content,
      mine:
          json['isMine'] == true ||
          (senderId.isNotEmpty && senderId == myUserId),
      sentAt: DateTime.tryParse(
        ApiJson.text(json, const ['createdAt', 'sentAt']) ?? '',
      ),
    );
  }

  @override
  List<Object?> get props => [id, content, mine, sentAt, pending];
}
