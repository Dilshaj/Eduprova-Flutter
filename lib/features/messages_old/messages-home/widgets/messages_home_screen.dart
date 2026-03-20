import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../../communities/widgets/communities_groups.dart';
import '../../communities/widgets/new_community_dialog.dart';
import '../../calendar/widgets/calendar_home_screen.dart';
import '../../activity/widgets/activity_screen.dart';
import '../../communities/widgets/community_overview.dart';
import '../../communities/utils/community_utils.dart';

class ChatItemWidget extends ConsumerWidget {
  final ConversationModel item;
  final VoidCallback onPress;

  const ChatItemWidget({super.key, required this.item, required this.onPress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == .dark;
    final currentUserId = ref.watch(authProvider).user?.id ?? '';
    final title = item.getDisplayTitle(currentUserId);
    final lastMessage = switch (item.lastMessage) {
      Map m => m['content'] ?? '',
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
                        Text(
                          _formatTime(lastMessageTime),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDarkMode
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDarkMode
                            ? const Color(0xFF9AA0A6)
                            : const Color(0xFFA0A3A8),
                      ),
                      maxLines: 1,
                      overflow: .ellipsis,
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

  List<Map<String, dynamic>> communities = List.from(initialCommunities);

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
    final conversation = await _messagesRepository.createConversation(
      selected.map((user) => user.id).toList(),
      name: selected.length > 1
          ? selected.map((user) => user.displayName).take(3).join(', ')
          : null,
    );

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

  void _addNewCommunity(Map<String, dynamic> data) {
    if (data.containsKey('name')) {
      final name = data['name'] as String;
      final description = data['description'] as String?;

      setState(() {
        communities.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': name,
          'description': description,
          'members': '1 member',
          'type': 'new',
          'icon': Icons.groups_outlined,
          'channels': [
            {
              'id': 'c_ann_${DateTime.now().millisecondsSinceEpoch}',
              'name': 'Announcements',
            },
            {
              'id': 'c_gen_${DateTime.now().millisecondsSinceEpoch}',
              'name': 'General',
            },
          ],
        });
      });
    }
  }

  void _updateCommunityChannels(
    String communityId,
    List<Map<String, dynamic>> newChannels,
  ) {
    setState(() {
      final index = communities.indexWhere((c) => c['id'] == communityId);
      if (index != -1) {
        communities[index]['channels'] = newChannels;
      }
    });
  }

  Future<void> _openCreateCommunity() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const NewCommunityDialog(),
    );
    if (result != null) {
      final newCommunity = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': result['name'],
        'description': result['description'],
        'members': '1 member',
        'type': 'new',
        'icon': Icons.groups_outlined,
        'channels': [
          {
            'id': 'c_ann_${DateTime.now().millisecondsSinceEpoch}',
            'name': 'Announcements',
          },
          {
            'id': 'c_gen_${DateTime.now().millisecondsSinceEpoch}',
            'name': 'General',
          },
        ],
      };

      setState(() {
        communities.insert(0, newCommunity);
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityOverviewScreen(
              community: newCommunity,
              onGroupsUpdated: (updatedChannels) {
                _updateCommunityChannels(
                  newCommunity['id'] as String,
                  updatedChannels,
                );
              },
            ),
          ),
        );
      }
    }
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 1:
        return CommunitiesGroupsScreen(
          isEmbedded: true,
          communities: communities,
          onAddNewCommunity: _addNewCommunity,
          onUpdateGroups: _updateCommunityChannels,
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

    return conversationsAsync.when(
      data: (conversations) {
        final filteredChats = conversations.where((chat) {
          final currentUserId = ref.watch(authProvider).user?.id ?? '';
          final title = chat.getDisplayTitle(currentUserId);
          final matchesSearch = title.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

          if (_searchQuery.isNotEmpty && !matchesSearch) return false;

          if (_activeFilter == 'unread') {
            // Check unread count logic if available
            return false;
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
                        count: '142',
                        isActive: _activeFilter == 'unread',
                        onTap: () => setState(() => _activeFilter = 'unread'),
                      ),
                      _buildChip(
                        'Favourites',
                        isActive: _activeFilter == 'favs',
                        onTap: () => setState(() => _activeFilter = 'favs'),
                      ),
                      _buildChip(
                        'Groups',
                        count: '34',
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
                        if (_selectedTabIndex == 1) ...[
                          GestureDetector(
                            onTap: _openCreateCommunity,
                            child: Icon(
                              Icons.add_circle_outline,
                              size: 28,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
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
