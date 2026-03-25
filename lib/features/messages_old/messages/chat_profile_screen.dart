import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/utils/image_cache_manager.dart';
import '../../auth/providers/auth_provider.dart';
import '../messages-home/widgets/chat_avatar.dart';
import '../models/conversation_model.dart';
import '../providers/messages_provider.dart';
import '../widgets/participant_picker_screen.dart';
import '../models/search_user_model.dart';
import '../repository/messages_repository.dart';
import 'chat_shared_media_screen.dart';
import 'chat_participants_screen.dart';
import '../../../core/widgets/app_loaders.dart';

class ChatProfileScreen extends ConsumerStatefulWidget {
  final ConversationModel conversation;

  const ChatProfileScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatProfileScreen> createState() => _ChatProfileScreenState();
}

class _ChatProfileScreenState extends ConsumerState<ChatProfileScreen> {
  final MessagesRepository _repository = MessagesRepository();
  late ConversationModel _conversation;
  bool _isAddingParticipants = false;

  @override
  void initState() {
    super.initState();
    _conversation = widget.conversation;
  }

  bool get _isGroup => _conversation.type != ConversationType.direct;

  bool get _canManageParticipants {
    if (!_isGroup) return false;
    final currentUserId = ref.read(authProvider).user?.id ?? '';
    return _conversation.participants.any(
      (participant) =>
          participant.userId == currentUserId &&
          (participant.role == 'admin' ||
              _conversation.createdBy == currentUserId),
    );
  }

