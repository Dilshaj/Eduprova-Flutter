import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
import '../widgets/messages_background.dart';
import 'chat_profile_screen.dart';
import 'live_call_screen.dart';
import 'image_preview_screen.dart';
import '../widgets/chat_bubble_painter.dart';
import '../widgets/chat_doodle_painter.dart';

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

  // Selection & Reply State
  final Set<String> _selectedMessageIds = {};
  bool _showReactionOverlay = false;
  String? _reactionMessageId;
  Offset? _tapPosition;

  // Unsubscribe callbacks
  VoidCallback? _unsubscribeMessages;
  VoidCallback? _unsubscribeReactions;
  final LayerLink _selectedMessageLayerLink = LayerLink();

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
    _unsubscribeMessages = _chatSocketNotifier.onNewMessage(
      widget.conversationId,
      (message) {
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
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
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
      },
    );

    _unsubscribeReactions = _chatSocketNotifier.onReaction(
      widget.conversationId,
      (convId, messageId, reactions) {
        if (!mounted) return;
        ref
            .read(localMessagesProvider.notifier)
            .updateReactions(convId, messageId, reactions);
      },
    );
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

  void _toggleSelection(String messageId) {
    final bool wasEmpty = _selectedMessageIds.isEmpty;
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
      } else {
        _selectedMessageIds.add(messageId);
      }

      if (_selectedMessageIds.isEmpty) {
        _showReactionOverlay = false;
        _reactionMessageId = null;
      } else if (_selectedMessageIds.length == 1 && wasEmpty) {
        // Only show reaction overlay if it's the FIRST message being selected
        _reactionMessageId = _selectedMessageIds.first;
        _showReactionOverlay = true;
      } else if (_selectedMessageIds.length != 1) {
        // Hide if more than one selected or if we unselected back to 1 (per user request)
        _showReactionOverlay = false;
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectedMessageIds.clear();
      _showReactionOverlay = false;
      _reactionMessageId = null;
    });
  }

  void _forwardSelected() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Forwarding not implemented')));
    _cancelSelection();
  }

  void _deleteSelected() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Deleting not implemented')));
    _cancelSelection();
  }

  void _onReply(MessageModel message) {
    _setReply(message);
    _cancelSelection();
  }

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
    if (_conversation == null ||
        _conversation!.type == ConversationType.direct) {
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
        const SnackBar(
          content: Text('All selected users are already in this group'),
        ),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Participants added')));
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
                isFavorite ? 'Remove from favourites' : 'Add to favourites',
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

  Widget _buildReactionOverlay(BuildContext context, ColorScheme cs) {
    if (_tapPosition == null) return const SizedBox.shrink();

    final screenWidth = MediaQuery.sizeOf(context).width;

    // Estimate reaction bar width (padding + emojis = ~300)
    const double barWidth = 320;

    double top = _tapPosition!.dy - 70;
    if (top < 100) {
      top = _tapPosition!.dy + 20; // Show below finger if too high
    }

    double left = _tapPosition!.dx - (barWidth / 2);
    if (left < 16) left = 16;
    if (left + barWidth > screenWidth - 16) left = screenWidth - barWidth - 16;

    return Positioned(
      top: top,
      left: left,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ['❤️', '👍', '😂', '😮', '😢', '🔥'].map((emoji) {
              return GestureDetector(
                onTap: () {
                  if (_reactionMessageId != null) {
                    _addReaction(_reactionMessageId!, emoji);
                  }
                  _cancelSelection();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _addReaction(String messageId, String emoji) async {
    await MessagesRepository().addReaction(messageId, emoji);
    // Real-time update should happen via socket, but we can also update locally
    ref.read(localMessagesProvider.notifier).updateReactions(
      widget.conversationId,
      messageId,
      [
        {'emoji': emoji, 'userId': _currentUserId},
      ],
    );
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

    return PopScope(
      canPop: _selectedMessageIds.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedMessageIds.isNotEmpty) {
          _cancelSelection();
        }
      },
      child: MessagesBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: ChatDoodlePainter(
                  color: const Color(0xffEEEEEE),
                ),
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _buildAppBar(theme, cs, otherUserId),
              body: GestureDetector(
                onTap: () {
                  if (_selectedMessageIds.isNotEmpty) {
                    _cancelSelection();
                  }
                },
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: _isLoadingConversation
                              ? _buildSkeletonList()
                              : messages.isEmpty
                                  ? _buildEmptyState(cs)
                                  : NotificationListener<ScrollNotification>(
                                      onNotification: (notification) {
                                        if (notification is ScrollUpdateNotification) {
                                          if (_showReactionOverlay) {
                                            setState(() {
                                              _showReactionOverlay = false;
                                            });
                                          }
                                        }
                                        return false;
                                      },
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        reverse: true,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 12,
                                        ),
                                        itemCount: messages.length,
                                        itemBuilder: (context, index) {
                                          final msg = messages[index];
                                          final olderMsg = index < messages.length - 1
                                              ? messages[index + 1]
                                              : null;
                                          final newerMsg = index > 0
                                              ? messages[index - 1]
                                              : null;

                                          return _buildMessageGroup(
                                            msg,
                                            olderMsg,
                                            newerMsg,
                                            context,
                                          );
                                        },
                                      ),
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
                    if (_showReactionOverlay) _buildReactionOverlay(context, cs),
                    if (!_isAtBottom || _newMessagesCount > 0)
                      Positioned(
                        right: 16,
                        bottom: _isPendingDirectChat ||
                                isOtherTyping ||
                                _replyToMessage != null
                            ? 160
                            : 100,
                        child: _buildScrollToBottomButton(cs),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            Icon(LucideIcons.chevronDown, color: cs.primary),
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
    if (_selectedMessageIds.isNotEmpty) {
      return AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: _cancelSelection,
          icon: Icon(LucideIcons.x, color: cs.onSurface),
        ),
        title: Text(
          '${_selectedMessageIds.length} selected',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final msgId = _selectedMessageIds.first;
              final messages = ref.read(
                combinedMessagesProvider(widget.conversationId),
              );
              try {
                final msg = messages.firstWhere((m) => m.id == msgId);
                _onReply(msg);
              } catch (_) {}
            },
            icon: Icon(
              LucideIcons.reply,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          IconButton(
            onPressed: () => _forwardSelected(),
            icon: Icon(
              LucideIcons.forward,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          IconButton(
            onPressed: () => _deleteSelected(),
            icon: Icon(
              LucideIcons.trash2,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    }

    final avatarUrl = _getConversationAvatar();
    final isOnline = otherUserId != null
        ? ref.watch(isUserOnlineProvider(otherUserId))
        : false;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF33334F),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (otherUserId != null)
                    Text(
                      isOnline ? 'Online' : 'Recently active',
                      style: TextStyle(
                        color: isOnline
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF33334F).withValues(alpha: 0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else if (_conversation != null)
                    Text(
                      '${_conversation!.participants.length} Participants',
                      style: TextStyle(
                        color: const Color(0xFF33334F).withValues(alpha: 0.4),
                        fontSize: 12,
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
              LucideIcons.userPlus,
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
                  LucideIcons.phone,
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
                  LucideIcons.video,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
          onPressed: _startingVideoCall ? null : () => _startCall(video: true),
        ),
        IconButton(
          icon: Icon(
            LucideIcons.ellipsisVertical,
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
    MessageModel? newerMsg,
    BuildContext context,
  ) {
    final isMe = msg.senderId == _currentUserId;
    final showDateSeparator =
        olderMsg == null || !_isSameDay(msg.createdAt, olderMsg.createdAt);

    return Column(
      children: [
        if (showDateSeparator) _buildDateSeparator(msg.createdAt),
        _buildMessageBubble(msg, isMe, context, olderMsg, newerMsg),
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
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD9E4E8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
    );

    // return Padding(
    //   padding: const EdgeInsets.symmetric(vertical: 16),
    //   child: Row(
    //     children: [

    //       // const Expanded(child: Divider()),
    //       // Padding(
    //       //   padding: const EdgeInsets.symmetric(horizontal: 12),
    //       //   child:
    //       // ),
    //       // const Expanded(child: Divider()),
    //     ],
    //   ),
    // );
  }

  Widget _buildMessageBubble(
    MessageModel msg,
    bool isMe,
    BuildContext context,
    MessageModel? olderMsg,
    MessageModel? newerMsg,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isDirectChat = _conversation?.type == ConversationType.direct;
    final isSelected = _selectedMessageIds.contains(msg.id);

    // olderMsg is visually ABOVE the current message (due to reverse: true in ListView)
    // newerMsg is visually BELOW the current message
    final isPartOfGroupAbove =
        olderMsg != null &&
        olderMsg.senderId == msg.senderId &&
        _isSameMinute(olderMsg.createdAt, msg.createdAt);

    final isPartOfGroupBelow =
        newerMsg != null &&
        newerMsg.senderId == msg.senderId &&
        _isSameMinute(newerMsg.createdAt, msg.createdAt);

    return GestureDetector(
      onLongPressStart: (details) {
        _tapPosition = details.globalPosition;
      },
      onLongPress: () {
        if (!_selectedMessageIds.contains(msg.id)) {
          _toggleSelection(msg.id);
        } else if (_selectedMessageIds.length == 1) {
          setState(() {
            _showReactionOverlay = true;
          });
        }
      },
      onTap: () {
        if (_selectedMessageIds.isNotEmpty) {
          _toggleSelection(msg.id);
        }
      },
      child: Container(
        color: isSelected ? cs.primary.withValues(alpha: 0.12) : Colors.transparent,
        padding: EdgeInsets.only(
          top: isPartOfGroupAbove ? 2 : 12,
          bottom: isPartOfGroupBelow ? 2 : 12,
          left: 12,
          right: 12,
        ),
        child: CompositedTransformTarget(
          link: isSelected && _selectedMessageIds.length == 1 ? _selectedMessageLayerLink : LayerLink(),
          child: _SwipeToReply(
            onReply: () => _onReply(msg),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMe) ...[
                  _buildAvatar(msg, cs),
                  const SizedBox(width: 12),
                ],
                Flexible(
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (!isMe && !isDirectChat && !isPartOfGroupAbove)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: Text(
                            msg.sender != null ? '${msg.sender!.firstName} ${msg.sender!.lastName}' : 'Member',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      Stack(
                        children: [
                          CustomPaint(
                            painter: ChatBubblePainter(
                              color: isMe ? const Color(0xFF0066FF) : const Color(0xFFFDFBFF),
                              isMe: isMe,
                              showTail: !isPartOfGroupBelow,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: !isMe ? BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE8EEF1), width: 1),
                              ) : null,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (msg.replyToMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _buildReplyContext(msg.replyToMessage!, isMe, cs),
                                    ),
                                  if (msg.attachments.any((a) => a.type == 'image'))
                                    _buildImageAttachments(msg, context, cs),
                                  
                                  Wrap(
                                    alignment: WrapAlignment.end,
                                    crossAxisAlignment: WrapCrossAlignment.end,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        msg.content ?? '',
                                        style: TextStyle(
                                          color: isMe ? Colors.white : const Color(0xFF33334F),
                                          fontSize: 16,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            DateFormat('h:mm a').format(msg.createdAt.toLocal()).toLowerCase(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isMe 
                                                ? Colors.white.withValues(alpha: 0.7)
                                                : const Color(0xff71719A).withValues(alpha: 0.7),
                                            ),
                                          ),
                                          if (isMe) ...[
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.done_all,
                                              size: 14,
                                              color: Colors.white.withValues(alpha: 0.8),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (msg.reactions.isNotEmpty) _buildReactions(msg, cs),
                    ],
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 12),
                  _buildAvatar(msg, cs),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageAttachments(MessageModel msg, BuildContext context, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var attachment in msg.attachments.where((a) => a.type == 'image'))
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ImagePreviewScreen(
                      imageUrl: attachment.url,
                      heroTag: 'msg_${msg.id}_${attachment.url}',
                    ),
                  ),
                );
              },
              child: Hero(
                tag: 'msg_${msg.id}_${attachment.url}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: attachment.url,
                    cacheManager: CacheManagers.messageCacheManager,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      width: double.infinity,
                      color: cs.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _isSameMinute(DateTime d1, DateTime d2) {
    return d1.year == d2.year &&
        d1.month == d2.month &&
        d1.day == d2.day &&
        d1.hour == d2.hour &&
        d1.minute == d2.minute;
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
    // High contrast styling against the message bubble
    final bgColor = isMe
        ? cs.onPrimary.withValues(alpha: 0.15)
        : cs.primary.withValues(alpha: 0.1);
    final borderColor = isMe ? cs.onPrimary : cs.primary;
    final titleColor = isMe ? cs.onPrimary : cs.primary;
    final textColor = isMe
        ? cs.onPrimary.withValues(alpha: 0.8)
        : cs.onSurface.withValues(alpha: 0.7);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            replyMsg['senderName']?.toString() ?? 'User',
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            replyMsg['content']?.toString() ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textColor, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildReactions(MessageModel msg, ColorScheme cs) {
    final theme = Theme.of(context);
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
                border: Border.all(
                  width: 0.5,
                  color: theme.dividerColor.withValues(alpha: 0.7),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: cs.primary, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _replyToMessage!['senderName'] ?? 'User',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _replyToMessage!['content']?.toString() ?? 'Attachment',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              _replyToId = null;
              _replyToMessage = null;
            }),
            icon: Icon(
              LucideIcons.x,
              size: 18,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme, ColorScheme cs) {

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Plus button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE8EEF1), width: 1),
              ),
              child: IconButton(
                onPressed: _pickImage,
                icon: const Icon(LucideIcons.plus, color: Color(0xFF0066FF), size: 20),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 8),
            // Input field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5F9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE8EEF1), width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _inputFocusNode,
                        onChanged: (val) {
                          setState(() {});
                          _onTextChanged(val);
                        },
                        style: const TextStyle(fontSize: 15, color: Color(0xFF33334F)),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: const Color(0xFF33334F).withValues(alpha: 0.4)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.sentiment_satisfied_alt_outlined, 
                        color: const Color(0xFF33334F).withValues(alpha: 0.5), size: 24),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _messageController,
              builder: (context, value, child) {
                final hasText = value.text.trim().isNotEmpty;
                return Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFFA855F7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: IconButton(
                    onPressed: hasText ? _sendMessage : null,
                    icon: Transform.rotate(
                      angle: -0.4,
                      child: const Icon(
                        LucideIcons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                );
              },
            ),
          ],
        ),
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
              LucideIcons.megaphone,
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

// ─── Swipe to Reply ────────────────────────────────────────────────────────

class _SwipeToReply extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;

  const _SwipeToReply({required this.child, required this.onReply});

  @override
  State<_SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<_SwipeToReply> {
  double _dragOffset = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0) {
          setState(() {
            _dragOffset = (details.delta.dx + _dragOffset).clamp(0, 100);
          });
        }
      },
      onHorizontalDragEnd: (details) {
        if (_dragOffset > 50) {
          widget.onReply();
        }
        setState(() {
          _dragOffset = 0;
        });
      },
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
          if (_dragOffset > 0)
            Positioned(
              left: _dragOffset / 2 - 20,
              child: Opacity(
                opacity: (_dragOffset / 50).clamp(0, 1),
                child: const Icon(Icons.reply, color: Color(0xFF0066FF)),
              ),
            ),
        ],
      ),
    );
  }
}
