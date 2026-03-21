import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/utils/image_cache_manager.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/search_user_model.dart';
import '../providers/chat_socket_provider.dart';
import '../providers/messages_provider.dart';
import '../repository/calling_repository.dart';
import '../repository/messages_repository.dart';
import '../widgets/participant_picker_screen.dart';
import 'chat_profile_screen.dart';
import 'live_call_screen.dart';
import 'image_preview_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final MessagesRepository _messagesRepository = MessagesRepository();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  late final ActiveConversationNotifier _activeConversationNotifier;
  late final ConversationsNotifier _conversationsNotifier;
  late final ChatSocketNotifier _chatSocketNotifier;

  ConversationModel? _conversation;
  bool _isLoadingConversation = true;
  String? _replyToId;
  Map<String, dynamic>? _replyToMessage;
  Timer? _typingDebounce;
  bool _isTyping = false;
  bool _startingAudioCall = false;
  bool _startingVideoCall = false;

  bool _isAtBottom = true;
  int _newMessagesCount = 0;

  // Unsubscribe callbacks
  VoidCallback? _unsubscribeMessages;
  VoidCallback? _unsubscribeReactions;

  @override
  void initState() {
    super.initState();
    _activeConversationNotifier = ref.read(activeConversationProvider.notifier);
    _conversationsNotifier = ref.read(conversationsProvider.notifier);
    _chatSocketNotifier = ref.read(chatSocketProvider.notifier);
    Future.microtask(() {
      if (!mounted) return;
      _activeConversationNotifier.open(widget.conversationId);
    });
    _loadConversation();
    _setupSocketListeners();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final isAtBottom = _scrollController.offset <= 100;
    if (isAtBottom && !_isAtBottom) {
      if (mounted) {
        setState(() {
          _isAtBottom = true;
          _newMessagesCount = 0;
        });
      }
    } else if (!isAtBottom && _isAtBottom) {
      if (mounted) {
        setState(() {
          _isAtBottom = false;
        });
      }
    }
  }

  Future<void> _loadConversation() async {
    // Find from cached conversations
    final convState = ref.read(conversationsProvider);
    ConversationModel? cached;
    try {
      cached = convState.value?.firstWhere(
        (c) => c.id == widget.conversationId,
      );
    } catch (_) {}

    if (cached != null) {
      setState(() {
        _conversation = cached;
        _isLoadingConversation = false;
      });
    }

    final freshConversation = await _messagesRepository.getConversationById(
      widget.conversationId,
    );
    if (freshConversation != null && mounted) {
      setState(() {
        _conversation = freshConversation;
      });
      _conversationsNotifier.addOrUpdateConversation(freshConversation);
    }

    // Join socket room
    _chatSocketNotifier.joinConversation(widget.conversationId);

    // Mark as read
    await _messagesRepository.markAsRead(widget.conversationId);
    if (mounted) {
      _conversationsNotifier.markConversationRead(
        widget.conversationId,
        _currentUserId,
      );
    }

    // Seed messages for this conversation from API
    ref.invalidate(messagesFetcherProvider(widget.conversationId));
    final fetchedMessages = await ref.read(
      messagesFetcherProvider(widget.conversationId).future,
    );
    ref
        .read(localMessagesProvider.notifier)
        .seedMessages(widget.conversationId, fetchedMessages);

    // Scroll to bottom after loading
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    if (!mounted) return;
    setState(() {
      _isLoadingConversation = false;
    });
  }

  void _setupSocketListeners() {
    _unsubscribeMessages = _chatSocketNotifier.onNewMessage(widget.conversationId, (
      message,
    ) {
      if (!mounted) return;
      ref
          .read(localMessagesProvider.notifier)
          .addMessage(widget.conversationId, message);
      // Update conversation list last message
      _conversationsNotifier.updateLastMessage(
        widget.conversationId,
        message,
        currentUserId: _currentUserId,
        incrementUnread: false,
      );
      if (message.senderId != _currentUserId) {
        unawaited(_messagesRepository.markAsRead(widget.conversationId));
        _conversationsNotifier.markConversationRead(
          widget.conversationId,
          _currentUserId,
        );
      }

      // Scroll to new message only if at bottom OR if it's our own message
      final isMe = message.senderId == _currentUserId;
      if (_isAtBottom || isMe) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } else {
        // Capture old extent to prevent jump
        final oldExtent = _scrollController.hasClients
            ? _scrollController.position.maxScrollExtent
            : 0.0;

        if (mounted) {
          setState(() {
            _newMessagesCount++;
          });
        }

        // Adjust scroll position after message is added to stay visually stationary
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            final newExtent = _scrollController.position.maxScrollExtent;
            final diff = newExtent - oldExtent;
            if (diff > 0) {
              // Maintain same content position by increasing offset
              _scrollController.jumpTo(_scrollController.offset + diff);
            }
          }
        });
      }
    });

    _unsubscribeReactions = _chatSocketNotifier.onReaction(widget.conversationId, (
      convId,
      messageId,
      reactions,
    ) {
      if (!mounted) return;
      ref
          .read(localMessagesProvider.notifier)
          .updateReactions(convId, messageId, reactions);
    });
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    if (animated) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _unsubscribeMessages?.call();
    _unsubscribeReactions?.call();
    _chatSocketNotifier.leaveConversation(widget.conversationId);
    _activeConversationNotifier.close(widget.conversationId);
    _typingDebounce?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  String get _currentUserId => ref.read(authProvider).user?.id ?? '';

  String _getConversationTitle() {
    if (_conversation == null) return 'Chat';
    return _conversation!.getDisplayTitle(_currentUserId);
  }

  String? _getConversationAvatar() {
    return _conversation?.getDisplayAvatar(_currentUserId);
  }

  String? _getOtherUserId() {
    if (_conversation == null) return null;
    if (_conversation!.type != ConversationType.direct) return null;
    final other = _conversation!.participants.firstWhere(
      (p) => p.userId != _currentUserId,
      orElse: () => _conversation!.participants.first,
    );
    return other.userId;
  }

  Future<void> _startCall({required bool video}) async {
    if (_conversation == null) return;

    final type = _conversation!.type == ConversationType.direct
        ? 'dm'
        : 'group';
    final recipientIds = _conversation!.participants
        .map((participant) => participant.userId)
        .where((userId) => userId != _currentUserId)
        .toList();

    if (recipientIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No other participants found for this call'),
        ),
      );
      return;
    }

    setState(() {
      if (video) {
        _startingVideoCall = true;
      } else {
        _startingAudioCall = true;
      }
    });

    try {
      final room = await CallingRepository().createRoom(
        type: type,
        conversationId: _conversation!.type == ConversationType.group
            ? _conversation!.id
            : null,
        participantIds: _conversation!.type == ConversationType.direct
            ? recipientIds
            : const [],
      );

      final authUser = ref.read(authProvider).user;
      final callerName =
          '${authUser?.firstName ?? ''} ${authUser?.lastName ?? ''}'.trim();

      ref
          .read(chatSocketProvider.notifier)
          .emitCallInvite(
            recipientIds: recipientIds,
            roomName: room.roomName,
            conversationType: type,
            callerName: callerName.isNotEmpty ? callerName : 'Eduprova user',
            callerAvatar: authUser?.avatar,
          );

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LiveCallScreen(
            initialRoom: room,
            initialVideo: video,
            initialAudio: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to start call: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _startingAudioCall = false;
          _startingVideoCall = false;
        });
      }
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || !_canSendMessages) return;

    _messageController.clear();

    // Stop typing indicator
    _typingDebounce?.cancel();
    if (_isTyping) {
      ref
          .read(chatSocketProvider.notifier)
          .emitTypingStop(widget.conversationId);
      _isTyping = false;
    }

    // Send via socket
    ref
        .read(chatSocketProvider.notifier)
        .sendMessage(
          conversationId: widget.conversationId,
          content: text,
          replyTo: _replyToId,
          replyToMessage: _replyToMessage,
        );

    setState(() {
      _replyToId = null;
      _replyToMessage = null;
    });
  }

  bool get _isPendingDirectChat =>
      _conversation?.type == ConversationType.direct &&
      _conversation?.status == 'pending';

  bool get _isPendingCreator =>
      _isPendingDirectChat && _conversation?.createdBy == _currentUserId;

  bool get _isPendingWithoutPermission =>
      _isPendingDirectChat && !_isPendingCreator;

  bool get _isAnnouncementGroup =>
      _conversation?.type == ConversationType.announcement;

  bool get _isCurrentUserAdmin =>
      _conversation?.participants.any(
        (participant) =>
            participant.userId == _currentUserId && participant.role == 'admin',
      ) ??
      false;

  bool get _canManageParticipants =>
      _conversation != null &&
      _conversation!.type != ConversationType.direct &&
      (_isCurrentUserAdmin || _conversation!.createdBy == _currentUserId);

  bool get _canSendMessages =>
      !_isPendingWithoutPermission &&
      (!_isAnnouncementGroup || _isCurrentUserAdmin);

  Future<void> _addParticipantsToCommunityGroup() async {
    if (_conversation == null || _conversation!.type == ConversationType.direct) {
      return;
    }

    final selected = await Navigator.of(context).push<List<SearchUserModel>>(
      MaterialPageRoute(
        builder: (_) => const ParticipantPickerScreen(
          title: 'Add Participants',
          submitLabel: 'Add',
        ),
      ),
    );

    if (!mounted || selected == null || selected.isEmpty) return;

    final existingIds = _conversation!.participants
        .map((participant) => participant.userId)
        .toSet();
    final userIds = selected
        .map((user) => user.id)
        .where((id) => !existingIds.contains(id))
        .toList();

    if (userIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All selected users are already in this group')),
      );
      return;
    }

    final updated = await _messagesRepository.addParticipants(
      widget.conversationId,
      userIds,
    );

    if (!mounted) return;

    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to add participants')),
      );
      return;
    }

    setState(() => _conversation = updated);
    ref.read(conversationsProvider.notifier).addOrUpdateConversation(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Participants added')),
    );
  }

  Future<void> _openChatProfile() async {
    if (_conversation == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatProfileScreen(conversation: _conversation!),
      ),
    );

    final refreshed = ref
        .read(conversationsProvider.notifier)
        .getConversation(widget.conversationId);
    if (mounted && refreshed != null) {
      setState(() => _conversation = refreshed);
    }
  }

  Future<void> _openChatMenu() async {
    if (_conversation == null) return;
    final isFavorite = ref
        .read(favoriteConversationIdsProvider)
        .contains(widget.conversationId);

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(
                _conversation!.type == ConversationType.direct
                    ? 'View profile'
                    : 'View group info',
              ),
              onTap: () => Navigator.pop(ctx, 'profile'),
            ),
            if (_canManageParticipants)
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_rounded),
                title: const Text('Add participants'),
                onTap: () => Navigator.pop(ctx, 'participants'),
              ),
            ListTile(
              leading: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isFavorite ? Colors.amber.shade600 : null,
              ),
              title: Text(
                isFavorite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
              ),
              onTap: () => Navigator.pop(ctx, 'favorite'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;
    if (action == 'profile') {
      await _openChatProfile();
      return;
    }
    if (action == 'participants') {
      await _addParticipantsToCommunityGroup();
      return;
    }
    if (action == 'favorite') {
      await ref
          .read(favoriteConversationIdsProvider.notifier)
          .toggle(widget.conversationId);
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _acceptInvite() async {
    final updated = await _messagesRepository.acceptInvite(
      widget.conversationId,
    );
    if (!mounted) return;
    if (updated == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to accept invitation')),
      );
      return;
    }
    setState(() => _conversation = updated);
    ref.read(conversationsProvider.notifier).loadConversations();
  }

  Future<void> _rejectInvite() async {
    final ok = await _messagesRepository.rejectInvite(widget.conversationId);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reject invitation')),
      );
      return;
    }
    ref.read(conversationsProvider.notifier).loadConversations();
    context.pop();
  }

  void _onTextChanged(String value) {
    final notifier = ref.read(chatSocketProvider.notifier);
    if (value.isNotEmpty && !_isTyping) {
      notifier.emitTypingStart(widget.conversationId);
      _isTyping = true;
    }
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(seconds: 3), () {
      if (_isTyping) {
        notifier.emitTypingStop(widget.conversationId);
        _isTyping = false;
      }
    });
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    // Show loading or optimistic message? For now, just upload and send
    final repo = ref.read(messagesRepositoryProvider);
    final result = await repo.uploadChatFile(
      chatId: widget.conversationId,
      filePath: image.path,
    );

    if (result != null && result['url'] != null) {
      final imageUrl = result['url'].toString();
      ref
          .read(chatSocketProvider.notifier)
          .sendImageMessage(
            conversationId: widget.conversationId,
            imageUrl: imageUrl,
            replyTo: _replyToId,
          );

      setState(() {
        _replyToId = null;
        _replyToMessage = null;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
      }
    }
  }

  void _setReply(MessageModel message) {
    setState(() {
      _replyToId = message.id;
      _replyToMessage = {
        'content': message.content,
        'senderId': message.senderId,
        'senderName': message.sender != null
            ? '${message.sender!.firstName} ${message.sender!.lastName}'
            : 'User',
      };
    });
    _inputFocusNode.requestFocus();
  }

  void _showMessageActions(BuildContext context, MessageModel message) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji quick reactions
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['👍', '❤️', '😂', '😮', '😢', '🙏']
                      .map(
                        (e) => GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            _addReaction(message.id, e);
                          },
                          child: Text(e, style: const TextStyle(fontSize: 28)),
                        ),
                      )
                      .toList(),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.reply, color: cs.primary),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(ctx);
                  _setReply(message);
                },
              ),
              if (message.content != null)
                ListTile(
                  leading: Icon(Icons.copy, color: cs.onSurface),
                  title: const Text('Copy text'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Clipboard.setData(ClipboardData(text: message.content!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addReaction(String messageId, String emoji) async {
    await MessagesRepository().addReaction(messageId, emoji);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final messages = ref.watch(combinedMessagesProvider(widget.conversationId));
    final otherUserId = _getOtherUserId();
    final isOtherTyping = otherUserId != null
        ? ref.watch(isTypingProvider((widget.conversationId, otherUserId)))
        : false;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(theme, cs, otherUserId),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _isLoadingConversation
                    ? _buildSkeletonList()
                    : messages.isEmpty
                    ? _buildEmptyState(cs)
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true, // Use reverse list
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          // For descending list, the "previous" (older) message is at index + 1
                          final olderMsg = index < messages.length - 1
                              ? messages[index + 1]
                              : null;
                          return _buildMessageGroup(msg, olderMsg, context);
                        },
                      ),
              ),
              if (_isPendingDirectChat) _buildPendingInviteBanner(cs),
              if (isOtherTyping) _buildTypingIndicator(cs),
              if (_replyToMessage != null) _buildReplyBanner(cs),
              if (_isAnnouncementGroup && !_isCurrentUserAdmin)
                _buildAnnouncementNotice(cs),
              if (_canSendMessages) _buildMessageInput(theme, cs),
            ],
          ),
          if (!_isAtBottom || _newMessagesCount > 0)
            Positioned(
              right: 16,
              bottom:
                  _isPendingDirectChat ||
                      isOtherTyping ||
                      _replyToMessage != null
                  ? 160
                  : 100,
              child: _buildScrollToBottomButton(cs),
            ),
        ],
      ),
    );
  }

  Widget _buildScrollToBottomButton(ColorScheme cs) {
    return GestureDetector(
      onTap: () {
        _scrollToBottom();
        setState(() {
          _newMessagesCount = 0;
          _isAtBottom = true;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.keyboard_arrow_down, color: cs.primary),
            if (_newMessagesCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '$_newMessagesCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingInviteBanner(ColorScheme cs) {
    if (_isPendingCreator) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Waiting for accepted invitation...',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You received a chat invitation',
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: _rejectInvite,
                child: const Text('Decline'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _acceptInvite,
                child: const Text('Accept'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ThemeData theme,
    ColorScheme cs,
    String? otherUserId,
  ) {
    final avatarUrl = _getConversationAvatar();
    final isOnline = otherUserId != null
        ? ref.watch(isUserOnlineProvider(otherUserId))
        : false;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: cs.surface,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: cs.onSurface),
        onPressed: () => context.pop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          GestureDetector(
            onTap: _openChatProfile,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: cs.primaryContainer,
                  backgroundImage: avatarUrl != null
                      ? CachedNetworkImageProvider(
                          avatarUrl,
                          cacheManager: CacheManagers.messageCacheManager,
                        )
                      : null,
                  child: avatarUrl == null
                      ? Text(
                          _getConversationTitle().isNotEmpty
                              ? _getConversationTitle()[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: _openChatProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getConversationTitle(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (otherUserId != null)
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: isOnline
                            ? Colors.green
                            : cs.onSurface.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else if (_conversation != null)
                    Text(
                      '${_conversation!.participants.length} Participants',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (_canManageParticipants)
          IconButton(
            icon: Icon(
              Icons.person_add_alt_1_outlined,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
            onPressed: _addParticipantsToCommunityGroup,
          ),
        IconButton(
          icon: _startingAudioCall
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  Icons.call_outlined,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
          onPressed: _startingAudioCall ? null : () => _startCall(video: false),
        ),
        IconButton(
          icon: _startingVideoCall
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  Icons.videocam_outlined,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
          onPressed: _startingVideoCall ? null : () => _startCall(video: true),
        ),
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: cs.onSurface.withValues(alpha: 0.7),
          ),
          onPressed: _openChatMenu,
        ),
      ],
    );
  }

  Widget _buildMessageGroup(
    MessageModel msg,
    MessageModel? olderMsg,
    BuildContext context,
  ) {
    final isMe = msg.senderId == _currentUserId;
    final showDateSeparator =
        olderMsg == null || !_isSameDay(msg.createdAt, olderMsg.createdAt);

    return Column(
      children: [
        if (showDateSeparator) _buildDateSeparator(msg.createdAt),
        _buildMessageBubble(msg, isMe, context),
      ],
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final isToday = _isSameDay(date, now);
    final isYesterday = _isSameDay(date, now.subtract(const Duration(days: 1)));
    final label = isToday
        ? 'Today'
        : isYesterday
        ? 'Yesterday'
        : DateFormat('MMM d, y').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    MessageModel msg,
    bool isMe,
    BuildContext context,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAnnouncement = _isAnnouncementGroup;

    final bubbleColor = isMe
        ? cs.primary
        : (isDark ? const Color(0xFF2C2C2E) : Colors.white);
    final textColor = isMe ? cs.onPrimary : cs.onSurface;
    final subTextColor = isMe
        ? cs.onPrimary.withValues(alpha: 0.65)
        : cs.onSurface.withValues(alpha: 0.55);

    return GestureDetector(
      onLongPress: () => _showMessageActions(context, msg),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: isAnnouncement
              ? MainAxisAlignment.center
              : isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isAnnouncement && !isMe) ...[
              _buildAvatar(msg, cs),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isAnnouncement
                    ? CrossAxisAlignment.center
                    : isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Sender name for group chats
                  if (!isAnnouncement &&
                      _conversation?.type != ConversationType.direct &&
                      !isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 4),
                      child: Text(
                        msg.sender != null
                            ? '${msg.sender!.firstName} ${msg.sender!.lastName}'
                            : 'Member',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  // Reply context above bubble
                  if (msg.replyToMessage != null)
                    _buildReplyContext(msg.replyToMessage!, isMe, cs),
                  // Message bubble
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width *
                          (isAnnouncement ? 0.84 : 0.72),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(
                          isAnnouncement ? 18 : (isMe ? 18 : 4),
                        ),
                        bottomRight: Radius.circular(
                          isAnnouncement ? 18 : (isMe ? 4 : 18),
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.2 : 0.06,
                          ),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isAnnouncement
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        // Render image attachments if present
                        if (msg.attachments.any((a) => a.type == 'image'))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var attachment in msg.attachments.where(
                                  (a) => a.type == 'image',
                                ))
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ImagePreviewScreen(
                                              imageUrl: attachment.url,
                                              heroTag:
                                                  'msg_${msg.id}_${attachment.url}',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Hero(
                                        tag: 'msg_${msg.id}_${attachment.url}',
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: attachment.url,
                                            cacheManager: CacheManagers
                                                .messageCacheManager,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                  height: 200,
                                                  width: double.infinity,
                                                  color: cs
                                                      .surfaceContainerHighest,
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                                      Icons.broken_image,
                                                      size: 50,
                                                    ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (msg.content != null && msg.content!.isNotEmpty)
                          Text(
                            msg.content!,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              height: 1.4,
                            ),
                            textAlign: isAnnouncement ? TextAlign.center : null,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('h:mm a').format(msg.createdAt.toLocal()),
                          style: TextStyle(color: subTextColor, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  // Emoji reactions below bubble
                  if (msg.reactions.isNotEmpty) _buildReactions(msg, cs),
                ],
              ),
            ),
            if (isMe) const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(MessageModel msg, ColorScheme cs) {
    final avatarUrl = msg.sender?.avatar;
    final initials = msg.sender != null
        ? '${msg.sender!.firstName[0]}${msg.sender!.lastName.isNotEmpty ? msg.sender!.lastName[0] : ''}'
        : '?';
    return CircleAvatar(
      radius: 14,
      backgroundColor: cs.primaryContainer,
      backgroundImage: avatarUrl != null
          ? CachedNetworkImageProvider(
              avatarUrl,
              cacheManager: CacheManagers.messageCacheManager,
            )
          : null,
      child: avatarUrl == null
          ? Text(
              initials.toUpperCase(),
              style: TextStyle(
                color: cs.onPrimaryContainer,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildReplyContext(
    Map<String, dynamic> replyMsg,
    bool isMe,
    ColorScheme cs,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: cs.primary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            replyMsg['senderName']?.toString() ?? 'User',
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            replyMsg['content']?.toString() ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactions(MessageModel msg, ColorScheme cs) {
    // Group reactions by emoji
    final grouped = <String, int>{};
    for (final r in msg.reactions) {
      grouped[r.emoji] = (grouped[r.emoji] ?? 0) + r.userIds.length;
    }

    return Wrap(
      spacing: 4,
      children: [
        for (final entry in grouped.entries)
          GestureDetector(
            onTap: () => _addReaction(msg.id, entry.key),
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Text(
                '${entry.key} ${entry.value}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTypingIndicator(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: cs.primaryContainer,
            child: Text(
              '?',
              style: TextStyle(color: cs.onPrimaryContainer, fontSize: 10),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => _TypingDot(delay: Duration(milliseconds: i * 200)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBanner(ColorScheme cs) {
    return Container(
      color: cs.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(width: 3, height: 36, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyToMessage!['senderName'] ?? 'User'}',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _replyToMessage!['content']?.toString() ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
            onPressed: () => setState(() {
              _replyToId = null;
              _replyToMessage = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme, ColorScheme cs) {
    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: cs.onSurface.withValues(alpha: 0.5),
                      size: 22,
                    ),
                    onPressed: _pickImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _inputFocusNode,
                      onChanged: _onTextChanged,
                      onSubmitted: (_) => _sendMessage(),
                      style: theme.textTheme.bodyMedium,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: _isAnnouncementGroup
                            ? 'Write an announcement...'
                            : 'Type a message...',
                        hintStyle: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.sentiment_satisfied_alt_outlined,
                      color: cs.onSurface.withValues(alpha: 0.5),
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          ListenableBuilder(
            listenable: _messageController,
            builder: (_, _) {
              final hasText = _messageController.text.trim().isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasText ? cs.primary : cs.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    hasText ? Icons.send : Icons.mic,
                    color: hasText
                        ? cs.onPrimary
                        : cs.onSurface.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  onPressed: hasText ? _sendMessage : () {},
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementNotice(ColorScheme cs) {
    return Container(
      width: double.infinity,
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 18,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Only admins can send messages in announcements.',
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 8,
      itemBuilder: (_, i) {
        final isMe = i.isEven;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!isMe) ...[
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 120 + (i % 3) * 40.0,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: cs.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Say hi! 👋',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Typing dot animation ─────────────────────────────────────────────────

class _TypingDot extends StatefulWidget {
  final Duration delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(
      begin: 0,
      end: -6,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: cs.onSurface.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
