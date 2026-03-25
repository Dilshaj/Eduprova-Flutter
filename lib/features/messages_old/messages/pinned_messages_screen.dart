import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../providers/messages_provider.dart';

class PinnedMessagesScreen extends ConsumerWidget {
  final ConversationModel conversation;

  const PinnedMessagesScreen({super.key, required this.conversation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final messages = ref.watch(combinedMessagesProvider(conversation.id));
    final pinnedMessages = messages
        .where((m) => conversation.pinnedMessages.contains(m.id))
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.pin, size: 20),
            SizedBox(width: 10),
            Text('Pinned Messages', style: TextStyle(color: cs.onSurface)),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: ActionChip(
          onPressed: () => Navigator.pop(context),
          label: const Icon(LucideIcons.arrowLeft),
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          backgroundColor: Colors.transparent,
          side: BorderSide.none,
        ),
      ),
      body: pinnedMessages.isEmpty
          ? const Center(child: Text('No pinned messages.'))
          : ListView.separated(
              itemCount: pinnedMessages.length,
              padding: const EdgeInsets.all(16),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final msg = pinnedMessages[index];
                return InkWell(
                  onTap: () => Navigator.pop(context, msg.id),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.7),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.dividerColor.withValues(alpha: 0.7),
                          // blurRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildPinnedMessageTile(msg, cs)),
                        IconButton(
                          icon: Icon(
                            LucideIcons.pinOff,
                            size: 18,
                            color: cs.error.withValues(alpha: 0.7),
                          ),
                          onPressed: () => _unpinMessage(context, ref, msg.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _unpinMessage(
    BuildContext context,
    WidgetRef ref,
    String messageId,
  ) async {
    final repo = ref.read(messagesRepositoryProvider);
    final success = await repo.unpinMessage(conversation.id, messageId);

    if (success) {
      // Update global state
      final notifier = ref.read(conversationsProvider.notifier);
      final updatedPinned = conversation.pinnedMessages
          .where((id) => id != messageId)
          .toList();
      notifier.addOrUpdateConversation(
        conversation.copyWith(pinnedMessages: updatedPinned),
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to unpin message')),
        );
      }
    }
  }

  Widget _buildPinnedMessageTile(MessageModel msg, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (msg.content != null && msg.content!.isNotEmpty)
          Text(
            msg.content!,
            style: TextStyle(color: cs.onSurface, fontSize: 15, height: 1.4),
          ),
        if (msg.attachments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const Icon(LucideIcons.paperclip, size: 16),
                const SizedBox(width: 8),
                Text('${msg.attachments.length} attachment(s)'),
              ],
            ),
          ),
      ],
    );
  }
}
