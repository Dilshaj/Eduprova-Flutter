import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_avatar.dart';
import 'user_profile.dart';
import '../../models/conversation_model.dart';
import '../../models/message_model.dart';
import '../../providers/messages_provider.dart';
import '../../providers/chat_socket_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class UserChatScreen extends ConsumerStatefulWidget {
  final ConversationModel? conversation;
  final String? userName;
  final String? userAvatar;
  final String? userStatus;

  const UserChatScreen({
    super.key,
    this.conversation,
    this.userName,
    this.userAvatar,
    this.userStatus,
  });

  @override
  ConsumerState<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends ConsumerState<UserChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool showMenu = false;

  @override
  void initState() {
    super.initState();
    if (widget.conversation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(chatSocketProvider.notifier)
            .joinConversation(widget.conversation!.id);
      });
    }
  }

  @override
  void dispose() {
    if (widget.conversation != null) {
      ref
          .read(chatSocketProvider.notifier)
          .leaveConversation(widget.conversation!.id);
    }
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || widget.conversation == null)
      return;

    ref
        .read(localMessagesProvider.notifier)
        .sendMessage(widget.conversation!.id, _messageController.text.trim());
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final currentUserId = auth.user?.id ?? '';
    final conversation = widget.conversation;

    final userName =
        conversation?.getDisplayTitle(currentUserId) ??
        widget.userName ??
        'User';
    final userStatus = widget.userStatus ?? 'online';
    final isDarkMode = Theme.of(context).brightness == .dark;

    final messagesAsync = conversation != null
        ? ref.watch(messagesFetcherProvider(conversation.id))
        : const AsyncValue<List<MessageModel>>.data([]);

    final localMessages = conversation != null
        ? (ref.watch(localMessagesProvider)[conversation.id] ?? [])
        : <MessageModel>[];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Container(
                  color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                  padding: const .symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF111111),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserProfileScreen(
                                  userName: userName,
                                  userAvatar: '',
                                  userStatus: userStatus,
                                  conversation: conversation,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              ChatAvatar(
                                conversation: conversation,
                                currentUserId: currentUserId,
                                size: 40,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: .start,
                                  mainAxisSize: .min,
                                  children: [
                                    Text(
                                      userName,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: .bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : const Color(0xFF111111),
                                      ),
                                      maxLines: 1,
                                      overflow: .ellipsis,
                                    ),
                                    Text(
                                      userStatus == 'online'
                                          ? 'Active now'
                                          : 'Away',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: userStatus == 'online'
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.call_outlined,
                          color: isDarkMode
                              ? Colors.white70
                              : const Color(0xFF111111),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.videocam_outlined,
                          color: isDarkMode
                              ? Colors.white70
                              : const Color(0xFF111111),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => showMenu = !showMenu),
                        icon: Icon(
                          Icons.more_vert,
                          color: isDarkMode
                              ? Colors.white70
                              : const Color(0xFF111111),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chat Messages
                Expanded(
                  child: messagesAsync.when(
                    data: (fetched) {
                      // Merge local messages (avoid duplicates by ID if already fetched)
                      final fetchedIds = {for (final m in fetched) m.id};
                      final combined = [
                        ...localMessages.where(
                          (m) => !fetchedIds.contains(m.id),
                        ),
                        ...fetched,
                      ];

                      return ListView.builder(
                        padding: const .symmetric(horizontal: 16, vertical: 20),
                        reverse: true, // Important for chat
                        itemCount: combined.length,
                        itemBuilder: (context, index) {
                          final msg = combined[index];
                          final isMe = msg.senderId == currentUserId;

                          return Padding(
                            padding: const .only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: .end,
                              mainAxisAlignment: isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isMe) ...[
                                  ChatAvatar(
                                    conversation: conversation,
                                    currentUserId: currentUserId,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.sizeOf(context).width *
                                            0.7,
                                      ),
                                      padding: const .symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? const Color(0xFF0066FF)
                                            : (isDarkMode
                                                  ? const Color(0xFF1E293B)
                                                  : const Color(0xFFF3F4F6)),
                                        borderRadius: .only(
                                          topLeft: const Radius.circular(20),
                                          topRight: const Radius.circular(20),
                                          bottomLeft: Radius.circular(
                                            isMe ? 20 : 0,
                                          ),
                                          bottomRight: Radius.circular(
                                            isMe ? 0 : 20,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        msg.content ?? '',
                                        style: GoogleFonts.inter(
                                          color: isMe
                                              ? Colors.white
                                              : (isDarkMode
                                                    ? Colors.white
                                                    : Colors.black87),
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: .min,
                                      children: [
                                        Text(
                                          _formatTime(msg.createdAt),
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        if (isMe) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.done_all,
                                            size: 14,
                                            color: const Color(0xFF0066FF),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ),

                // Input Area
                Container(
                  padding: const .symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDarkMode
                            ? const Color(0xFF334155)
                            : const Color(0xFFEEEEEE),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.add, color: Color(0xFF0066FF)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const .symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF3F4F6),
                            borderRadius: .circular(24),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  focusNode: _focusNode,
                                  decoration: const InputDecoration(
                                    hintText: 'Type a message',
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  style: GoogleFonts.inter(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.sentiment_satisfied_alt_outlined,
                                  size: 20,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.attach_file,
                                  size: 20,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          padding: const .all(12),
                          decoration: const BoxDecoration(
                            shape: .circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                            ),
                          ),
                          alignment: .center,
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Menu Overlay
            if (showMenu)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => showMenu = false),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox.expand(),
                ),
              ),
            if (showMenu)
              Positioned(
                top: 60,
                right: 16,
                child: Material(
                  elevation: 8,
                  color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: .circular(12),
                  child: Container(
                    width: 200,
                    padding: const .symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: .min,
                      children: [
                        _buildMenuOption(
                          Icons.info_outline,
                          'View Profile',
                          isDarkMode,
                        ),
                        _buildMenuOption(
                          Icons.notifications_outlined,
                          'Mute',
                          isDarkMode,
                        ),
                        _buildMenuOption(
                          Icons.search,
                          'Search Chat',
                          isDarkMode,
                        ),
                        _buildMenuOption(
                          Icons.block_flipped,
                          'Block',
                          isDarkMode,
                          isRed: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    IconData icon,
    String label,
    bool isDarkMode, {
    bool isRed = false,
  }) {
    return InkWell(
      onTap: () => setState(() => showMenu = false),
      child: Padding(
        padding: const .symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isRed
                  ? Colors.redAccent
                  : (isDarkMode ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isRed
                    ? Colors.redAccent
                    : (isDarkMode ? Colors.white : Colors.black),
                fontWeight: .w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
