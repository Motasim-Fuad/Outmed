import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/l10n/app_locale.dart';
import 'package:outmed/core/network/api_endpoints.dart';
import 'package:outmed/core/network/api_error.dart';
import 'package:outmed/core/network/api_json.dart';
import 'package:outmed/core/network/offline_queue.dart';
import 'package:outmed/core/network/remote_cache.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/core/storage/token_store.dart';
import 'package:outmed/features/messages/data/models/chat_message.dart';
import 'package:outmed/features/messages/data/models/chat_thread.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_event.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this._dio, this._cache, this._queue, this._tokens)
    : super(const ChatState()) {
    on<ChatStarted>(_onStarted);
    on<ChatFilterChanged>(
      (event, emit) => emit(state.copyWith(filter: event.filter)),
    );
    on<ChatSearchChanged>(
      (event, emit) => emit(state.copyWith(query: event.query)),
    );
    on<ChatThreadOpened>(_onOpened);
    on<ChatMessageSent>(_onSent);
    on<ChatReset>((event, emit) => emit(const ChatState()));
  }

  static const _messagesQuery = {'page': 1, 'limit': 30};

  final Dio _dio;
  final RemoteCache _cache;
  final OfflineQueue _queue;
  final TokenStore _tokens;

  Future<void> _onStarted(ChatStarted event, Emitter<ChatState> emit) async {
    if (!AppEnv.useRemote) {
      emit(
        state.copyWith(
          threads: _demoThreads,
          threadsStatus: LoadStatus.success,
        ),
      );
      return;
    }
    final cached = _threads(_cache.peek(ApiEndpoints.conversations));
    emit(
      state.copyWith(
        threads: cached.isEmpty ? null : cached,
        threadsStatus: cached.isEmpty && state.threads.isEmpty
            ? LoadStatus.loading
            : LoadStatus.success,
        errorMessage: '',
      ),
    );
    try {
      final body = await _cache.get(ApiEndpoints.conversations);
      emit(
        state.copyWith(
          threads: _threads(body),
          threadsStatus: LoadStatus.success,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          threadsStatus: LoadStatus.failure,
          errorMessage: ApiError.message(error),
        ),
      );
    }
  }

  Future<void> _onOpened(
    ChatThreadOpened event,
    Emitter<ChatState> emit,
  ) async {
    var thread = event.thread;
    emit(
      ChatState(
        threads: state.threads,
        threadsStatus: state.threadsStatus,
        filter: state.filter,
        query: state.query,
        active: thread,
        messagesStatus: LoadStatus.loading,
      ),
    );
    if (!AppEnv.useRemote) {
      emit(
        state.copyWith(
          active: thread.id.isEmpty
              ? thread.copyWith(id: 'demo-${thread.title}')
              : null,
          messages: _demoMessages(thread.title),
          messagesStatus: LoadStatus.success,
        ),
      );
      return;
    }
    try {
      if (thread.id.isEmpty) {
        thread = await _startConversation(thread);
        final known = state.threads.any((item) => item.id == thread.id);
        emit(
          state.copyWith(
            active: thread,
            threads: known ? null : [thread, ...state.threads],
          ),
        );
      }
      final path = ApiEndpoints.conversationMessages(thread.id);
      final cached = _messages(_cache.peek(path, query: _messagesQuery));
      if (cached.isNotEmpty) {
        emit(
          state.copyWith(messages: cached, messagesStatus: LoadStatus.success),
        );
      }
      final body = await _cache.get(path, query: _messagesQuery);
      emit(
        state.copyWith(
          messages: _messages(body),
          messagesStatus: LoadStatus.success,
          threads: [
            for (final item in state.threads)
              item.id == thread.id ? item.copyWith(unread: 0) : item,
          ],
        ),
      );
      if (thread.unread > 0) {
        unawaited(
          _queue
              .send('PATCH', ApiEndpoints.conversationRead(thread.id))
              .catchError((Object _) => null),
        );
      }
    } on Object catch (error) {
      emit(
        state.copyWith(
          messagesStatus: LoadStatus.failure,
          errorMessage: ApiError.message(error),
        ),
      );
    }
  }

  Future<ChatThread> _startConversation(ChatThread thread) async {
    if (thread.participantUserId.isEmpty) {
      throw StateError(AppLocale.translate('chat_unavailable'));
    }
    final response = await _dio.post<dynamic>(
      ApiEndpoints.conversations,
      data: {
        'participantUserId': thread.participantUserId,
        if (thread.orderId.isNotEmpty) 'orderId': thread.orderId,
      },
    );
    final json = ApiJson.asMap(ApiJson.unwrap(response.data));
    final id = json == null ? null : ApiJson.text(json, const ['id']);
    if (id == null) throw StateError(AppLocale.translate('request_failed'));
    final existing = state.threads.where((item) => item.id == id);
    if (existing.isNotEmpty) return existing.first;
    return thread.copyWith(id: id);
  }

  Future<void> _onSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    final text = event.text.trim();
    final thread = state.active;
    if (text.isEmpty || thread == null) return;
    final local = ChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      content: text,
      mine: true,
      sentAt: DateTime.now(),
      pending: AppEnv.useRemote,
    );
    emit(
      state.copyWith(
        messages: [...state.messages, local],
        sending: true,
        errorMessage: '',
      ),
    );
    if (!AppEnv.useRemote || thread.id.isEmpty) {
      emit(state.copyWith(sending: false));
      return;
    }
    try {
      final body = await _queue.send(
        'POST',
        ApiEndpoints.chatMessages,
        body: {'conversationId': thread.id, 'content': text},
      );
      final json = ApiJson.asMap(ApiJson.unwrap(body));
      final saved = json == null
          ? null
          : ChatMessage.tryParse(json, _tokens.userId);
      emit(
        state.copyWith(
          sending: false,
          messages: saved == null
              ? null
              : [
                  for (final message in state.messages)
                    message.id == local.id
                        ? ChatMessage(
                            id: saved.id,
                            content: saved.content,
                            mine: true,
                            sentAt: saved.sentAt,
                          )
                        : message,
                ],
          threads: [
            for (final item in state.threads)
              item.id == thread.id
                  ? item.copyWith(preview: text, updatedAt: DateTime.now())
                  : item,
          ],
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          sending: false,
          messages: state.messages
              .where((message) => message.id != local.id)
              .toList(growable: false),
          errorMessage: ApiError.message(error),
        ),
      );
    }
  }

  List<ChatThread> _threads(Object? body) {
    final userId = _tokens.userId;
    final threads =
        ApiJson.maps(body)
            .map((json) => ChatThread.tryParse(json, userId))
            .whereType<ChatThread>()
            .toList()
          ..sort((a, b) {
            final left = a.updatedAt ?? DateTime(2000);
            final right = b.updatedAt ?? DateTime(2000);
            return right.compareTo(left);
          });
    return threads;
  }

  List<ChatMessage> _messages(Object? body) {
    final userId = _tokens.userId;
    return ApiJson.maps(body)
        .map((json) => ChatMessage.tryParse(json, userId))
        .whereType<ChatMessage>()
        .toList()
      ..sort((a, b) {
        final left = a.sentAt ?? DateTime(2000);
        final right = b.sentAt ?? DateTime(2000);
        return left.compareTo(right);
      });
  }

  static final _demoThreads = [
    ChatThread(
      id: 'demo-1',
      title: 'HealthCare Supplies',
      preview: 'Can you confirm stock and delivery time?',
      updatedAt: DateTime.now(),
      unread: 2,
    ),
    ChatThread(
      id: 'demo-2',
      title: 'Marsh Medical',
      preview: 'Yes, we can do this!',
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      orderId: 'demo-order',
    ),
  ];

  List<ChatMessage> _demoMessages(String name) => [
    ChatMessage(
      id: 'demo-a',
      content: 'Hello, this is $name. How can we help with your order?',
      mine: false,
    ),
    const ChatMessage(
      id: 'demo-b',
      content: 'Can you confirm stock and delivery time?',
      mine: true,
    ),
    const ChatMessage(
      id: 'demo-c',
      content: 'Yes, we can dispatch the requested quantity.',
      mine: false,
    ),
  ];
}
