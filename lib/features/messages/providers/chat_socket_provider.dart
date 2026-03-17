import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../core/network/api_client.dart';
import '../../../globals.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/message_model.dart';
import 'messages_provider.dart';

class ChatSocketNotifier extends Notifier<bool> {
  io.Socket? _socket;
  Timer? _heartbeatTimer;

  @override
  bool build() {
    ref.onDispose(() {
      close();
    });
    return false;
  }

  void init() {
    if (_socket != null) return;

    final auth = ref.read(authProvider);
    final token = prefs.getString('access_token');
    final userId = auth.user?.id;

    if (token == null || userId == null) return;

    final baseUrl = ApiClient.baseUrl;

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['polling', 'websocket'])
          .setAuth({'token': token})
          .setQuery({'userId': userId})
          .enableAutoConnect()
          .setReconnectionDelay(1500)
          .setReconnectionDelayMax(10000)
          .setReconnectionAttempts(10)
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[ChatSocket] Connected: ${_socket!.id}');
      state = true;
      _startHeartbeat();
    });

    _socket!.onDisconnect((reason) {
      debugPrint('[ChatSocket] Disconnected: $reason');
      state = false;
      _stopHeartbeat();
    });

    _socket!.onConnectError((err) {
      debugPrint('[ChatSocket] Connection Error: $err');
    });

    // Listen for new messages
    _socket!.on('new-message', (data) {
      debugPrint('[ChatSocket] New message received: $data');
      try {
        final message = MessageModel.fromJson(data);
        // Update local messages provider
        ref
            .read(localMessagesProvider.notifier)
            .addMessage(message.conversationId, message);

        // Also invalidate conversations list to show last message update
        ref.invalidate(conversationsProvider);
      } catch (e) {
        debugPrint('[ChatSocket] Error parsing new message: $e');
      }
    });

    // Listen for presence
    _socket!.on('presence-update', (data) {
      debugPrint('[ChatSocket] Presence update: $data');
    });

    _socket!.connect();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_socket?.connected == true) {
        _socket!.emit('presence:heartbeat');
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void joinConversation(String conversationId) {
    if (_socket?.connected == true) {
      _socket!.emit('join-conversation', {'conversationId': conversationId});
    }
  }

  void leaveConversation(String conversationId) {
    if (_socket?.connected == true) {
      _socket!.emit('leave-conversation', {'conversationId': conversationId});
    }
  }

  void sendMessage(String conversationId, String content, {String? replyTo}) {
    if (_socket?.connected == true) {
      _socket!.emit('send-message', {
        'conversationId': conversationId,
        'content': content,
        if (replyTo != null) 'replyTo': replyTo,
      });
    }
  }

  void close() {
    _stopHeartbeat();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    state = false;
  }
}

final chatSocketProvider = NotifierProvider<ChatSocketNotifier, bool>(
  ChatSocketNotifier.new,
);
