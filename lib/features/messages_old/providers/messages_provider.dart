import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../globals.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../providers/chat_socket_provider.dart';
import '../repository/messages_repository.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepository();
});

final activeConversationProvider =
    NotifierProvider<ActiveConversationNotifier, Set<String>>(
      ActiveConversationNotifier.new,
    );

class ActiveConversationNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void open(String conversationId) {
    state = {...state, conversationId};
  }

  void close(String conversationId) {
    final next = {...state};
    next.remove(conversationId);
    state = next;
  }
}

final favoriteConversationIdsProvider =
    NotifierProvider<FavoriteConversationIdsNotifier, Set<String>>(
      FavoriteConversationIdsNotifier.new,
    );

class FavoriteConversationIdsNotifier extends Notifier<Set<String>> {
  static const _prefsKey = 'favorite_conversation_ids';

  @override
  Set<String> build() {
    final raw = prefs.getStringList(_prefsKey) ?? const [];
    return raw.toSet();
  }

  Future<void> toggle(String conversationId) async {
    final next = {...state};
    if (!next.add(conversationId)) {
      next.remove(conversationId);
    }
    state = next;
    await prefs.setStringList(_prefsKey, next.toList()..sort());
  }

  bool isFavorite(String conversationId) => state.contains(conversationId);
}

// ─── Conversations ────────────────────────────────────────────────────────

class ConversationsNotifier extends AsyncNotifier<List<ConversationModel>> {
  final MessagesRepository _repository = MessagesRepository();

  @override
  FutureOr<List<ConversationModel>> build() {
    ref.onDispose(() {
      _socketDispose?.call();
      _conversationSocketDispose?.call();
    });

    // Listen for real-time message updates to update last message in list
    Future.microtask(() {
      _socketDispose = ref.read(chatSocketProvider.notifier).onGlobalMessage((
        msg,
      ) {
        final currentUserId = ref.read(authProvider).user?.id ?? '';
        final isActive = ref
            .read(activeConversationProvider)
            .contains(msg.conversationId);
        final current = state.value ?? const [];
        final exists = current.any((conv) => conv.id == msg.conversationId);
        if (exists) {
          updateLastMessage(
            msg.conversationId,
            msg,
            currentUserId: currentUserId,
            incrementUnread: msg.senderId != currentUserId && !isActive,
          );
          if (msg.senderId != currentUserId && isActive) {
            unawaited(_repository.markAsRead(msg.conversationId));
          }
        } else {
          unawaited(
            _insertConversationIfNeeded(
              msg.conversationId,
              message: msg,
              currentUserId: currentUserId,
              incrementUnread: msg.senderId != currentUserId && !isActive,
            ),
          );
        }
      });

      _conversationSocketDispose = ref
          .read(chatSocketProvider.notifier)
          .onConversationEvent((conversation) {
            addOrUpdateConversation(ConversationModel.fromJson(conversation));
          });
    });

    return _repository.getConversations();
  }

  VoidCallback? _socketDispose;
  VoidCallback? _conversationSocketDispose;

