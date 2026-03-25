import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:eduprova/theme/theme_model.dart';
import 'package:eduprova/theme/messages_theme_extension.dart';

import '../../meet/meet.dart';
import 'chat_avatar.dart';
import '../../models/conversation_model.dart';
import '../../models/search_user_model.dart';
import '../../providers/messages_provider.dart';
import '../../repository/messages_repository.dart';
import '../../repository/participant_search_repository.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../widgets/messages_background.dart';
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
    final msgTheme = Theme.of(context).extension<MessagesThemeExtension>()!;
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ChatAvatar(
                conversation: item,
                currentUserId: currentUserId,
                size: 56,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: msgTheme.chatTitleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                                    : FontWeight.w500,
                                color: msgTheme.chatTimeColor,
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
                                  color: msgTheme.unreadBadgeBackground,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: msgTheme.unreadBadgeTextColor,
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
                            LucideIcons.star,
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
                              color: msgTheme.chatSubtitleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
      final period = time.hour < 12 ? 'am' : 'pm';
      final hour = time.hour == 0
          ? 12
          : (time.hour > 12 ? time.hour - 12 : time.hour);
      return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
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

class _MessagesHomeScreenState extends ConsumerState<MessagesHomeScreen>
    with TickerProviderStateMixin {
  final MessagesRepository _messagesRepository = MessagesRepository();
  final ParticipantSearchRepository _participantSearchRepository =
      ParticipantSearchRepository();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  late TabController _defaultTabController;
  late TabController _filterTabController;
  late TabController _activeController;

  Timer? _searchDebounce;
  String _searchQuery = '';
  int _selectedTabIndex = 0;
  bool _showAdvancedFilters = false;
  bool _isSearchingUsers = false;
  List<SearchUserModel> _searchedUsers = const [];

  @override
  void initState() {
    super.initState();
    _defaultTabController = TabController(length: 4, vsync: this);
    _filterTabController = TabController(length: 4, vsync: this);
    _activeController = _defaultTabController;

    _defaultTabController.addListener(() {
      if (!mounted) return;
      setState(() {
        _selectedTabIndex = _defaultTabController.index;
      });
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _defaultTabController.dispose();
    _filterTabController.dispose();
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

      conversation = await _messagesRepository.createConversation([
        for (var user in selected) user.id,
      ], name: details.name);

      if (conversation != null && details.avatarDataUri != null) {
        conversation =
            await _messagesRepository.updateConversation(
              conversation.id,
              avatar: details.avatarDataUri,
            ) ??
            conversation;
      }
    } else {
      conversation = await _messagesRepository.createConversation([
        for (var user in selected) user.id,
      ]);
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
                            LucideIcons.image,
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
    final conversation = await _messagesRepository.createConversation([
      user.id,
    ]);
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
          _searchedUsers = [
            for (var user in users)
              if (user.id != currentUserId) user,
          ];
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
      _activeController = _showAdvancedFilters
          ? _filterTabController
          : _defaultTabController;
      if (!_showAdvancedFilters) {
        _filterTabController.animateTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final msgTheme = Theme.of(context).extension<MessagesThemeExtension>()!;
    final appTheme = Theme.of(context).extension<AppDesignExtension>()!;

    return MessagesBackground(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: msgTheme.scaffoldBackground,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(msgTheme, appTheme),
              _buildSearchBar(msgTheme),
              _buildTabs(msgTheme),
              Expanded(child: _buildTabBarView()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    MessagesThemeExtension msgTheme,
    AppDesignExtension appTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Messages',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: msgTheme.titleColor,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: _goToMeet,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: appTheme.buyNowGradient,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.video,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Meet',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (_selectedTabIndex == 0) ...[
                GestureDetector(
                  onTap: _openParticipantSearch,
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedAddTeam02,
                    size: 24,
                    color: msgTheme.titleColor,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _toggleFilters,
                  child: Icon(
                    Icons.filter_list,
                    size: 24,
                    color: msgTheme.titleColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(MessagesThemeExtension msgTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: () => _searchFocusNode.requestFocus(),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: msgTheme.searchBarFillColor,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.search,
                size: 22,
                color: msgTheme.searchBarIconColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    _scheduleUserSearch(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search conversations',
                    hintStyle: GoogleFonts.inter(
                      color: msgTheme.searchBarTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: msgTheme.titleColor,
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Icon(
                    LucideIcons.x,
                    size: 20,
                    color: msgTheme.searchBarIconColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(MessagesThemeExtension msgTheme) {
    final tabs = _showAdvancedFilters
        ? ['All', 'Unread', 'Groups', 'Direct']
        : ['Chat', 'Communities', 'Calendar', 'Activity'];
    final controller = _showAdvancedFilters
        ? _filterTabController
        : _activeController;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => TabBar(
            controller: controller,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: msgTheme.tabSelectedBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            labelColor: msgTheme.tabSelectedTextColor,
            unselectedLabelColor: msgTheme.tabUnselectedTextColor,
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            tabs: [
              for (int i = 0; i < tabs.length; i++)
                Tab(
                  height: 38,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: controller.index == i
                          ? Colors.transparent
                          : msgTheme.searchBarFillColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: controller.index == i
                            ? Colors.transparent
                            : msgTheme.searchBarIconColor.withValues(
                                alpha: 0.1,
                              ),
                        width: 1,
                      ),
                    ),
                    child: Text(tabs[i]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    if (_showAdvancedFilters) {
      return TabBarView(
        controller: _filterTabController,
        children: [
          _buildChatList(filter: 'all'),
          _buildChatList(filter: 'unread'),
          _buildChatList(filter: 'groups'),
          _buildChatList(filter: 'direct'),
        ],
      );
    }
    return TabBarView(
      controller: _defaultTabController,
      children: [
        _buildChatList(filter: 'all'),
        CommunitiesPage(
          onBack: () {
            _defaultTabController.animateTo(0);
          },
        ),
        CalendarHomeScreen(
          isEmbedded: true,
          onBack: () {
            _defaultTabController.animateTo(0);
          },
        ),
        ActivityScreen(
          isEmbedded: true,
          onBack: () {
            _defaultTabController.animateTo(0);
          },
        ),
      ],
    );
  }

  Widget _buildChatList({required String filter}) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final currentUserId = ref.watch(authProvider).user?.id ?? '';
    final favorites = ref.watch(favoriteConversationIdsProvider);
    final msgTheme = Theme.of(context).extension<MessagesThemeExtension>()!;

    return conversationsAsync.when(
      data: (conversations) {
        final filteredChats = [
          for (var chat in conversations)
            if (chat
                .getDisplayTitle(currentUserId)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
              if (filter == 'all' ||
                  (filter == 'unread' &&
                      chat.unreadCountFor(currentUserId) > 0) ||
                  (filter == 'groups' &&
                      chat.type != ConversationType.direct) ||
                  (filter == 'direct' && chat.type == ConversationType.direct))
                chat,
        ];

        final pinnedChats = [
          for (var chat in filteredChats)
            if (favorites.contains(chat.id)) chat,
        ];
        final recentChats = [
          for (var chat in filteredChats)
            if (!favorites.contains(chat.id)) chat,
        ];

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(conversationsProvider.notifier).loadConversations(),
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 10, bottom: 100),
            children: [
              if (_searchQuery.isNotEmpty && _isSearchingUsers)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_searchQuery.isNotEmpty &&
                  _searchedUsers.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'PEOPLE',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: msgTheme.sectionHeaderColor,
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
                    title: Text(
                      user.displayName,
                      style: GoogleFonts.inter(color: msgTheme.chatTitleColor),
                    ),
                    subtitle: Text(
                      user.email,
                      style: GoogleFonts.inter(
                        color: msgTheme.chatSubtitleColor,
                      ),
                    ),
                    trailing: Icon(
                      LucideIcons.messageSquare,
                      color: msgTheme.searchBarIconColor,
                    ),
                    onTap: () => _createDirectChat(user),
                  ),
              ],
              if (pinnedChats.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Text(
                    'PINNED',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: msgTheme.sectionHeaderColor,
                    ),
                  ),
                ),
                for (final item in pinnedChats)
                  ChatItemWidget(item: item, onPress: () => _goToChat(item)),
              ],
              if (recentChats.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Text(
                    'RECENT',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: msgTheme.sectionHeaderColor,
                    ),
                  ),
                ),
                for (final item in recentChats)
                  ChatItemWidget(item: item, onPress: () => _goToChat(item)),
              ],
              if (filteredChats.isEmpty &&
                  _searchQuery.isNotEmpty &&
                  !_isSearchingUsers &&
                  _searchedUsers.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'No chats found',
                      style: GoogleFonts.inter(
                        color: msgTheme.chatSubtitleColor,
                      ),
                    ),
                  ),
                ),
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
}
