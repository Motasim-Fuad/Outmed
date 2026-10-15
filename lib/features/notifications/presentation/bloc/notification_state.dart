import 'package:equatable/equatable.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/notifications/data/models/app_notification.dart';

class NotificationState extends Equatable {
  const NotificationState({
    this.items = const [],
    this.status = LoadStatus.initial,
    this.errorMessage = '',
  });

  final List<AppNotification> items;
  final LoadStatus status;
  final String errorMessage;

  int get unread => items.where((item) => !item.read).length;

  NotificationState copyWith({
    List<AppNotification>? items,
    LoadStatus? status,
    String? errorMessage,
  }) {
    return NotificationState(
      items: items ?? this.items,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [items, status, errorMessage];
}
