import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';

// Assuming base URL for sockets based on previous tools
const String socketBaseUrl = "http://localhost:2000/course-chat";

class ChatMessage {
  final int id;
  final String user;
  final String? avatar;
  final String initials;
  final String time;
  final String text;
  final String color;
  final String? userId;

  ChatMessage({
    required this.id,
    required this.user,
    this.avatar,
    required this.initials,
    required this.time,
    required this.text,
    required this.color,
    this.userId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      user: json['user'] ?? 'Unknown',
      avatar: json['avatar'],
      initials: json['initials'] ?? 'U',
      time: json['time'] ?? '',
      text: json['text'] ?? '',
      color: json['color'] ?? 'bg-blue-600',
      userId: json['userId']?.toString(),
    );
  }
}

class MessagesState {
  final List<ChatMessage> messages;
  final bool isConnected;
  final int viewerCount;
  final String? currentUserId;

  MessagesState({
    this.messages = const [],
    this.isConnected = false,
    this.viewerCount = 0,
    this.currentUserId,
  });

  MessagesState copyWith({
    List<ChatMessage>? messages,
    bool? isConnected,
    int? viewerCount,
    String? currentUserId,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isConnected: isConnected ?? this.isConnected,
      viewerCount: viewerCount ?? this.viewerCount,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}

class AllMessagesNotifier extends Notifier<Map<String, MessagesState>> {
  final Map<String, io.Socket> _sockets = {};

  @override
  Map<String, MessagesState> build() {
    ref.onDispose(() {
      for (final socket in _sockets.values) {
        socket.disconnect();
        socket.dispose();
      }
    });

    return {};
  }

  Future<void> initSocket(String courseId) async {
    if (_sockets.containsKey(courseId)) return;

    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'You';
    final userId = prefs.getString('user_id') ?? 'current-user-id';

    final currentUserInfo = {'id': userId, 'name': name};

    final socket = io.io(socketBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _sockets[courseId] = socket;

    // Initialize state
    state = {...state, courseId: MessagesState()};

    socket.onConnect((_) {
      final currentState = state[courseId] ?? MessagesState();
      state = {
        ...state,
        courseId: currentState.copyWith(
          isConnected: true,
          currentUserId: userId,
        ),
      };
      socket.emit('join-course-chat', {
        'courseId': courseId,
        'user': currentUserInfo,
      });
    });

    socket.onDisconnect((_) {
      final currentState = state[courseId] ?? MessagesState();
      state = {
        ...state,
        courseId: currentState.copyWith(isConnected: false, viewerCount: 0),
      };
    });

    socket.on('new-course-message', (data) {
      final message = ChatMessage.fromJson(data);
      final currentState = state[courseId] ?? MessagesState();

      // Prevent duplicates
      if (currentState.messages.any((m) => m.id == message.id)) return;

      state = {
        ...state,
        courseId: currentState.copyWith(
          messages: [...currentState.messages, message],
        ),
      };
    });

    socket.on('viewer-count-updated', (data) {
      final count = data is int ? data : int.tryParse(data.toString()) ?? 0;
      final currentState = state[courseId] ?? MessagesState();

      state = {...state, courseId: currentState.copyWith(viewerCount: count)};
    });

    socket.on('user-joined', (data) {
      // Could potentially show system message that user joined
    });

    socket.connect();
  }

  Future<void> sendMessage(String courseId, String text) async {
    final socket = _sockets[courseId];
    if (socket?.connected == true && text.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name') ?? 'You';
      final userId = prefs.getString('user_id') ?? 'current-user-id';

      final currentUserInfo = {'id': userId, 'name': name};

      socket!.emit('send-course-message', {
        'courseId': courseId,
        'text': text,
        'user': currentUserInfo,
      });
    }
  }

  void leaveCourseChat(String courseId) {
    final socket = _sockets[courseId];
    if (socket != null) {
      socket.emit('leave-course-chat', {'courseId': courseId});
      socket.disconnect();
      socket.dispose();
      _sockets.remove(courseId);

      // Remove from state
      final newState = Map<String, MessagesState>.from(state);
      newState.remove(courseId);
      state = newState;
    }
  }
}

final allMessagesProvider =
    NotifierProvider<AllMessagesNotifier, Map<String, MessagesState>>(
      AllMessagesNotifier.new,
    );

final messagesProvider = Provider.family<MessagesState, String>((
  ref,
  courseId,
) {
  final map = ref.watch(allMessagesProvider);
  if (!map.containsKey(courseId)) {
    // Fire off async initialization once
    Future.microtask(() {
      ref.read(allMessagesProvider.notifier).initSocket(courseId);
    });
    return MessagesState();
  }
  return map[courseId]!;
});
