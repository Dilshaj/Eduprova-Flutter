import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../repository/messages_repository.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return .new();
});

class ConversationsNotifier extends AsyncNotifier<List<ConversationModel>> {
  @override
  FutureOr<List<ConversationModel>> build() {
    return ref.read(messagesRepositoryProvider).getConversations();
  }

  Future<void> loadConversations() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(messagesRepositoryProvider).getConversations(),
    );
  }
}

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<ConversationModel>>(
      ConversationsNotifier.new,
    );

// Fallback to FutureProvider for fetching messages by ID
final messagesFetcherProvider =
    FutureProvider.family<List<MessageModel>, String>((ref, id) {
      return ref.read(messagesRepositoryProvider).getMessages(id);
    });

// Complementary Notifier to handle local updates/sending
class LocalMessagesNotifier extends Notifier<Map<String, List<MessageModel>>> {
  @override
  Map<String, List<MessageModel>> build() => {};

  void addMessage(String conversationId, MessageModel message) {
    var current = state[conversationId] ?? [];
    if (current.any((m) => m.id == message.id)) return;

    state = {
      ...state,
      conversationId: [message, ...current],
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
