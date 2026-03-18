import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../core/network/api_client.dart';
import '../../../globals.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/message_model.dart';

// ─── Presence ──────────────────────────────────────────────────────────────

enum PresenceStatus { online, away, offline }

class PresenceInfo {
  final PresenceStatus status;
  final int? lastSeenMs;

  const PresenceInfo({this.status = PresenceStatus.offline, this.lastSeenMs});
}

// ─── Typing state ─────────────────────────────────────────────────────────

class TypingState {
  final Set<String> typingUserIds;
  const TypingState({this.typingUserIds = const {}});

  TypingState copyWith({Set<String>? typingUserIds}) =>
      TypingState(typingUserIds: typingUserIds ?? this.typingUserIds);
}

// ─── Socket state ─────────────────────────────────────────────────────────

class ChatSocketState {
  final bool isConnected;
  final Map<String, PresenceInfo> presence;
  final Map<String, TypingState> typing;

  const ChatSocketState({
    this.isConnected = false,
    this.presence = const {},
    this.typing = const {},
  });

  ChatSocketState copyWith({
    bool? isConnected,
    Map<String, PresenceInfo>? presence,
    Map<String, TypingState>? typing,
  }) => ChatSocketState(
    isConnected: isConnected ?? this.isConnected,
    presence: presence ?? this.presence,
    typing: typing ?? this.typing,
  );
}

// ─── Callback typedefs ────────────────────────────────────────────────────

typedef NewMessageCallback = void Function(MessageModel message);
typedef MessageReactionCallback =
    void Function(
      String conversationId,
      String messageId,
      List<dynamic> reactions,
    );

// ─── Notifier ─────────────────────────────────────────────────────────────

class ChatSocketNotifier extends Notifier<ChatSocketState> {
  io.Socket? _socket;
  Timer? _heartbeatTimer;
  final Set<String> _activeRooms = {};
  DateTime? _lastConnectAttempt;

  final Map<String, List<NewMessageCallback>> _messageListeners = {};
  final List<NewMessageCallback> _globalMessageListeners = [];
  final Map<String, MessageReactionCallback> _reactionListeners = {};

  @override
  ChatSocketState build() {
    ref.onDispose(_disconnect);

    // Watch auth status to connect/disconnect
    final auth = ref.watch(authProvider);
    if (auth.status == AuthStatus.authenticated && auth.user != null) {
      // Avoid calling connect() multiple times if already connected/connecting
      if (_socket == null || !_socket!.connected) {
        Future.microtask(() => connect(userId: auth.user!.id));
      }
    } else if (auth.status == AuthStatus.unauthenticated) {
      _disconnect();
    }

    return const ChatSocketState();
  }

  // ── Connection ────────────────────────────────────────────────────────────

