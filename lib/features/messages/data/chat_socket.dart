import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:outmed/core/config/app_env.dart';
import 'package:outmed/core/logger/app_logger.dart';
import 'package:outmed/core/network/api_json.dart';
import 'package:outmed/features/messages/data/models/chat_realtime_event.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatSocket {
  ChatSocket();

  final _events = StreamController<ChatRealtimeEvent>.broadcast();
  final _rooms = <String>{};
  io.Socket? _socket;
  String _token = '';
  var _connecting = false;

  Stream<ChatRealtimeEvent> get events => _events.stream;

  bool get connected => _socket?.connected ?? false;

  void connect(String token) {
    if (!AppEnv.useRemote || token.isEmpty) return;
    if (_token == token && (connected || _connecting)) return;
    _token = token;
    _connecting = true;
    _destroy();
    final socket = io.io(
      '${AppEnv.apiBaseUrl}/chat',
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setPath('/socket.io')
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setAckTimeout(8000)
          .enableForceNew()
          .enableReconnection()
          .disableAutoConnect()
          .build(),
    );
    _socket = socket
      ..onConnect((_) {
        _connecting = false;
        AppLogger.log('ChatSocket: connected');
        _emit(const ChatRealtimeConnected());
        for (final id in [..._rooms]) {
          unawaited(_emitJoin(id));
        }
      })
      ..onDisconnect((_) {
        _connecting = false;
        AppLogger.log('ChatSocket: disconnected');
        _emit(const ChatRealtimeDisconnected());
      })
      ..onConnectError((error) {
        _connecting = false;
        AppLogger.log('ChatSocket: connect error $error');
      })
      ..onError((error) {
        AppLogger.log('ChatSocket: error $error');
      })
      ..on('newMessage', (data) => _on('newMessage', data))
      ..on('userTyping', (data) => _on('userTyping', data))
      ..on('messagesRead', (data) => _on('messagesRead', data))
      ..connect();
  }

  Future<void> join(String conversationId) async {
    if (conversationId.isEmpty) return;
    _rooms.add(conversationId);
    if (!connected) return;
    await _emitJoin(conversationId);
  }

  Future<void> leave(String conversationId) async {
    if (conversationId.isEmpty) return;
    _rooms.remove(conversationId);
    if (!connected) return;
    try {
      await _ack('leaveConversation', {'conversationId': conversationId});
    } on Object catch (error) {
      AppLogger.log('ChatSocket: leave failed $error');
    }
  }

  Future<Map<String, Object?>?> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final ack = await _ack('sendMessage', {
      'conversationId': conversationId,
      'content': content,
    });
    return ApiJson.asMap(ack['data']) ?? ack;
  }

  void typing({required String conversationId, required bool isTyping}) {
    if (!connected || conversationId.isEmpty) return;
    _socket?.emit('typing', {
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
  }

  Future<void> markRead(String conversationId) async {
    if (conversationId.isEmpty || !connected) return;
    try {
      await _ack('markAsRead', {'conversationId': conversationId});
    } on Object catch (error) {
      AppLogger.log('ChatSocket: mark read failed $error');
    }
  }

  void disconnect() {
    _rooms.clear();
    _token = '';
    _connecting = false;
    _destroy();
  }

  Future<void> _emitJoin(String conversationId) async {
    try {
      await _ack('joinConversation', {'conversationId': conversationId});
      AppLogger.log('ChatSocket: joined $conversationId');
    } on Object catch (error) {
      AppLogger.log('ChatSocket: join failed $error');
    }
  }

  void _destroy() {
    final socket = _socket;
    _socket = null;
    if (socket == null) return;
    try {
      socket.clearListeners();
    } on Object catch (_) {}
    try {
      socket.disconnect();
    } on Object catch (error) {
      AppLogger.log('ChatSocket: destroy $error');
    }
    try {
      socket.dispose();
    } on Object catch (_) {}
  }

  void _on(String event, Object? data) {
    if (kDebugMode) {
      AppLogger.log('ChatSocket: $event');
    }
    final parsed = ChatRealtimeEvent.tryParse(event, data);
    if (parsed != null) _emit(parsed);
  }

  void _emit(ChatRealtimeEvent event) {
    if (_events.isClosed) return;
    _events.add(event);
  }

  Future<Map<String, Object?>> _ack(
    String event,
    Map<String, Object?> data,
  ) async {
    final socket = _socket;
    if (socket == null || !socket.connected) {
      throw StateError('Chat socket is not connected');
    }
    final raw = await socket.emitWithAckAsync(event, data);
    final map = ChatRealtimeEvent.mapOf(raw) ?? const <String, Object?>{};
    final error = map['error'];
    if (error != null) throw StateError('$error');
    if (map['success'] == false) {
      throw StateError('$event failed');
    }
    return map;
  }
}
