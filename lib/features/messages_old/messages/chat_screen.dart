import 'dart:io';
import 'dart:async';
import 'package:eduprova/features/messages_old/widgets/messages_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/utils/image_cache_manager.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/search_user_model.dart';
import '../providers/chat_socket_provider.dart';
import '../providers/messages_provider.dart';
import '../repository/messages_repository.dart';
import '../repository/calling_repository.dart';
import '../widgets/participant_picker_screen.dart';
import 'chat_profile_screen.dart';
import 'live_call_screen.dart';
import 'image_preview_screen.dart';
import 'pinned_messages_screen.dart';
import 'forward_message_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final MessagesRepository _messagesRepository = MessagesRepository();
  final TextEditingController _messageController = TextEditingController();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
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
  String? _highlightedMessageId;

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
    _itemPositionsListener.itemPositions.addListener(_scrollListener);
  }

  void _scrollListener() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    // Find the minimum index (since it's reversed, 0 is at bottom)
    final minIndex = positions
        .map((p) => p.index)
        .reduce((a, b) => a < b ? a : b);
    final isAtBottom = minIndex <= 1;

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
          if (mounted) {
            setState(() {
              _newMessagesCount++;
            });
          }
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
    if (!_itemScrollController.isAttached) return;
    if (animated) {
      _itemScrollController.scrollTo(
        index: 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _itemScrollController.jumpTo(index: 0);
    }
  }

  Future<void> _scrollToMessage(String messageId) async {
    final messages = ref.read(combinedMessagesProvider(widget.conversationId));
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      setState(() => _highlightedMessageId = messageId);
      await _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _highlightedMessageId == messageId) {
          setState(() => _highlightedMessageId = null);
        }
      });
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
    _itemPositionsListener.itemPositions.removeListener(_scrollListener);
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
    if (_selectedMessageIds.isEmpty) return;

    final messages = ref.read(combinedMessagesProvider(widget.conversationId));
    final selectedMsgs = messages
        .where((m) => _selectedMessageIds.contains(m.id))
        .toList();

    _cancelSelection();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForwardMessageScreen(messages: selectedMsgs),
      ),
    );
  }

  Future<void> _deleteSelected() async {
    if (_selectedMessageIds.isEmpty) return;

    final idsToDelete = _selectedMessageIds.toList();
    _cancelSelection();

    final repo = ref.read(messagesRepositoryProvider);
    final success = await repo.deleteMessages(idsToDelete);

    if (success && mounted) {
      for (final id in idsToDelete) {
        ref
            .read(localMessagesProvider.notifier)
            .removeMessage(widget.conversationId, id);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete messages')),
      );
    }
  }

  Future<void> _pinSelected() async {
    if (_selectedMessageIds.length != 1) return;
    final msgId = _selectedMessageIds.first;
    _cancelSelection();

    final repo = ref.read(messagesRepositoryProvider);
    final success = await repo.pinMessage(widget.conversationId, msgId);

    if (success && mounted) {
      if (_conversation != null) {
        final currentPins = _conversation!.pinnedMessages;
        if (!currentPins.contains(msgId)) {
          setState(() {
            _conversation = _conversation!.copyWith(
              pinnedMessages: [...currentPins, msgId],
            );
          });
          _conversationsNotifier.addOrUpdateConversation(_conversation!);
        }
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Message pinned')));
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to pin message')));
    }
  }

  Future<void> _toggleFavoriteSelected() async {
    if (_selectedMessageIds.isEmpty) return;

    final messages = ref.read(combinedMessagesProvider(widget.conversationId));
    final selectedMsgs = messages
        .where((m) => _selectedMessageIds.contains(m.id))
        .toList();

    final allStarred = selectedMsgs.every(
      (m) => m.starredBy.contains(_currentUserId),
    );

    final repo = ref.read(messagesRepositoryProvider);
    final ids = _selectedMessageIds.toList();
    _cancelSelection();

    final success = allStarred
        ? await repo.unstarMessages(ids)
        : await repo.starMessages(ids);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            allStarred ? 'Removed from favorites' : 'Added to favorites',
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Action failed')));
    }
  }

  void _copySelected() {
    if (_selectedMessageIds.isEmpty) return;
    final messages = ref.read(combinedMessagesProvider(widget.conversationId));
    final selectedMessages = messages
        .where((m) => _selectedMessageIds.contains(m.id))
        .toList();
    final textToCopy = selectedMessages
        .map((m) => m.content ?? '')
        .where((c) => c.isNotEmpty)
        .join('\n');

    if (textToCopy.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: textToCopy));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Message copied')));
    }
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final messages = ref.read(combinedMessagesProvider(widget.conversationId));
    if (text.isEmpty || !_canSendMessages(messages)) return;

    _messageController.clear();

    // Stop typing indicator
    _typingDebounce?.cancel();
    if (_isTyping) {
      ref
          .read(chatSocketProvider.notifier)
          .emitTypingStop(widget.conversationId);
      _isTyping = false;
    }

    // Optimistic Update
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final user = ref.read(authProvider).user;
    final tempMessage = MessageModel(
      id: tempId,
      conversationId: widget.conversationId,
      senderId: _currentUserId,
      content: text,
      type: MessageType.text,
      createdAt: DateTime.now(),
      attachments: const [],
      reactions: const [],
      readBy: [_currentUserId],
      replyTo: _replyToId,
      replyToMessage: _replyToMessage,
      sender: user,
    );
    ref
        .read(localMessagesProvider.notifier)
        .addMessage(widget.conversationId, tempMessage);
    _scrollToBottom();

    final prevReplyToId = _replyToId;
    final prevReplyToMessage = _replyToMessage;

    setState(() {
      _replyToId = null;
      _replyToMessage = null;
    });

    // Send via socket
    final actualMessage = await ref
        .read(chatSocketProvider.notifier)
        .sendMessage(
          conversationId: widget.conversationId,
          content: text,
          replyTo: prevReplyToId,
          replyToMessage: prevReplyToMessage,
        );

    if (mounted) {
      if (actualMessage != null) {
        ref
            .read(localMessagesProvider.notifier)
            .replaceMessage(widget.conversationId, tempId, actualMessage);
      } else {
        ref
            .read(localMessagesProvider.notifier)
            .removeMessage(widget.conversationId, tempId);
      }
    }
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

  bool _canSendMessages(List<MessageModel> messages) {
    if (_isPendingWithoutPermission) return false;
    if (_isAnnouncementGroup && !_isCurrentUserAdmin) return false;
    if (_isPendingCreator && messages.isNotEmpty) return false;
    return true;
  }

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
            ListTile(
              leading: const Icon(LucideIcons.timer),
              title: const Text('Disappearing messages'),
              onTap: () => Navigator.pop(ctx, 'disappearing'),
            ),
            ListTile(
              leading: const Icon(LucideIcons.eraser, color: Colors.red),
              title: const Text(
                'Clear chat',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => Navigator.pop(ctx, 'clear'),
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Copy Chat ID'),
              onTap: () => Navigator.pop(ctx, 'copy_id'),
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
      return;
    }
    if (action == 'disappearing') {
      await _toggleDisappearingMessages();
      return;
    }
    if (action == 'clear') {
      await _clearChat();
      return;
    }
    if (action == 'copy_id') {
      Clipboard.setData(ClipboardData(text: widget.conversationId));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chat ID copied')));
      return;
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

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final user = ref.read(authProvider).user;
    final tempMessage = MessageModel(
      id: tempId,
      conversationId: widget.conversationId,
      senderId: _currentUserId,
      content: '',
      type: MessageType.image,
      createdAt: DateTime.now(),
      attachments: [MessageAttachment(type: 'image', url: image.path)],
      reactions: const [],
      readBy: [_currentUserId],
      replyTo: _replyToId,
      replyToMessage: _replyToMessage,
      sender: user,
    );

    ref
        .read(localMessagesProvider.notifier)
        .addMessage(widget.conversationId, tempMessage);
    _scrollToBottom();

    final prevReplyToId = _replyToId;

    setState(() {
      _replyToId = null;
      _replyToMessage = null;
    });

    final repo = ref.read(messagesRepositoryProvider);
    final result = await repo.uploadChatFile(
      chatId: widget.conversationId,
      filePath: image.path,
    );

    if (result != null && result['url'] != null) {
      final imageUrl = result['url'].toString();
      final actualMessage = await ref
          .read(chatSocketProvider.notifier)
          .sendMessage(
            conversationId: widget.conversationId,
            content: '',
            type: 'image',
            attachments: [
              {
                'type': 'image',
                'url': imageUrl,
                'storageProvider': 'cloudinary',
              },
            ],
            replyTo: prevReplyToId,
          );

      if (mounted) {
        if (actualMessage != null) {
          ref
              .read(localMessagesProvider.notifier)
              .replaceMessage(widget.conversationId, tempId, actualMessage);
        } else {
          ref
              .read(localMessagesProvider.notifier)
              .removeMessage(widget.conversationId, tempId);
        }
      }
    } else {
      if (mounted) {
        ref
            .read(localMessagesProvider.notifier)
            .removeMessage(widget.conversationId, tempId);
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
        'attachments': message.attachments
            .map((a) => {'url': a.url, 'type': a.type, 'fileName': a.fileName})
            .toList(),
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
    final messages = ref.read(combinedMessagesProvider(widget.conversationId));
    final msgOption = messages.where((m) => m.id == messageId).toList();

    if (msgOption.isNotEmpty) {
      final msg = msgOption.first;
      final currentReactions = List<MessageReaction>.from(msg.reactions);
      final existingIndex = currentReactions.indexWhere(
        (r) => r.emoji == emoji && r.userIds.contains(_currentUserId),
      );

      if (existingIndex != -1) {
        final userIds = List<String>.from(
          currentReactions[existingIndex].userIds,
        )..remove(_currentUserId);
        if (userIds.isEmpty) {
          currentReactions.removeAt(existingIndex);
        } else {
          currentReactions[existingIndex] = MessageReaction(
            emoji: emoji,
            userIds: userIds,
          );
        }
      } else {
        final index = currentReactions.indexWhere((r) => r.emoji == emoji);
        if (index != -1) {
          currentReactions[index] = MessageReaction(
            emoji: emoji,
            userIds: [...currentReactions[index].userIds, _currentUserId],
          );
        } else {
          currentReactions.add(
            MessageReaction(emoji: emoji, userIds: [_currentUserId]),
          );
        }
      }

      ref
          .read(localMessagesProvider.notifier)
          .updateReactions(
            widget.conversationId,
            messageId,
            currentReactions
                .map((r) => {'emoji': r.emoji, 'userIds': r.userIds})
                .toList(),
          );
    }

    await MessagesRepository().addReaction(messageId, emoji);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final messages = ref.watch(combinedMessagesProvider(widget.conversationId));
    final convState = ref.watch(conversationsProvider);
    final watchedConv = convState.value
        ?.where((c) => c.id == widget.conversationId)
        .firstOrNull;

    // Merge watched conversation into local state if it changed
    if (watchedConv != null && watchedConv != _conversation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _conversation = watchedConv;
          });
        }
      });
    }

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
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
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
                    if (_conversation != null &&
                        _conversation!.pinnedMessages.isNotEmpty)
                      Builder(
                        builder: (_) {
                          final pinnedIds = _conversation!.pinnedMessages;
                          final latestPinId = pinnedIds.last;
                          try {
                            final msg = messages.firstWhere(
                              (m) => m.id == latestPinId,
                            );
                            return _buildPinnedMessageBar(msg, cs);
                          } catch (e) {
                            // If message not in current list, just show a generic bar
                            return _buildPinnedMessageBar(
                              MessageModel(
                                id: latestPinId,
                                conversationId: widget.conversationId,
                                senderId: '',
                                content: 'Pinned Message',
                                type: MessageType.text,
                                createdAt: DateTime.now(),
                                attachments: const [],
                                reactions: const [],
                              ),
                              cs,
                            );
                          }
                        },
                      ),
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
                              child: ScrollablePositionedList.builder(
                                itemScrollController: _itemScrollController,
                                itemPositionsListener: _itemPositionsListener,
                                itemCount: messages.length,
                                reverse: true,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 12,
                                ),
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
                    if (_isPendingDirectChat &&
                        (!_isPendingCreator || messages.isNotEmpty))
                      _buildPendingInviteBanner(cs),
                    if (isOtherTyping) _buildTypingIndicator(cs),
                    if (_replyToMessage != null) _buildReplyBanner(cs),
                    if (_isAnnouncementGroup && !_isCurrentUserAdmin)
                      _buildAnnouncementNotice(cs),
                    if (_canSendMessages(messages))
                      _buildMessageInput(theme, cs),
                  ],
                ),
                if (_showReactionOverlay) _buildReactionOverlay(context, cs),
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
          ),
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
          color: cs.surfaceContainerHigh.withValues(alpha: 0.8),
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
    final theme = Theme.of(context);
    if (_isPendingCreator) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Waiting for accepted invitation...',
          textAlign: TextAlign.center,
          //italic text
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
          PopupMenuButton<String>(
            icon: Icon(
              LucideIcons.ellipsisVertical,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
            onSelected: (value) {
              if (value == 'copy') _copySelected();
              if (value == 'pin') _pinSelected();
              if (value == 'favorite') _toggleFavoriteSelected();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(LucideIcons.copy, size: 20),
                    SizedBox(width: 12),
                    Text('Copy'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'favorite',
                child: Row(
                  children: [
                    Icon(LucideIcons.star, size: 20),
                    SizedBox(width: 12),
                    Text('Favorite'),
                  ],
                ),
              ),
              if (_selectedMessageIds.length == 1)
                const PopupMenuItem(
                  value: 'pin',
                  child: Row(
                    children: [
                      Icon(LucideIcons.pin, size: 20),
                      SizedBox(width: 12),
                      Text('Pin'),
                    ],
                  ),
                ),
            ],
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

    final repo = ref.read(messagesRepositoryProvider);
    final success = await repo.clearChat(widget.conversationId);
    if (!mounted) return;

    if (success) {
      ref
          .read(localMessagesProvider.notifier)
          .clearMessages(widget.conversationId);
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

    final duration = enable ? 604800 : 0;
    final repo = ref.read(messagesRepositoryProvider);
    final success = await repo.updateDisappearingMessages(
      widget.conversationId,
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

  Widget _buildPinnedMessageBar(MessageModel msg, ColorScheme cs) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _scrollToMessage(msg.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.pin, size: 16, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg.content ?? (msg.attachments.isNotEmpty ? 'Attachment' : ''),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.list, size: 16),
              onPressed: () async {
                final selectedId = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PinnedMessagesScreen(conversation: _conversation!),
                  ),
                );
                if (selectedId != null) {
                  _scrollToMessage(selectedId);
                }
              },
            ),
          ],
        ),
      ),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 0.5,
          color: Theme.of(context).dividerColor.withValues(alpha: 0.7),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 0.5,
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedMessageIds.contains(msg.id);
    final isAnnouncement = _isAnnouncementGroup;
    final isDirectChat = _conversation?.type == ConversationType.direct;

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

    final showAvatar = !isMe && !isPartOfGroupBelow;

    final bubbleColor = isAnnouncement
        ? cs.surfaceContainerHigh
        : (isMe
              ? cs.primary
              : cs.surfaceContainerHighest.withValues(
                  alpha: isDark ? 0.4 : 1.0,
                ));

    final textColor = isAnnouncement
        ? cs.onSurface
        : (isMe ? cs.onPrimary : cs.onSurfaceVariant);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: isSelected
            ? cs.primary.withValues(alpha: 0.12)
            : msg.id == _highlightedMessageId
            ? cs.primaryContainer.withValues(alpha: 0.6)
            : Colors.transparent,
        padding: EdgeInsets.only(
          top: isPartOfGroupAbove ? 1 : 4,
          bottom: isPartOfGroupBelow ? 1 : 4,
        ),
        child: CompositedTransformTarget(
          link: isSelected && _selectedMessageIds.length == 1
              ? _selectedMessageLayerLink
              : LayerLink(),
          child: _SwipeToReply(
            onReply: () => _onReply(msg),
            child: Row(
              mainAxisAlignment: isAnnouncement
                  ? MainAxisAlignment.center
                  : isMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isAnnouncement && !isMe && !isDirectChat) ...[
                  const SizedBox(width: 8),
                  if (showAvatar)
                    _buildAvatar(msg, cs)
                  else
                    const SizedBox(width: 28),
                  const SizedBox(width: 8),
                ] else if (isDirectChat && !isMe) ...[
                  const SizedBox(width: 12),
                ],
                Flexible(
                  child: Column(
                    crossAxisAlignment: isAnnouncement
                        ? CrossAxisAlignment.center
                        : isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // Header for group chat names
                      if (!isMe &&
                          !isDirectChat &&
                          !isPartOfGroupAbove &&
                          !isAnnouncement)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, left: 4),
                          child: Text(
                            msg.sender != null
                                ? '${msg.sender!.firstName} ${msg.sender!.lastName}'
                                : 'Member',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ),

                      // Footers for groups or last message in group
                      Container(
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.sizeOf(context).width *
                              (isAnnouncement ? 0.84 : 0.72),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                              isAnnouncement
                                  ? 18
                                  : (isMe ? 18 : (isPartOfGroupAbove ? 4 : 18)),
                            ),
                            topRight: Radius.circular(
                              isAnnouncement
                                  ? 18
                                  : (!isMe
                                        ? 18
                                        : (isPartOfGroupAbove ? 4 : 18)),
                            ),
                            bottomLeft: Radius.circular(
                              isAnnouncement
                                  ? 18
                                  : (isMe ? 18 : (isPartOfGroupBelow ? 4 : 18)),
                            ),
                            bottomRight: Radius.circular(
                              isAnnouncement
                                  ? 18
                                  : (!isMe
                                        ? 18
                                        : (isPartOfGroupBelow ? 4 : 18)),
                            ),
                          ),
                          boxShadow: [
                            if (!isAnnouncement)
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
                            if (msg.replyToMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildReplyContext(
                                  msg.replyToMessage!,
                                  isMe,
                                  cs,
                                ),
                              ),
                            if (msg.attachments.any((a) => a.type == 'image'))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var attachment
                                        in msg.attachments.where(
                                          (a) => a.type == 'image',
                                        ))
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            final messagesForImages = ref.read(
                                              combinedMessagesProvider(
                                                widget.conversationId,
                                              ),
                                            );
                                            final allImageUrls =
                                                messagesForImages
                                                    .expand(
                                                      (m) => m.attachments,
                                                    )
                                                    .where(
                                                      (a) => a.type == 'image',
                                                    )
                                                    .map((a) => a.url)
                                                    .toList();
                                            final clickedIndex = allImageUrls
                                                .indexOf(attachment.url);
                                            final initialIndex =
                                                clickedIndex >= 0
                                                ? clickedIndex
                                                : 0;

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ImagePreviewScreen(
                                                  imageUrls:
                                                      allImageUrls.isEmpty
                                                      ? [attachment.url]
                                                      : allImageUrls,
                                                  initialIndex: initialIndex,
                                                  heroTag:
                                                      'msg_${msg.id}_${attachment.url}',
                                                ),
                                              ),
                                            );
                                          },
                                          child: Hero(
                                            tag:
                                                'msg_${msg.id}_${attachment.url}',
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child:
                                                  attachment.url.startsWith(
                                                    'http',
                                                  )
                                                  ? CachedNetworkImage(
                                                      imageUrl: attachment.url,
                                                      cacheManager: CacheManagers
                                                          .messageCacheManager,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (
                                                            context,
                                                            url,
                                                          ) => Container(
                                                            height: 200,
                                                            width:
                                                                double.infinity,
                                                            color: cs
                                                                .surfaceContainerHighest,
                                                            child: const Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            ),
                                                          ),
                                                      errorWidget:
                                                          (
                                                            context,
                                                            url,
                                                            error,
                                                          ) => const Icon(
                                                            Icons.broken_image,
                                                            size: 50,
                                                          ),
                                                    )
                                                  : Image.file(
                                                      File(attachment.url),
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => const Icon(
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
                              Linkify(
                                onOpen: (link) async {
                                  final uri = Uri.parse(link.url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                                text: msg.content!,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                                linkStyle: TextStyle(
                                  color: isMe ? Colors.white : cs.primary,
                                  decoration: TextDecoration.underline,
                                ),
                                textAlign: isAnnouncement
                                    ? TextAlign.center
                                    : TextAlign.start,
                              ),
                          ],
                        ),
                      ),
                      if (msg.reactions.isNotEmpty) _buildReactions(msg, cs),

                      if (!isAnnouncement && !isPartOfGroupBelow)
                        Padding(
                          padding: EdgeInsets.only(
                            top: 4,
                            left: isMe ? 0 : 4,
                            right: isMe ? 4 : 0,
                          ),
                          child: Text(
                            DateFormat(
                              'h:mm a',
                            ).format(msg.createdAt.toLocal()),
                            style: TextStyle(
                              fontSize: 10,
                              color: cs.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isMe) const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  replyMsg['content']?.toString() ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
              ),
              if (replyMsg['attachments'] != null &&
                  (replyMsg['attachments'] as List).isNotEmpty) ...[
                const SizedBox(width: 8),
                if ((replyMsg['attachments'] as List)[0]['type'] == 'image')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: (replyMsg['attachments'] as List)[0]['url'],
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          Icon(LucideIcons.image, size: 16, color: textColor),
                    ),
                  )
                else
                  Icon(LucideIcons.fileText, size: 20, color: textColor),
              ],
            ],
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
    final List? attachments = _replyToMessage!['attachments'] as List?;
    final hasAttachment = attachments != null && attachments.isNotEmpty;
    final isImage = hasAttachment && (attachments[0]['type'] == 'image');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.reply, size: 16, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying to...',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _replyToMessage!['content']?.toString() ??
                      (hasAttachment ? 'Attachment' : ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (isImage)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CachedNetworkImage(
                    imageUrl: attachments[0]['url'],
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(color: cs.outlineVariant),
                    errorWidget: (_, _, _) =>
                        const Icon(LucideIcons.image, size: 16),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(LucideIcons.x, size: 20),
            padding: EdgeInsets.zero,
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _pickImage,
            icon: Icon(LucideIcons.plus, color: cs.primary, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? cs.surfaceContainerHigh
                    : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _inputFocusNode,
                maxLines: 5,
                minLines: 1,
                onChanged: (val) {
                  setState(() {});
                  _onTextChanged(val);
                },
                style: theme.textTheme.bodyMedium,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: _isAnnouncementGroup
                      ? 'Write an announcement...'
                      : 'Type a message...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _messageController,
            builder: (context, value, child) {
              final hasText = value.text.trim().isNotEmpty;
              return Container(
                decoration: BoxDecoration(
                  color: hasText ? cs.primary : cs.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: hasText ? _sendMessage : null,
                  icon: Icon(
                    hasText ? LucideIcons.send : LucideIcons.mic,
                    color: hasText
                        ? Colors.white
                        : cs.onSurface.withValues(alpha: 0.5),
                    size: 20,
                  ),
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

class _SwipeToReplyState extends State<_SwipeToReply>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _dragOffset = 0;
  double _baseOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
        )..addListener(() {
          setState(() {
            _dragOffset = _controller.value * _baseOffset;
          });
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: .opaque,
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragOffset = (_dragOffset + details.delta.dx).clamp(0.0, 100.0);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragOffset >= 80) {
          widget.onReply();
        }
        _baseOffset = _dragOffset;
        _controller.reverse(from: 1.0);
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
                child: const Icon(LucideIcons.reply, color: Color(0xFF0066FF)),
              ),
            ),
        ],
      ),
    );
  }
}