  void connect({String? userId}) {
    if (_socket != null && _socket!.connected) return;

    final token = prefs.getString('access_token');
    final effectiveUserId = userId ?? prefs.getString('user_id');

    if (token == null || effectiveUserId == null) {
      debugPrint('[ChatSocket] Missing token or userId, cannot connect');
      return;
    }

    // Coalesce connection attempts
    if (_lastConnectAttempt != null &&
        DateTime.now().difference(_lastConnectAttempt!) <
            const Duration(seconds: 2)) {
      return;
    }
    _lastConnectAttempt = DateTime.now();

    final baseUrl = ApiClient.baseUrl;
    debugPrint('[ChatSocket] Connecting to $baseUrl (userId=$effectiveUserId)');

    _socket = io.io(baseUrl, <String, dynamic>{
      'transports': ['polling', 'websocket'],
      'auth': {'token': token},
      'query': {'userId': effectiveUserId},
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 1500,
    });

    _socket!.onConnect((_) {
      debugPrint('[ChatSocket] Connected: ${_socket!.id}');
      state = state.copyWith(isConnected: true);
      _startHeartbeat();

      // Re-join all active rooms
      for (final rid in _activeRooms) {
        _socket!.emit('join-conversation', {'conversationId': rid});
      }
    });

    _socket!.onDisconnect((reason) {
      debugPrint('[ChatSocket] Disconnected: $reason');
      state = state.copyWith(isConnected: false);
      _stopHeartbeat();
    });

    _socket!.onConnectError((err) {
      debugPrint('[ChatSocket] Connect error: $err');
      debugPrint('[ChatSocket] Current baseUrl: $baseUrl');
    });

    _socket!.onError((err) {
      debugPrint('[ChatSocket] Socket error: $err');
    });

    // ── Presence ────────────────────────────────────────────────────────────
    _socket!.on('presence-initial', (data) {
      final list = data is List ? data : <dynamic>[];
      final map = <String, PresenceInfo>{};
      for (final entry in list) {
        if (entry is Map) {
          final uid = entry['userId']?.toString();
          if (uid == null) continue;
          final s = _parseStatus(entry['status']?.toString());
          final ls = entry['lastSeen'] != null
              ? int.tryParse(entry['lastSeen'].toString())
              : null;
          map[uid] = PresenceInfo(status: s, lastSeenMs: ls);
        } else if (entry is String) {
          map[entry] = const PresenceInfo(status: PresenceStatus.online);
        }
      }
      state = state.copyWith(presence: map);
    });

    _socket!.on('presence-update', (data) {
      if (data is! Map) return;
      final uid = data['userId']?.toString();
      final statusStr = data['status']?.toString();
      if (uid == null) return;

      final updated = Map<String, PresenceInfo>.from(state.presence);
      if (statusStr == 'offline') {
        updated.remove(uid);
      } else {
        final s = _parseStatus(statusStr);
        final ls = data['lastSeen'] != null
            ? int.tryParse(data['lastSeen'].toString())
            : updated[uid]?.lastSeenMs;
        updated[uid] = PresenceInfo(status: s, lastSeenMs: ls);
      }
      state = state.copyWith(presence: updated);
    });

    // ── New message ───────────────────────────────────────────────────────────
    _socket!.on('new-message', (data) {
      if (data is! Map) return;
      try {
        final message = MessageModel.fromJson(data as Map<String, dynamic>);

        // Notify conversation-specific listeners
        final listeners = _messageListeners[message.conversationId] ?? [];
        for (final cb in List<NewMessageCallback>.from(listeners)) {
          cb(message);
        }

        // Notify global listeners
        for (final cb in List<NewMessageCallback>.from(
          _globalMessageListeners,
        )) {
          cb(message);
        }
      } catch (e) {
        debugPrint('[ChatSocket] Error parsing new-message: $e');
      }
    });

    // ── Reactions ─────────────────────────────────────────────────────────────
    _socket!.on('message:reaction', (data) {
      if (data is! Map) return;
      final convId = data['conversationId']?.toString() ?? '';
      final msgId = data['messageId']?.toString() ?? '';
      final reactions = (data['reactions'] as List?) ?? [];
      _reactionListeners[convId]?.call(convId, msgId, reactions);
    });

    // ── Typing ───────────────────────────────────────────────────────────────
    _socket!.on('typing-start', (data) {
      if (data is! Map) return;
      final convId = data['conversationId']?.toString() ?? '';
      final uid = data['userId']?.toString() ?? '';
      _updateTyping(convId, uid, add: true);
    });

    _socket!.on('typing-stop', (data) {
      if (data is! Map) return;
      final convId = data['conversationId']?.toString() ?? '';
      final uid = data['userId']?.toString() ?? '';
      _updateTyping(convId, uid, add: false);
    });

    _socket!.connect();
  }

  void _updateTyping(String convId, String uid, {required bool add}) {
    final updated = Map<String, TypingState>.from(state.typing);
    final cur = updated[convId] ?? const TypingState();
    final newSet = Set<String>.from(cur.typingUserIds);
    if (add) {
      newSet.add(uid);
    } else {
      newSet.remove(uid);
    }
    updated[convId] = cur.copyWith(typingUserIds: newSet);
    state = state.copyWith(typing: updated);
  }

