import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../providers/chat_socket_provider.dart';
import '../repository/messages_repository.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepository();
});

// ─── Conversations ────────────────────────────────────────────────────────

class ConversationsNotifier extends AsyncNotifier<List<ConversationModel>> {
  @override
  FutureOr<List<ConversationModel>> build() {
    ref.onDispose(() => _socketDispose?.call());

    // Listen for real-time message updates to update last message in list
    Future.microtask(() {
      _socketDispose = ref.read(chatSocketProvider.notifier).onGlobalMessage((
        msg,
      ) {
        updateLastMessage(msg.conversationId, msg);
      });
    });

    return ref.read(messagesRepositoryProvider).getConversations();
  }

  VoidCallback? _socketDispose;

  Future<void> loadConversations() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(messagesRepositoryProvider).getConversations(),
    );
  }

  void updateLastMessage(String conversationId, MessageModel message) {
    final current = state.value;
    if (current == null) return;

    final updated = [
      for (final conv in current)
        if (conv.id == conversationId)
          ConversationModel(
            id: conv.id,
            type: conv.type,
            name: conv.name,
            avatar: conv.avatar,
            description: conv.description,
            participants: conv.participants,
            lastMessage: {
              'content': message.content,
              'type': message.type.toJson(),
              'createdAt': message.createdAt.toIso8601String(),
              'senderId': message.senderId,
            },
            createdBy: conv.createdBy,
            communityId: conv.communityId,
            createdAt: conv.createdAt,
            updatedAt: DateTime.now(),
          )
        else
          conv,
    ];
    // Move updated conversation to top
    final idx = updated.indexWhere((c) => c.id == conversationId);
    if (idx > 0) {
      final moved = updated.removeAt(idx);
      updated.insert(0, moved);
    }
    state = AsyncValue.data(updated);
  }
}

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<ConversationModel>>(
      ConversationsNotifier.new,
    );

// ─── Messages (paginated, per conversation) ───────────────────────────────

/// Fetches initial page of messages — newest returned first from API,
/// already returned oldest-to-newest from the backend for display.
final messagesFetcherProvider =
    FutureProvider.family<List<MessageModel>, String>((
      ref,
      conversationId,
    ) async {
      final repo = ref.read(messagesRepositoryProvider);
      return repo.getMessages(conversationId);
    });

// ─── Local messages (real-time additions) ────────────────────────────────

class LocalMessagesNotifier extends Notifier<Map<String, List<MessageModel>>> {
  @override
  Map<String, List<MessageModel>> build() => {};

  /// Seed messages from the initial API fetch (oldest first, for correct display)
  void seedMessages(String conversationId, List<MessageModel> messages) {
    if (state.containsKey(conversationId)) return; // already seeded
    state = {...state, conversationId: List.from(messages)};
  }

  /// Add a new incoming/sent message to the END of the list (newest at bottom)
  void addMessage(String conversationId, MessageModel message) {
    final current = state[conversationId] ?? [];
    if (current.any((m) => m.id == message.id)) return; // deduplicate

    state = {
      ...state,
      conversationId: [...current, message], // append at end
    };
  }

  /// Update reactions on a specific message
  void updateReactions(
    String conversationId,
    String messageId,
    List<dynamic> reactions,
  ) {
    final current = state[conversationId];
    if (current == null) return;

    final parsed = [
      for (final r in reactions)
        if (r is Map<String, dynamic>) MessageReaction.fromJson(r),
    ];

    state = {
      ...state,
      conversationId: [
        for (final m in current)
          if (m.id == messageId) m.copyWith(reactions: parsed) else m,
      ],
    };
  }

  Future<void> sendMessage(String conversationId, String content) async {
    final message = await ref
        .read(messagesRepositoryProvider)
        .sendMessage(conversationId: conversationId, content: content);
    if (message != null) {
      addMessage(conversationId, message);
    }
  }
}

final localMessagesProvider =
    NotifierProvider<LocalMessagesNotifier, Map<String, List<MessageModel>>>(
      LocalMessagesNotifier.new,
    );

/// Combined view: seeded messages + real-time additions
final combinedMessagesProvider = Provider.family<List<MessageModel>, String>((
  ref,
  conversationId,
) {
  final localMap = ref.watch(localMessagesProvider);
  return localMap[conversationId] ?? [];
});
