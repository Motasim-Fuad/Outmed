import 'package:equatable/equatable.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsStarted extends NotificationEvent {
  const NotificationsStarted();
}

class NotificationRead extends NotificationEvent {
  const NotificationRead(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class NotificationsAllRead extends NotificationEvent {
  const NotificationsAllRead();
}

class NotificationsReset extends NotificationEvent {
  const NotificationsReset();
}