  Future<void> loadConversations() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getConversations());
  }

  Future<void> _insertConversationIfNeeded(
    String conversationId, {
    MessageModel? message,
    String? currentUserId,
    bool incrementUnread = false,
  }) async {
    final current = state.value ?? const [];
    if (current.any((conv) => conv.id == conversationId)) return;

    var conversation = await _repository.getConversationById(conversationId);
    if (conversation == null) return;
    if (message != null) {
      conversation = _updateConversationMessageState(
        conversation,
        message,
        currentUserId: currentUserId,
        incrementUnread: incrementUnread,
      );
    }
    addOrUpdateConversation(conversation);
  }

  void updateLastMessage(
    String conversationId,
    MessageModel message, {
    String? currentUserId,
    bool incrementUnread = false,
  }) {
    final current = state.value;
    if (current == null) return;

    final updated = [
      for (final conv in current)
        if (conv.id == conversationId)
          _updateConversationMessageState(
            conv,
            message,
            currentUserId: currentUserId,
            incrementUnread: incrementUnread,
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

  ConversationModel? getConversation(String conversationId) {
    final current = state.value;
    if (current == null) return null;
    for (final conversation in current) {
      if (conversation.id == conversationId) return conversation;
    }
    return null;
  }

  void addOrUpdateConversation(ConversationModel conversation) {
    final current = [...(state.value ?? const <ConversationModel>[])];
    final index = current.indexWhere((item) => item.id == conversation.id);
    if (index >= 0) {
      current[index] = conversation;
      final moved = current.removeAt(index);
      current.insert(0, moved);
    } else {
      current.insert(0, conversation);
    }
    state = AsyncValue.data(current);
  }

  void markConversationRead(String conversationId, String currentUserId) {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data([
      for (final conv in current)
        if (conv.id == conversationId)
          conv.withUnreadCount(currentUserId, 0)
        else
          conv,
    ]);
  }

  ConversationModel _updateConversationMessageState(
    ConversationModel conversation,
    MessageModel message, {
    String? currentUserId,
    required bool incrementUnread,
  }) {
    var updated = conversation.copyWith(
      lastMessage: {
        'id': message.id,
        'content': message.content,
        'type': message.type.toJson(),
        'createdAt': message.createdAt.toIso8601String(),
        'senderId': message.senderId,
        if (message.attachments.isNotEmpty)
          'attachments': [
            for (final attachment in message.attachments) attachment.toJson(),
          ],
      },
      updatedAt: message.createdAt,
    );

    if (incrementUnread &&
        currentUserId != null &&
        currentUserId.isNotEmpty &&
        updated.participants.any((p) => p.userId == currentUserId)) {
      final currentUnread = updated.unreadCountFor(currentUserId);
      updated = updated.withUnreadCount(currentUserId, currentUnread + 1);
    }

    return updated;
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
      return repo.getMessages(conversationId, order: 'desc');
    });

// ─── Local messages (real-time additions) ────────────────────────────────

class LocalMessagesNotifier extends Notifier<Map<String, List<MessageModel>>> {
  @override
  Map<String, List<MessageModel>> build() => {};

  /// Seed messages from the initial API fetch (oldest first, for correct display)
  void seedMessages(String conversationId, List<MessageModel> messages) {
    final current = state[conversationId] ?? const <MessageModel>[];
    final merged = <String, MessageModel>{};

    for (final message in current) {
      merged[message.id] = message;
    }
    for (final message in messages) {
      merged[message.id] = message;
    }

    final sorted = merged.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    state = {...state, conversationId: sorted};
  }

  /// Add a new incoming/sent message to the END of the list (newest at bottom)
  void addMessage(String conversationId, MessageModel message) {
    final current = state[conversationId] ?? [];
    if (current.any((m) => m.id == message.id)) return; // deduplicate

    state = {
      ...state,
      conversationId: [message, ...current], // newest at index 0
    };
  }

  /// Remove a message (e.g., temporary optimistic message)
  void removeMessage(String conversationId, String messageId) {
    final current = state[conversationId];
    if (current == null) return;

    state = {
      ...state,
      conversationId: current.where((m) => m.id != messageId).toList(),
    };
  }

  /// Replace a message
  void replaceMessage(
    String conversationId,
    String oldMessageId,
    MessageModel newMessage,
  ) {
    final current = state[conversationId];
    if (current == null) return;

    if (current.any((m) => m.id == newMessage.id && m.id != oldMessageId)) {
      state = {
        ...state,
        conversationId: current.where((m) => m.id != oldMessageId).toList(),
      };
      return;
    }

    state = {
      ...state,
      conversationId: current
          .map((m) => m.id == oldMessageId ? newMessage : m)
          .toList(),
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

  /// Clear all messages for a specific conversation locally
  void clearMessages(String conversationId) {
    state = {...state, conversationId: []};
  }

  Future<void> sendMessage(
    String conversationId,
    String content, {
    String? replyTo,
  }) async {
    final message = await ref
        .read(messagesRepositoryProvider)
        .sendMessage(
          conversationId: conversationId,
          content: content,
          replyTo: replyTo,
        );
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
