import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'meet.dart';
import 'chat_avatar.dart';
import '../../models/conversation_model.dart';
import '../../models/search_user_model.dart';
import '../../providers/messages_provider.dart';
import '../../repository/messages_repository.dart';
import '../../repository/participant_search_repository.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../widgets/messages_background.dart';
import '../../widgets/messages_button.dart';
import '../../widgets/participant_picker_screen.dart';
import '../../communities/page.dart';
import '../../calendar/widgets/calendar_home_screen.dart';
import '../../activity/widgets/activity_screen.dart';

class ChatItemWidget extends ConsumerWidget {
  final ConversationModel item;
  final VoidCallback onPress;

  const ChatItemWidget({super.key, required this.item, required this.onPress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == .dark;
    final currentUserId = ref.watch(authProvider).user?.id ?? '';
    final title = item.getDisplayTitle(currentUserId);
    final unreadCount = item.unreadCountFor(currentUserId);
    final isFavorite = ref.watch(
      favoriteConversationIdsProvider.select((ids) => ids.contains(item.id)),
    );
    final lastMessage = switch (item.lastMessage) {
      Map m => _buildLastMessageLabel(m),
      String s => s,
      _ => '',
    };
    final lastMessageTime = item.updatedAt;

    return InkWell(
      onTap: onPress,
      child: Container(
        height: 80,
        padding: const .symmetric(horizontal: 16),
        child: Row(
          children: [
            Padding(
              padding: const .only(right: 16),
              child: ChatAvatar(
                conversation: item,
                currentUserId: currentUserId,
                size: 56,
              ),
            ),
            Expanded(
              child: Container(
                padding: const .only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDarkMode
                          ? const Color(0xFF202020)
                          : const Color(0xFFF0F0F0),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .start,
                  children: [
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: .normal,
                              color: isDarkMode
                                  ? const Color(0xFFE8EAED)
                                  : const Color(0xFF111111),
                            ),
                            maxLines: 1,
                            overflow: .ellipsis,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatTime(lastMessageTime),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: unreadCount > 0
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isDarkMode
                                    ? (unreadCount > 0
                                          ? const Color(0xFFE8EAED)
                                          : const Color(0xFF9CA3AF))
                                    : (unreadCount > 0
                                          ? const Color(0xFF111111)
                                          : const Color(0xFF6B7280)),
                              ),
                            ),
                            if (unreadCount > 0) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0066FF),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (isFavorite) ...[
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            lastMessage,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isDarkMode
                                  ? (unreadCount > 0
                                        ? const Color(0xFFE8EAED)
                                        : const Color(0xFF9AA0A6))
                                  : (unreadCount > 0
                                        ? const Color(0xFF111111)
                                        : const Color(0xFFA0A3A8)),
                            ),
                            maxLines: 1,
                            overflow: .ellipsis,
                          ),
                        ),
                      ],
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

  static String _buildLastMessageLabel(Map<dynamic, dynamic> message) {
    final content = message['content']?.toString().trim() ?? '';
    if (content.isNotEmpty) return content;

    final attachments = message['attachments'];
    if (attachments is List && attachments.isNotEmpty) {
      final first = attachments.first;
      if (first is Map && first['type'] == 'image') {
        return 'Photo';
      }
      return 'Attachment';
    }

    return switch (message['type']?.toString()) {
      'image' => 'Photo',
      'file' => 'Attachment',
      _ => 'New message',
    };
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}

class MessagesHomeScreen extends ConsumerStatefulWidget {
  final Function(int)? onTabChange;
  const MessagesHomeScreen({super.key, this.onTabChange});

  @override
  ConsumerState<MessagesHomeScreen> createState() => _MessagesHomeScreenState();
}

class _MessagesHomeScreenState extends ConsumerState<MessagesHomeScreen> {
  final MessagesRepository _messagesRepository = MessagesRepository();
  final ParticipantSearchRepository _participantSearchRepository =
      ParticipantSearchRepository();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  String _searchQuery = '';
  int _selectedTabIndex = 0;
  bool _showAdvancedFilters = false;
  String _activeFilter = 'all';
  bool _isSearchingUsers = false;
  List<SearchUserModel> _searchedUsers = const [];

  @override
  void initState() {
    super.initState();
    // Socket auto-connects in ChatSocketNotifier.build() via Future.microtask
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _goToMeet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MeetScreen()),
    );
  }

  Future<void> _openParticipantSearch() async {
    final selected = await Navigator.of(context).push<List<SearchUserModel>>(
      MaterialPageRoute(
        builder: (_) => const ParticipantPickerScreen(
          title: 'Start Conversation',
          submitLabel: 'Create',
        ),
      ),
    );

    if (!mounted || selected == null || selected.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    ConversationModel? conversation;

    if (selected.length > 1) {
      final details = await _showGroupDetailsDialog(selected);
      if (!mounted || details == null) return;

      conversation = await _messagesRepository.createConversation(
        selected.map((user) => user.id).toList(),
        name: details.name,
      );

      if (conversation != null && details.avatarDataUri != null) {
        conversation = await _messagesRepository.updateConversation(
              conversation.id,
              avatar: details.avatarDataUri,
            ) ??
            conversation;
      }
    } else {
      conversation = await _messagesRepository.createConversation(
        selected.map((user) => user.id).toList(),
      );
    }

    if (!mounted) return;

    if (conversation == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to create conversation')),
      );
      return;
    }

    ref.read(conversationsProvider.notifier).loadConversations();
    context.push('/chat/${conversation.id}');
  }

  Future<({String name, String? avatarDataUri})?> _showGroupDetailsDialog(
    List<SearchUserModel> selected,
  ) async {
    final nameController = TextEditingController(
      text: selected.map((user) => user.displayName).take(3).join(', '),
    );
    XFile? selectedImage;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('New Group'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Group name',
                    hintText: 'Enter group name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Group icon',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final image = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image == null) return;
                    setModalState(() => selectedImage = image);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            selectedImage == null
                                ? 'Choose an image for the group icon'
                                : selectedImage!.name,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                Navigator.pop(ctx, true);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || nameController.text.trim().isEmpty) {
      return null;
    }

    String? avatarDataUri;
    if (selectedImage != null) {
      final bytes = await selectedImage!.readAsBytes();
      final lower = selectedImage!.name.toLowerCase();
      final mimeType = lower.endsWith('.png')
          ? 'image/png'
          : lower.endsWith('.webp')
          ? 'image/webp'
          : 'image/jpeg';
      avatarDataUri = 'data:$mimeType;base64,${base64Encode(bytes)}';
    }

    return (name: nameController.text.trim(), avatarDataUri: avatarDataUri);
  }

