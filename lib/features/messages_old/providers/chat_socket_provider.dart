import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../core/network/api_client.dart';
import '../../../globals.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/call_room_model.dart';
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
  final IncomingCallModel? incomingCall;

  const ChatSocketState({
    this.isConnected = false,
    this.presence = const {},
    this.typing = const {},
    this.incomingCall,
  });

  ChatSocketState copyWith({
    bool? isConnected,
    Map<String, PresenceInfo>? presence,
    Map<String, TypingState>? typing,
    IncomingCallModel? incomingCall,
    bool clearIncomingCall = false,
  }) => ChatSocketState(
    isConnected: isConnected ?? this.isConnected,
    presence: presence ?? this.presence,
    typing: typing ?? this.typing,
    incomingCall: clearIncomingCall
        ? null
        : (incomingCall ?? this.incomingCall),
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
typedef MeetingEventCallback =
    void Function(String event, Map<String, dynamic> data);
typedef ConversationEventCallback =
    void Function(Map<String, dynamic> conversation);

// ─── Notifier ─────────────────────────────────────────────────────────────

class ChatSocketNotifier extends Notifier<ChatSocketState> {
  io.Socket? _socket;
  Timer? _heartbeatTimer;
  final Set<String> _activeRooms = {};
  DateTime? _lastConnectAttempt;
  bool _listenersBound = false;
  int _transportStrategyIndex = 0;

  final Map<String, List<NewMessageCallback>> _messageListeners = {};
  final List<NewMessageCallback> _globalMessageListeners = [];
  final Map<String, MessageReactionCallback> _reactionListeners = {};
  final List<MeetingEventCallback> _meetingListeners = [];
  final List<ConversationEventCallback> _conversationListeners = [];

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

  static const List<List<String>> _transportStrategies = [
    ['websocket'],
    ['polling', 'websocket'],
  ];

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
    _connectInternal(baseUrl, effectiveUserId, token);
  }

  void _connectInternal(String baseUrl, String userId, String token) {
    final transports = _transportStrategies[_transportStrategyIndex];
    debugPrint(
      '[ChatSocket] Connecting to $baseUrl (userId=$userId, transports=$transports)',
    );

    final options = io.OptionBuilder()
        .disableAutoConnect()
        .setTransports(transports)
        .setAuth({'token': token})
        .setQuery({'userId': userId})
        .setReconnectionAttempts(10)
        .setReconnectionDelay(1500)
        .setTimeout(20000)
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .enableReconnection()
        .enableForceNew()
        .build();

    _socket = io.io(baseUrl, options);

    _bindSocketListeners();

    _socket!.onConnect((_) {
      debugPrint(
        '[ChatSocket] Connected to server: ${ApiClient.baseUrl} via $transports',
      );
      _transportStrategyIndex = 0;
      state = state.copyWith(isConnected: true);
      _startHeartbeat();
      setPresenceStatus(isAway: false);
      for (final rid in _activeRooms) {
        _socket!.emit('join-conversation', {'conversationId': rid});
      }
    });

    _socket!.onDisconnect((_) {
      debugPrint('[ChatSocket] Disconnected from server');
      state = state.copyWith(isConnected: false);
      _stopHeartbeat();
    });

    _socket!.onConnectError((data) {
      debugPrint('[ChatSocket] Connection Error: $data');
      state = state.copyWith(isConnected: false);
      _tryNextTransport(baseUrl, userId, token, source: 'connect_error');
    });

    _socket!.onError((data) {
      debugPrint('[ChatSocket] Socket Error: $data');
      _tryNextTransport(baseUrl, userId, token, source: 'socket_error');
    });

    _socket!.on('reconnect_attempt', (data) {
      debugPrint('[ChatSocket] Reconnect attempt: $data');
    });

    _socket!.connect();
  }

  void _tryNextTransport(
    String baseUrl,
    String userId,
    String token, {
    required String source,
  }) {
    if (_socket?.connected == true) return;
    if (_transportStrategyIndex >= _transportStrategies.length - 1) {
      if (baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1')) {
        debugPrint(
          '[ChatSocket] All transport strategies failed for $baseUrl. '
          'If this is a physical device, set the Dev API URL to your computer LAN IP.',
        );
      }
      return;
    }

    _transportStrategyIndex += 1;
    debugPrint(
      '[ChatSocket] Retrying with fallback transport after $source: '
      '${_transportStrategies[_transportStrategyIndex]}',
    );

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _listenersBound = false;

    Future.microtask(() => _connectInternal(baseUrl, userId, token));
  }

  void _bindSocketListeners() {
    if (_socket == null || _listenersBound) return;
    _listenersBound = true;

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

    _socket!.on('call:incoming', (data) {
      if (data is! Map) return;
      final call = IncomingCallModel.fromJson(Map<String, dynamic>.from(data));
      state = state.copyWith(incomingCall: call);
    });

    for (final event in const [
      'meeting:scheduled',
      'meeting:updated',
      'meeting:started',
      'meeting:cancelled',
    ]) {
      _socket!.on(event, (data) {
        if (data is! Map) return;
        final parsed = Map<String, dynamic>.from(data);
        for (final cb in List<MeetingEventCallback>.from(_meetingListeners)) {
          cb(event, parsed);
        }
      });
    }

    for (final event in const ['conversation:updated', 'conversation:joined']) {
      _socket!.on(event, (data) {
        if (data is! Map) return;
        final parsed = Map<String, dynamic>.from(data);
        for (final cb in List<ConversationEventCallback>.from(
          _conversationListeners,
        )) {
          cb(parsed);
        }
      });
    }
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
    _listenersBound = false;
    // Do not update state here as this is often called during disposal or inside build()
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
    List<dynamic>? attachments,
    String? type,
  }) {
    if (_socket?.connected != true) {
      debugPrint('[ChatSocket] Not connected — cannot send');
      return;
    }
    final messageData = {
      'conversationId': conversationId,
      'content': content,
      'type': type ?? 'text',
      'attachments': attachments ?? [],
      'replyTo': replyTo ?? replyToMessage?['_id'] ?? replyToMessage?['id'],
    };

    debugPrint('[ChatSocket] Sending message: $messageData');

    _socket?.emitWithAck(
      'send-message',
      messageData,
      ack: (data) {
        if (data != null && data['error'] != null) {
          debugPrint('[ChatSocket] Error sending message: ${data['error']}');
        } else {
          debugPrint('[ChatSocket] Message sent successfully');
        }
      },
    );
  }

  Future<void> sendImageMessage({
    required String conversationId,
    required String imageUrl,
    String? replyTo,
  }) async {
    sendMessage(
      conversationId: conversationId,
      content: '', // Images often have empty content unless there's a caption
      type: 'image',
      attachments: [
        {
          'type': 'image',
          'url': imageUrl,
          'storageProvider': 'cloudinary', // Default or from upload result
        },
      ],
      replyTo: replyTo,
    );
  }

  void emitTypingStart(String conversationId) =>
      _socket?.emit('typing-start', {'conversationId': conversationId});

  void emitTypingStop(String conversationId) =>
      _socket?.emit('typing-stop', {'conversationId': conversationId});

  void setPresenceStatus({required bool isAway}) {
    if (_socket?.connected != true) return;
    _socket!.emit('presence:status', {'status': isAway ? 'away' : 'active'});
  }

  void emitCallInvite({
    required List<String> recipientIds,
    required String roomName,
    required String conversationType,
    required String callerName,
    String? callerAvatar,
  }) {
    if (_socket?.connected != true || recipientIds.isEmpty) return;
    _socket!.emit('call:invite', {
      'recipientIds': recipientIds,
      'roomName': roomName,
      'conversationType': conversationType,
      'callerName': callerName,
      'callerAvatar': callerAvatar,
    });
  }

  void emitCallAccepted(IncomingCallModel call) {
    if (_socket?.connected != true) return;
    _socket!.emit('call:accepted', {
      'callerId': call.callerId,
      'roomName': call.roomName,
    });
    clearIncomingCall();
  }

  void emitCallRejected(IncomingCallModel call) {
    if (_socket?.connected != true) return;
    _socket!.emit('call:rejected', {
      'callerId': call.callerId,
      'roomName': call.roomName,
    });
    clearIncomingCall();
  }

  void setIncomingCall(IncomingCallModel call) {
    state = state.copyWith(incomingCall: call);
  }

  void clearIncomingCall() {
    state = state.copyWith(clearIncomingCall: true);
  }

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

  VoidCallback onMeetingEvent(MeetingEventCallback cb) {
    _meetingListeners.add(cb);
    return () => _meetingListeners.remove(cb);
  }

  VoidCallback onConversationEvent(ConversationEventCallback cb) {
    _conversationListeners.add(cb);
    return () => _conversationListeners.remove(cb);
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
