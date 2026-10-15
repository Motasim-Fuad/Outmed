import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_error.dart';
import 'package:outmed/core/network/api_json.dart';
import 'package:outmed/core/network/offline_queue.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/notifications/data/models/app_notification.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_event.dart';
import 'package:outmed/features/notifications/presentation/bloc/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(this._cache, this._queue)
    : super(const NotificationState()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationRead>(_onRead);
    on<NotificationsAllRead>(_onAllRead);
    on<NotificationsReset>((event, emit) => emit(const NotificationState()));
  }

  static const _query = {'page': 1, 'limit': 50};

  final RemoteCache _cache;
  final OfflineQueue _queue;

  Future<void> _onStarted(
    NotificationsStarted event,
    Emitter<NotificationState> emit,
  ) async {
    if (!AppEnv.useRemote) {
      emit(state.copyWith(items: _demo, status: LoadStatus.success));
      return;
    }
    final cached = _parse(
      _cache.peek(ApiEndpoints.notifications, query: _query),
    );
    emit(
      state.copyWith(
        items: cached.isEmpty ? null : cached,
        status: cached.isEmpty && state.items.isEmpty
            ? LoadStatus.loading
            : LoadStatus.success,
        errorMessage: '',
      ),
    );
    try {
      final body = await _cache.get(ApiEndpoints.notifications, query: _query);
      emit(state.copyWith(items: _parse(body), status: LoadStatus.success));
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: ApiError.message(error),
        ),
      );
    }
  }

  void _onRead(NotificationRead event, Emitter<NotificationState> emit) {
    emit(
      state.copyWith(
        items: [
          for (final item in state.items)
            item.id == event.id ? item.markRead() : item,
        ],
      ),
    );
    if (!AppEnv.useRemote) return;
    unawaited(
      _queue
          .send('PATCH', ApiEndpoints.notificationRead(event.id))
          .catchError((Object _) => null),
    );
  }

  void _onAllRead(NotificationsAllRead event, Emitter<NotificationState> emit) {
    emit(
      state.copyWith(
        items: [for (final item in state.items) item.markRead()],
      ),
    );
    if (!AppEnv.useRemote) return;
    unawaited(
      _queue
          .send('PATCH', ApiEndpoints.notificationsReadAll)
          .catchError((Object _) => null),
    );
  }

  List<AppNotification> _parse(Object? body) {
    return ApiJson.maps(
          body,
        )
        .map(AppNotification.tryParse)
        .whereType<AppNotification>()
        .toList(
          growable: false,
        );
  }

  static final _demo = [
    AppNotification(
      id: 'demo-n1',
      title: 'Order confirmed',
      body: 'Your order has been confirmed by the supplier.',
      createdAt: DateTime.now(),
    ),
    AppNotification(
      id: 'demo-n2',
      title: 'Welcome to OutMed',
      body: 'Browse verified suppliers and order medical supplies.',
      read: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}