  Future<void> _createDirectChat(SearchUserModel user) async {
    final messenger = ScaffoldMessenger.of(context);
    final conversation = await _messagesRepository.createConversation([user.id]);
    if (!mounted) return;
    if (conversation == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to open conversation')),
      );
      return;
    }
    ref.read(conversationsProvider.notifier).loadConversations();
    context.push('/chat/${conversation.id}');
  }

  void _scheduleUserSearch(String value) {
    _searchDebounce?.cancel();
    if (_selectedTabIndex != 0 || value.trim().isEmpty) {
      setState(() {
        _searchedUsers = const [];
        _isSearchingUsers = false;
      });
      return;
    }

    setState(() => _isSearchingUsers = true);
    _searchDebounce = Timer(const Duration(milliseconds: 320), () async {
      try {
        final currentUserId = ref.read(authProvider).user?.id ?? '';
        final users = await _participantSearchRepository.searchUsers(value);
        if (!mounted) return;
        setState(() {
          _searchedUsers = users
              .where((user) => user.id != currentUserId)
              .toList();
          _isSearchingUsers = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _searchedUsers = const [];
          _isSearchingUsers = false;
        });
      }
    });
  }

  void _goToChat(ConversationModel item) {
    context.push('/chat/${item.id}');
  }

  void _toggleFilters() {
    setState(() {
      _showAdvancedFilters = !_showAdvancedFilters;
      if (!_showAdvancedFilters) _activeFilter = 'all';
    });
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 1:
        return CommunitiesPage(
          onBack: () => setState(() => _selectedTabIndex = 0),
        );
      case 2:
        return CalendarHomeScreen(
          isEmbedded: true,
          onBack: () => setState(() => _selectedTabIndex = 0),
        );
      case 3:
        return ActivityScreen(
          isEmbedded: true,
          onBack: () => setState(() => _selectedTabIndex = 0),
        );
      default:
        return _buildChatList();
    }
  }

  Widget _buildChatList() {
    final conversationsAsync = ref.watch(conversationsProvider);
    final isDarkMode = Theme.of(context).brightness == .dark;
    final currentUserId = ref.watch(authProvider).user?.id ?? '';
    final favorites = ref.watch(favoriteConversationIdsProvider);

    return conversationsAsync.when(
      data: (conversations) {
        final filteredChats = conversations.where((chat) {
          final title = chat.getDisplayTitle(currentUserId);
          final matchesSearch = title.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

          if (_searchQuery.isNotEmpty && !matchesSearch) return false;

          if (_activeFilter == 'unread') {
            return chat.unreadCountFor(currentUserId) > 0;
          }
          if (_activeFilter == 'favs') {
            return favorites.contains(chat.id);
          }
          if (_activeFilter == 'groups') {
            return chat.type != ConversationType.direct;
          }
          return true;
        }).toList();
        if (filteredChats.isEmpty &&
            _searchedUsers.isEmpty &&
            _searchQuery.isNotEmpty &&
            !_isSearchingUsers) {
          return Padding(
            padding: const .only(top: 40),
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: isDarkMode ? Colors.white24 : Colors.black12,
                ),
                const SizedBox(height: 16),
                Text(
                  'No chats found for "$_searchQuery"',
                  style: GoogleFonts.inter(
                    color: isDarkMode ? Colors.white54 : Colors.black45,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(conversationsProvider.notifier).loadConversations(),
          child: ListView(
            controller: _scrollController,
            padding: const .only(top: 0, bottom: 100),
            children: [
              if (_searchQuery.isNotEmpty) ...[
                if (_isSearchingUsers)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_searchedUsers.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'People',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: .w700,
                        color: isDarkMode
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  for (final user in _searchedUsers)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            user.avatar != null && user.avatar!.isNotEmpty
                            ? NetworkImage(user.avatar!)
                            : null,
                        child: user.avatar == null || user.avatar!.isEmpty
                            ? Text(user.displayName.substring(0, 1).toUpperCase())
                            : null,
                      ),
                      title: Text(user.displayName),
                      subtitle: Text(user.email),
                      trailing: const Icon(Icons.chat_bubble_outline),
                      onTap: () => _createDirectChat(user),
                    ),
                ],
                if (filteredChats.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'Chats',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: .w700,
                        color: isDarkMode
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
              ],
              for (final item in filteredChats)
                ChatItemWidget(item: item, onPress: () => _goToChat(item)),
            ],
          ),
        );
      },
      loading: () => Skeletonizer(
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) => ListTile(
            leading: const CircleAvatar(radius: 28),
            title: Container(width: 150, height: 16, color: Colors.grey),
            subtitle: Container(width: 250, height: 12, color: Colors.grey),
          ),
        ),
      ),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildSearchAndFilters() {
    final isDarkMode = Theme.of(context).brightness == .dark;
    final conversations = ref.watch(conversationsProvider).value ?? const [];
    final currentUserId = ref.watch(authProvider).user?.id ?? '';
    final favorites = ref.watch(favoriteConversationIdsProvider);
    final unreadChatsCount = conversations
        .where((chat) => chat.unreadCountFor(currentUserId) > 0)
        .length;
    final favoriteChatsCount = conversations
        .where((chat) => favorites.contains(chat.id))
        .length;
    final groupChatsCount = conversations
        .where((chat) => chat.type != ConversationType.direct)
        .length;

    return Container(
      padding: const .only(bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Bar
          Container(
            padding: const .fromLTRB(16, 12, 16, 8),
            child: GestureDetector(
              onTap: () => _searchFocusNode.requestFocus(),
              child: Container(
                height: 46,
                padding: const .symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white10 : const Color(0xFFF3F4F6),
                  borderRadius: .circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      size: 20,
                      color: Color(0xFF9AA0A6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                          _scheduleUserSearch(val);
                        },
                        decoration: InputDecoration(
                          hintText: _selectedTabIndex == 1
                              ? 'Search communities'
                              : 'Search or start a new chat',
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF9AA0A6),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: .zero,
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Color(0xFF9AA0A6),
                                  ),
                                )
                              : null,
                          suffixIconConstraints: const BoxConstraints(
                            minHeight: 18,
                            minWidth: 18,
                          ),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF111111),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const .symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: _showAdvancedFilters
                  ? [
                      _buildChip(
                        'All',
                        isActive: _activeFilter == 'all',
                        onTap: () => setState(() => _activeFilter = 'all'),
                      ),
                      _buildChip(
                        'Unread',
                        count: unreadChatsCount > 0 ? '$unreadChatsCount' : null,
                        isActive: _activeFilter == 'unread',
                        onTap: () => setState(() => _activeFilter = 'unread'),
                      ),
                      _buildChip(
                        'Favourites',
                        count: favoriteChatsCount > 0
                            ? '$favoriteChatsCount'
                            : null,
                        isActive: _activeFilter == 'favs',
                        onTap: () => setState(() => _activeFilter = 'favs'),
                      ),
                      _buildChip(
                        'Groups',
                        count: groupChatsCount > 0 ? '$groupChatsCount' : null,
                        isActive: _activeFilter == 'groups',
                        onTap: () => setState(() => _activeFilter = 'groups'),
                      ),
                    ]
                  : [
                      _buildChip(
                        'Chat',
                        icon: Icons.chat_bubble,
                        isActive: _selectedTabIndex == 0,
                        onTap: () => setState(() => _selectedTabIndex = 0),
                      ),
                      _buildChip(
                        'Communities',
                        icon: Icons.hub_outlined,
                        isActive: _selectedTabIndex == 1,
                        onTap: () => setState(() => _selectedTabIndex = 1),
                      ),
                      _buildChip(
                        'Calendar',
                        icon: Icons.calendar_month_outlined,
                        isActive: _selectedTabIndex == 2,
                        onTap: () => setState(() => _selectedTabIndex = 2),
                      ),
                      _buildChip(
                        'Activity',
                        icon: Icons.notifications_none_outlined,
                        isActive: _selectedTabIndex == 3,
                        onTap: () => setState(() => _selectedTabIndex = 3),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == .dark;

    return MessagesBackground(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const .symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          margin: const .only(right: 12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE3E8C8),
                            shape: .circle,
                          ),
                          alignment: .center,
                          child: Text(
                            'PV',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF3A5A30),
                              fontWeight: .w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          _selectedTabIndex == 1
                              ? 'Communities'
                              : _selectedTabIndex == 2
                              ? 'Calendar'
                              : _selectedTabIndex == 3
                              ? 'Activity'
                              : 'Chat',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: .bold,
                            color: isDarkMode
                                ? const Color(0xFFE8EAED)
                                : const Color(0xFF111111),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        MessagesButton(
                          text: 'Meet',
                          height: 36,
                          icon: Icons.videocam,
                          onPressed: _goToMeet,
                        ),
                        const SizedBox(width: 12),
                        if (_selectedTabIndex == 0)
                          GestureDetector(
                            onTap: _openParticipantSearch,
                            child: Icon(
                              Icons.edit_square,
                              size: 26,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                        if (_selectedTabIndex == 0) const SizedBox(width: 12),
                        if (_selectedTabIndex == 0)
                          GestureDetector(
                            onTap: _toggleFilters,
                            child: Icon(
                              _showAdvancedFilters
                                  ? Icons.filter_list_off
                                  : Icons.filter_list,
                              size: 26,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Search and Tabs
              _buildSearchAndFilters(),

              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    String label, {
    String? count,
    bool isActive = false,
    VoidCallback? onTap,
    IconData? icon,
  }) {
    final isDarkMode = Theme.of(context).brightness == .dark;

    return Padding(
      padding: const .only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: .circular(20),
          child: Container(
            padding: const .symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                      begin: .centerLeft,
                      end: .centerRight,
                    )
                  : null,
              color: isActive
                  ? null
                  : (isDarkMode ? Colors.white10 : const Color(0xFFF3F4F6)),
              borderRadius: .circular(20),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0066FF).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const .new(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: isActive
                        ? Colors.white
                        : (isDarkMode
                              ? Colors.white70
                              : const Color(0xFF64748B)),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isActive ? .w600 : .w500,
                    color: isActive
                        ? Colors.white
                        : (isDarkMode
                              ? const Color(0xFFE8EAED)
                              : const Color(0xFF64748B)),
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    count,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isActive
                          ? (isDarkMode ? Colors.white70 : Colors.white60)
                          : (isDarkMode
                                ? Colors.white38
                                : const Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
