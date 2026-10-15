import 'package:equatable/equatable.dart';
import 'package:outmed/core/network/api_json.dart';

class LoginActivity extends Equatable {
  const LoginActivity({
    required this.id,
    this.ipAddress = '',
    this.userAgent = '',
    this.deviceType = '',
    this.location = '',
    this.createdAt,
  });

  final String id;
  final String ipAddress;
  final String userAgent;
  final String deviceType;
  final String location;
  final DateTime? createdAt;

  bool get mobile {
    final text = '$deviceType $userAgent'.toLowerCase();
    return text.contains('ios') ||
        text.contains('android') ||
        text.contains('iphone') ||
        text.contains('mobile') ||
        text.contains('dart');
  }

  String get deviceLabel {
    if (deviceType.isNotEmpty) return deviceType;
    final agent = userAgent.toLowerCase();
    if (agent.contains('iphone') || agent.contains('ios')) return 'iOS';
    if (agent.contains('android')) return 'Android';
    if (agent.contains('mac')) return 'macOS';
    if (agent.contains('windows')) return 'Windows';
    return userAgent;
  }

  static LoginActivity? tryParse(Map<String, Object?> json) {
    final id = ApiJson.text(json, const ['id']);
    if (id == null) return null;
    final created = ApiJson.text(json, const ['createdAt', 'created_at']);
    return LoginActivity(
      id: id,
      ipAddress: ApiJson.text(json, const ['ipAddress', 'ip']) ?? '',
      userAgent: ApiJson.text(json, const ['userAgent', 'user_agent']) ?? '',
      deviceType: ApiJson.text(json, const ['deviceType', 'device']) ?? '',
      location: ApiJson.text(json, const ['location']) ?? '',
      createdAt: created == null ? null : DateTime.tryParse(created)?.toLocal(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    ipAddress,
    userAgent,
    deviceType,
    location,
    createdAt,
  ];
}
