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
import 'package:outmed/features/messages/data/chat_socket.dart';
import 'package:outmed/features/messages/data/models/chat_message.dart';
import 'package:outmed/features/messages/data/models/chat_realtime_event.dart';
import 'package:outmed/features/messages/data/models/chat_thread.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_event.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this._dio, this._cache, this._queue, this._tokens, this._socket)
    : super(const ChatState()) {
    on<ChatStarted>(_onStarted);
    on<ChatFilterChanged>(
      (event, emit) => emit(state.copyWith(filter: event.filter)),
    );
    on<ChatSearchChanged>(
      (event, emit) => emit(state.copyWith(query: event.query)),
    );
    on<ChatThreadOpened>(_onOpened);
    on<ChatNotificationOpened>(_onNotificationOpened);
    on<ChatMessageSent>(_onSent);
    on<ChatTypingChanged>(_onTyping);
    on<ChatRealtimeReceived>(_onRealtime);
    on<ChatReset>(_onReset);
    _socketSub = _socket.events.listen((event) {
      if (!isClosed) add(ChatRealtimeReceived(event));
    });
  }

  static const _messagesQuery = {'page': 1, 'limit': 30};

  final Dio _dio;
  final RemoteCache _cache;
  final OfflineQueue _queue;
  final TokenStore _tokens;
  final ChatSocket _socket;
  StreamSubscription<ChatRealtimeEvent>? _socketSub;
  Timer? _typing;
  var _announcedTyping = false;

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
    _socket.connect(_tokens.accessToken ?? '');
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
    _joinAll(cached);
    try {
      final body = await _cache.get(ApiEndpoints.conversations);
      final threads = _threads(body);
      emit(
        state.copyWith(threads: threads, threadsStatus: LoadStatus.success),
      );
      _joinAll(threads);
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
      unawaited(_socket.join(thread.id));
      unawaited(_socket.markRead(thread.id));
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

  Future<void> _onNotificationOpened(
    ChatNotificationOpened event,
    Emitter<ChatState> emit,
  ) async {
    final lookup = event.lookup;
    emit(
      ChatState(
        threads: state.threads,
        threadsStatus: state.threadsStatus,
        filter: state.filter,
        query: state.query,
        active: ChatThread(
          id: lookup.conversationId,
          title: lookup.senderName,
          participantUserId: lookup.senderId,
        ),
        messagesStatus: LoadStatus.loading,
      ),
    );
    var threads = state.threads;
    if (AppEnv.useRemote) {
      try {
        threads = _threads(await _cache.get(ApiEndpoints.conversations));
        emit(
          state.copyWith(threads: threads, threadsStatus: LoadStatus.success),
        );
        _joinAll(threads);
      } on Object catch (_) {
        threads = state.threads.isNotEmpty
            ? state.threads
            : _threads(_cache.peek(ApiEndpoints.conversations));
      }
    } else if (threads.isEmpty) {
      threads = _demoThreads;
      emit(
        state.copyWith(threads: threads, threadsStatus: LoadStatus.success),
      );
    }
    final found = lookup.match(threads);
    final ChatThread target;
    if (found != null) {
      target = found.title.isEmpty || found.title == 'OutMed'
          ? found.copyWith(
              title: lookup.senderName.isEmpty ? null : lookup.senderName,
            )
          : found;
    } else if (lookup.conversationId.isNotEmpty || lookup.senderId.isNotEmpty) {
      target = ChatThread(
        id: lookup.conversationId,
        title: lookup.senderName,
        participantUserId: lookup.senderId,
      );
    } else {
      emit(
        state.copyWith(
          messagesStatus: LoadStatus.failure,
          errorMessage: AppLocale.translate('chat_unavailable'),
        ),
      );
      return;
    }
    await _onOpened(ChatThreadOpened(target), emit);
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
    _socket.typing(conversationId: thread.id, isTyping: false);
    try {
      final json = await _deliver(thread.id, text);
      final saved = json == null
          ? null
          : ChatMessage.tryParse(json, _tokens.userId);
      emit(
        state.copyWith(
          sending: false,
          peerRead: false,
          messages: saved == null
              ? null
              : _mergeMessage(
                  ChatMessage(
                    id: saved.id,
                    content: saved.content,
                    mine: true,
                    sentAt: saved.sentAt,
                  ),
                  pendingId: local.id,
                ),
          threads: _touchThread(thread.id, preview: text, unread: 0),
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

  Future<void> _onTyping(
    ChatTypingChanged event,
    Emitter<ChatState> emit,
  ) async {
    final id = state.active?.id ?? '';
    if (id.isEmpty) return;
    _typing?.cancel();
    if (event.isTyping) {
      if (!_announcedTyping) {
        _announcedTyping = true;
        _socket.typing(conversationId: id, isTyping: true);
      }
      _typing = Timer(const Duration(seconds: 2), () {
        _announcedTyping = false;
        _socket.typing(conversationId: id, isTyping: false);
      });
      return;
    }
    _announcedTyping = false;
    _socket.typing(conversationId: id, isTyping: false);
  }

  Future<void> _onRealtime(
    ChatRealtimeReceived event,
    Emitter<ChatState> emit,
  ) async {
    final payload = event.event;
    switch (payload) {
      case ChatRealtimeConnected():
      case ChatRealtimeDisconnected():
        return;
      case ChatRealtimeNewMessage(:final json, :final conversationId):
        final message = ChatMessage.tryParse(json, _tokens.userId);
        if (message == null || conversationId.isEmpty) return;
        final active = state.active?.id == conversationId;
        emit(
          state.copyWith(
            messages: active ? _mergeMessage(message) : null,
            peerTyping: active ? false : null,
            peerRead: active && message.mine ? false : null,
            threads: _touchThread(
              conversationId,
              preview: message.content,
              unread: active || message.mine
                  ? 0
                  : _unreadOf(conversationId) + 1,
            ),
          ),
        );
        if (active && !message.mine) {
          unawaited(_socket.markRead(conversationId));
        }
      case ChatRealtimeTyping(
        :final conversationId,
        :final userId,
        :final isTyping,
      ):
        if (state.active?.id != conversationId) return;
        if (userId.isNotEmpty && userId == _tokens.userId) return;
        emit(state.copyWith(peerTyping: isTyping));
      case ChatRealtimeRead(:final conversationId, :final userId):
        if (state.active?.id != conversationId) return;
        if (userId.isNotEmpty && userId == _tokens.userId) return;
        emit(state.copyWith(peerRead: true));
    }
  }

  void _onReset(ChatReset event, Emitter<ChatState> emit) {
    _typing?.cancel();
    _socket.disconnect();
    emit(const ChatState());
  }

  Future<Map<String, Object?>?> _deliver(
    String conversationId,
    String text,
  ) async {
    if (_socket.connected) {
      try {
        return await _socket.sendMessage(
          conversationId: conversationId,
          content: text,
        );
      } on Object catch (_) {}
    }
    final body = await _queue.send(
      'POST',
      ApiEndpoints.chatMessages,
      body: {'conversationId': conversationId, 'content': text},
    );
    return ApiJson.asMap(ApiJson.unwrap(body));
  }

  void _joinAll(List<ChatThread> threads) {
    for (final thread in threads) {
      unawaited(_socket.join(thread.id));
    }
  }

  int _unreadOf(String conversationId) {
    for (final thread in state.threads) {
      if (thread.id == conversationId) return thread.unread;
    }
    return 0;
  }

  List<ChatMessage> _mergeMessage(ChatMessage incoming, {String? pendingId}) {
    if (state.messages.any((message) => message.id == incoming.id)) {
      return state.messages;
    }
    final pendingIndex = state.messages.indexWhere(
      (message) =>
          message.pending &&
          (pendingId == null
              ? message.content == incoming.content
              : message.id == pendingId),
    );
    if (pendingIndex >= 0) {
      return [
        for (var i = 0; i < state.messages.length; i++)
          i == pendingIndex ? incoming : state.messages[i],
      ];
    }
    return [...state.messages, incoming];
  }

  List<ChatThread> _touchThread(
    String conversationId, {
    required String preview,
    required int unread,
  }) {
    final now = DateTime.now();
    final exists = state.threads.any((thread) => thread.id == conversationId);
    if (!exists) {
      _refreshThreads();
      return [
        ChatThread(
          id: conversationId,
          title: preview,
          preview: preview,
          updatedAt: now,
          unread: unread,
        ),
        ...state.threads,
      ];
    }
    final next =
        [
          for (final thread in state.threads)
            thread.id == conversationId
                ? thread.copyWith(
                    preview: preview,
                    updatedAt: now,
                    unread: unread,
                  )
                : thread,
        ]..sort((left, right) {
          final a = left.updatedAt ?? DateTime(2000);
          final b = right.updatedAt ?? DateTime(2000);
          return b.compareTo(a);
        });
    return next;
  }

  void _refreshThreads() {
    if (AppEnv.useRemote && !isClosed) add(const ChatStarted());
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

  @override
  Future<void> close() {
    _typing?.cancel();
    unawaited(_socketSub?.cancel());
    _socket.disconnect();
    return super.close();
  }
}