  Future<void> _addParticipants() async {
    if (_isAddingParticipants || !_canManageParticipants) return;

    final selected = await Navigator.of(context).push<List<SearchUserModel>>(
      MaterialPageRoute(
        builder: (_) => const ParticipantPickerScreen(
          title: 'Add Participants',
          submitLabel: 'Add',
        ),
      ),
    );

    if (!mounted || selected == null || selected.isEmpty) return;

    final existingIds = _conversation.participants
        .map((participant) => participant.userId)
        .toSet();
    final userIds = selected
        .map((user) => user.id)
        .where((id) => !existingIds.contains(id))
        .toList();

    if (userIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All selected users are already in this chat'),
        ),
      );
      return;
    }

    setState(() => _isAddingParticipants = true);
    final updated = await _repository.addParticipants(
      _conversation.id,
      userIds,
    );
    if (!mounted) return;
    setState(() => _isAddingParticipants = false);

    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to add participants')),
      );
      return;
    }

    setState(() => _conversation = updated);
    ref.read(conversationsProvider.notifier).addOrUpdateConversation(updated);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Participants added')));
  }

  Future<void> _clearChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text(
          'Are you sure you want to clear this chat for everyone?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await _repository.clearChat(_conversation.id);
    if (!mounted) return;

    if (success) {
      ref.read(localMessagesProvider.notifier).clearMessages(_conversation.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chat cleared')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to clear chat')));
    }
  }

  Future<void> _toggleDisappearingMessages() async {
    // Basic toggle: 7 days or off
    // If we had fields on ConversationModel for this, we would check them.
    // Assuming backend returns success and we just show an optimistic UI or message.
    final enable = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disappearing Messages'),
        content: const Text(
          'New messages will disappear 7 days after they are sent.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Turn Off'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (enable == null) return;

    // 604800 seconds = 7 days
    final duration = enable ? 604800 : 0;
    final success = await _repository.updateDisappearingMessages(
      _conversation.id,
      enable,
      duration,
    );
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Disappearing messages ${enable ? 'enabled' : 'disabled'}',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update disappearing messages')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == .dark;
    final currentUserId = ref.watch(authProvider).user?.id ?? '';
    final title = _conversation.getDisplayTitle(currentUserId);
    final isFavorite = ref.watch(
      favoriteConversationIdsProvider.select(
        (ids) => ids.contains(_conversation.id),
      ),
    );
    final textColor = isDarkMode ? Colors.white : Colors.black;

    final messages = ref.watch(combinedMessagesProvider(_conversation.id));
    final mediaAttachments = messages
        .where((m) => m.attachments.isNotEmpty)
        .expand((m) => m.attachments)
        .where((a) => a.type == 'image' || a.type == 'video')
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isGroup ? 'Team Info' : 'Chat Profile',
          style: GoogleFonts.inter(color: textColor, fontWeight: .bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref
                .read(favoriteConversationIdsProvider.notifier)
                .toggle(_conversation.id),
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFavorite ? Colors.amber.shade600 : textColor,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const .symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Team Icon
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: .circle,
                  gradient: LinearGradient.new(
                    colors: [.new(0xFF0066FF), .new(0xFFE056FD)],
                  ),
                ),
                alignment: .center,
                child: ChatAvatar(
                  conversation: _conversation,
                  currentUserId: currentUserId,
                  size: 108,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: .bold,
                color: textColor,
              ),
            ),
            if (_isGroup)
              Text(
                '${_conversation.participants.length} Participants',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
              ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                if (_canManageParticipants)
                  _buildActionIcon(
                    LucideIcons.userPlus,
                    'Add',
                    isDarkMode,
                    onTap: _addParticipants,
                  ),
                _buildActionIcon(LucideIcons.search, 'Find', isDarkMode),
                _buildActionIcon(LucideIcons.bell, 'Mute', isDarkMode),
                _buildActionIcon(LucideIcons.video, 'Meet', isDarkMode),
              ],
            ),

            const SizedBox(height: 40),

            // Members Section
            if (_isGroup) ...[
              _buildSectionHeader('Participants', isDarkMode),
              const SizedBox(height: 16),
              for (
                var i = 0;
                i <
                    (_conversation.participants.length > 4
                        ? 4
                        : _conversation.participants.length);
                i++
              )
                _buildMemberTile(_conversation.participants[i], isDarkMode),
              if (_conversation.participants.length > 4)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatParticipantsScreen(
                          conversation: _conversation,
                          currentUserId: currentUserId,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'View all participants',
                    style: GoogleFonts.inter(color: const Color(0xFF0066FF)),
                  ),
                ),
              const SizedBox(height: 24),
            ],

            // Media Section
            if (mediaAttachments.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListTile(
                    LucideIcons.image,
                    'Media, links, and docs',
                    '',
                    isDarkMode,
                    isRed: false,
                    trailing: Row(
                      mainAxisSize: .min,
                      children: [
                        Text(
                          '${mediaAttachments.length}',
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          LucideIcons.chevronRight,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatSharedMediaScreen(
                            conversation: _conversation,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: .horizontal,
                      itemCount: mediaAttachments.length > 5
                          ? 5
                          : mediaAttachments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final media = mediaAttachments[index];
                        return ClipRRect(
                          borderRadius: .circular(12),
                          child: CachedNetworkImage(
                            imageUrl: media.url,
                            width: 100,
                            height: 100,
                            fit: .cover,
                            placeholder: (context, url) =>
                                const ShimmerImageLoader(),
                            errorWidget: (context, url, error) => Container(
                              color: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              child: const Icon(
                                LucideIcons.imageOff,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              )
            else
              _buildListTile(
                LucideIcons.image,
                'Media, links, and docs',
                'None',
                isDarkMode,
                isRed: false,
                trailing: const Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: Colors.grey,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChatSharedMediaScreen(conversation: _conversation),
                    ),
                  );
                },
              ),
            if (mediaAttachments.isEmpty) const SizedBox(height: 24),

            _buildSectionHeader(
              _isGroup ? 'Group Settings' : 'Details',
              isDarkMode,
            ),
            const SizedBox(height: 12),
            if ((_conversation.description ?? '').isNotEmpty)
              _buildListTile(
                LucideIcons.info,
                'Description',
                _conversation.description!.trim(),
                isDarkMode,
                isRed: false,
              ),
            if (_isGroup)
              _buildListTile(
                LucideIcons.link,
                'Invite Link',
                'eduprova.com/j/team',
                isDarkMode,
                isRed: false,
              ),

            const SizedBox(height: 24),
            _buildListTile(
              LucideIcons.timer,
              'Disappearing Messages',
              '',
              isDarkMode,
              isRed: false,
              onTap: _toggleDisappearingMessages,
            ),
            _buildListTile(
              LucideIcons.eraser,
              'Clear Chat',
              '',
              isDarkMode,
              isRed: true,
              onTap: _clearChat,
            ),
            if (_isGroup)
              _buildListTile(
                LucideIcons.logOut,
                'Leave Group',
                '',
                isDarkMode,
                isRed: true,
              ),
            if (_isCurrentUserAdmin)
              _buildListTile(
                LucideIcons.trash2,
                'Delete Group',
                '',
                isDarkMode,
                isRed: true,
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  bool get _isCurrentUserAdmin {
    final currentUserId = ref.read(authProvider).user?.id ?? '';
    return _conversation.participants.any(
      (participant) =>
          participant.userId == currentUserId && participant.role == 'admin',
    );
  }

  Widget _buildActionIcon(
    IconData icon,
    String label,
    bool isDarkMode, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              shape: .circle,
            ),
            child: Icon(icon, color: isDarkMode ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: .bold,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildMemberTile(ConversationMember participant, bool isDarkMode) {
    final name = participant.user != null
        ? '${participant.user!.firstName} ${participant.user!.lastName}'.trim()
        : 'Participant';
    final avatar = participant.user?.avatar;
    final role = participant.role == 'admin' ? 'Admin' : 'Member';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.blue.withValues(alpha: 0.2),
        backgroundImage: avatar != null && avatar.isNotEmpty
            ? CachedNetworkImageProvider(
                avatar,
                cacheManager: CacheManagers.messageCacheManager,
              )
            : null,
        child: avatar == null || avatar.isEmpty
            ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
            : null,
      ),
      title: Text(
        name.isEmpty ? 'Participant' : name,
        style: GoogleFonts.inter(
          color: isDarkMode ? Colors.white : Colors.black,
          fontWeight: .w500,
        ),
      ),
      subtitle: Text(
        role,
        style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
      ),
      trailing: const Icon(
        LucideIcons.messageSquare,
        size: 18,
        color: Colors.blueAccent,
      ),
      onTap: () {},
    );
  }

  Widget _buildListTile(
    IconData icon,
    String label,
    String value,
    bool isDarkMode, {
    required bool isRed,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isRed
            ? Colors.redAccent
            : (isDarkMode ? Colors.white70 : Colors.black54),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: isRed
              ? Colors.redAccent
              : (isDarkMode ? Colors.white : Colors.black),
          fontSize: 16,
          fontWeight: .w500,
        ),
      ),
      subtitle: value.isNotEmpty
          ? Text(
              value,
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
            )
          : null,
      trailing: trailing ?? const Icon(LucideIcons.chevronRight, size: 20),
      onTap: onTap ?? () {},
    );
  }
}