  void _disconnect() {
    _stopHeartbeat();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // ── Heartbeat ─────────────────────────────────────────────────────────────

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_socket?.connected == true) {
        debugPrint('[ChatSocket] Sending presence:heartbeat');
        _socket!.emit('presence:heartbeat');
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  // ── Public emit API ──────────────────────────────────────────────────────

  void joinConversation(String conversationId) {
    _activeRooms.add(conversationId);
    if (_socket?.connected == true) {
      _socket!.emit('join-conversation', {'conversationId': conversationId});
      debugPrint('[ChatSocket] Joined room: $conversationId');
    }
  }

  void leaveConversation(String conversationId) {
    _activeRooms.remove(conversationId);
    _socket?.emit('leave-conversation', {'conversationId': conversationId});
  }

  void sendMessage({
    required String conversationId,
    required String content,
    String? replyTo,
    Map<String, dynamic>? replyToMessage,
    List<String>? attachments,
  }) {
    if (_socket?.connected != true) {
      debugPrint('[ChatSocket] Not connected — cannot send');
      return;
    }
    _socket!.emit('send-message', {
      'conversationId': conversationId,
      'content': content,
      'replyTo': ?replyTo,
      'replyToMessage': ?replyToMessage,
      'attachments': ?attachments,
    });
  }

  void emitTypingStart(String conversationId) =>
      _socket?.emit('typing-start', {'conversationId': conversationId});

  void emitTypingStop(String conversationId) =>
      _socket?.emit('typing-stop', {'conversationId': conversationId});

  // ── Subscription helpers ──────────────────────────────────────────────────

  /// Returns a dispose callback to unsubscribe.
  VoidCallback onNewMessage(String conversationId, NewMessageCallback cb) {
    _messageListeners.putIfAbsent(conversationId, () => []).add(cb);
    return () => _messageListeners[conversationId]?.remove(cb);
  }

  VoidCallback onReaction(String conversationId, MessageReactionCallback cb) {
    _reactionListeners[conversationId] = cb;
    return () => _reactionListeners.remove(conversationId);
  }

  VoidCallback onGlobalMessage(NewMessageCallback cb) {
    _globalMessageListeners.add(cb);
    return () => _globalMessageListeners.remove(cb);
  }

  // ── Query helpers ─────────────────────────────────────────────────────────

  bool isUserOnline(String userId) =>
      state.presence[userId]?.status != PresenceStatus.offline &&
      state.presence.containsKey(userId);

  PresenceInfo getPresence(String userId) =>
      state.presence[userId] ?? const PresenceInfo();

  bool isTyping(String conversationId, String otherUserId) =>
      state.typing[conversationId]?.typingUserIds.contains(otherUserId) ??
      false;

  // ── Helpers ───────────────────────────────────────────────────────────────

  static PresenceStatus _parseStatus(String? s) => switch (s) {
    'online' => PresenceStatus.online,
    'away' => PresenceStatus.away,
    _ => PresenceStatus.offline,
  };
}

final chatSocketProvider =
    NotifierProvider<ChatSocketNotifier, ChatSocketState>(
      ChatSocketNotifier.new,
    );

/// Whether a specific user is online
final isUserOnlineProvider = Provider.family<bool, String>((ref, userId) {
  // Watch presence changes
  ref.watch(chatSocketProvider.select((s) => s.presence.containsKey(userId)));
  return ref.read(chatSocketProvider.notifier).isUserOnline(userId);
});

/// Whether the other user is typing in a conversation
final isTypingProvider = Provider.family<bool, (String, String)>((ref, args) {
  final (conversationId, otherUserId) = args;
  ref.watch(
    chatSocketProvider.select(
      (s) =>
          s.typing[conversationId]?.typingUserIds.contains(otherUserId) ??
          false,
    ),
  );
  return ref
      .read(chatSocketProvider.notifier)
      .isTyping(conversationId, otherUserId);
});
