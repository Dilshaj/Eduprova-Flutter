import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../providers/messages_provider.dart';

class ForwardMessageScreen extends ConsumerStatefulWidget {
  final List<MessageModel> messages;

  const ForwardMessageScreen({super.key, required this.messages});

  @override
  ConsumerState<ForwardMessageScreen> createState() =>
      _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends ConsumerState<ForwardMessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedConversationIds = {};
  bool _isSending = false;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedConversationIds.contains(id)) {
        _selectedConversationIds.remove(id);
      } else {
        _selectedConversationIds.add(id);
      }
    });
  }

  Future<void> _forwardMessage() async {
    if (_selectedConversationIds.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    final repo = ref.read(messagesRepositoryProvider);

    try {
      for (final convId in _selectedConversationIds) {
        for (final msg in widget.messages) {
          await repo.sendMessage(
            conversationId: convId,
            content: msg.content ?? '',
            type: msg.type,
            isForwarded: true,
            attachments: msg.attachments,
          );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Message forwarded to ${_selectedConversationIds.length} chat(s)',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to forward message')),
      );
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final conversationsAsync = ref.watch(conversationsProvider);
    final currentUserId = ref.read(authProvider).user?.id ?? '';
    final searchQuery = _searchController.text.toLowerCase();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Forward to...'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.arrowLeft, size: 20),
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              backgroundColor: cs.surfaceContainerHigh,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(LucideIcons.search),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: conversationsAsync.when(
              data: (conversations) {
                final filtered = conversations.where((conv) {
                  final title = conv
                      .getDisplayTitle(currentUserId)
                      .toLowerCase();
                  return title.contains(searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No chats found',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final conv = filtered[index];
                    final isSelected = _selectedConversationIds.contains(
                      conv.id,
                    );

                    return ListTile(
                      leading: _buildAvatar(conv, currentUserId, cs),
                      title: Text(conv.getDisplayTitle(currentUserId)),
                      subtitle: Text(
                        conv.type == ConversationType.direct
                            ? 'Direct Message'
                            : 'Group',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggleSelection(conv.id),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onTap: () => _toggleSelection(conv.id),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) =>
                  const Center(child: Text('Failed to load chats')),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedConversationIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _isSending ? null : _forwardMessage,
              label: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Forward'),
              icon: _isSending ? null : const Icon(LucideIcons.send),
            )
          : null,
    );
  }

  Widget _buildAvatar(
    ConversationModel conv,
    String currentUserId,
    ColorScheme cs,
  ) {
    final avatarUrl = conv.getDisplayAvatar(currentUserId);
    String initials = '?';

    if (avatarUrl == null) {
      final title = conv.getDisplayTitle(currentUserId);
      initials = title.isNotEmpty ? title[0].toUpperCase() : '?';
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: cs.primaryContainer,
      backgroundImage: avatarUrl != null
          ? CachedNetworkImageProvider(avatarUrl)
          : null,
      child: avatarUrl == null
          ? Text(
              initials,
              style: TextStyle(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}
