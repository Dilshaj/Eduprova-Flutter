import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eduprova/theme/theme.dart';
import 'package:eduprova/theme/messages_theme_extension.dart';

import 'package:eduprova/core/navigation/app_routes.dart';
import 'chat_avatar.dart';
import '../../models/conversation_model.dart';
import '../../models/search_user_model.dart';
import '../../providers/messages_provider.dart';
import '../../repository/messages_repository.dart';
import '../../repository/participant_search_repository.dart';
import '../../../auth/providers/auth_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../calendar/widgets/calendar_home_screen.dart';
import '../../communities/page.dart';
import '../../widgets/messages_background.dart';

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
    final isUnread = unreadCount > 0;
    
    final lastMessage = switch (item.lastMessage) {
      Map m => _buildLastMessageLabel(m, currentUserId),
      String s => s,
      _ => '',
    };
    final lastMessageTime = item.updatedAt;

    return InkWell(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            ChatAvatar(
              conversation: item,
              currentUserId: currentUserId,
              size: 56,
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: msgTheme.chatTitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                      color: isUnread ? msgTheme.chatTitleColor : msgTheme.chatSubtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Time & Badge
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(lastMessageTime),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: msgTheme.chatTimeColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                if (isUnread)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0066FF),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _buildLastMessageLabel(Map<dynamic, dynamic> message, String currentUserId) {
    final content = message['content']?.toString().trim() ?? '';
    final isMe = message['senderId'] == currentUserId;
    final prefix = isMe ? 'You: ' : '';
    if (content.isNotEmpty) return '$prefix$content';
    final attachments = message['attachments'];
    if (attachments is List && attachments.isNotEmpty) {
      final first = attachments.first;
      if (first is Map && first['type'] == 'image') return '$prefix📷 Photo';
      return '$prefix📎 Attachment';
    }
    return switch (message['type']?.toString()) {
      'image' => '$prefix📷 Photo',
      'file' => '$prefix📎 Attachment',
      _ => '$prefix New message',
    };
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0 && now.day == time.day) {
      final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
      final ampm = time.hour >= 12 ? 'pm' : 'am';
      return '$hour:${time.minute.toString().padLeft(2, '0')} $ampm';
    } else if (diff.inDays < 7) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[time.weekday - 1];
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

class _MessagesHomeScreenState extends ConsumerState<MessagesHomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  late TabController _mainTabController;
  int _selectedTabIndex = 0;
  String _searchQuery = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mainTabController.dispose();
    super.dispose();
  }

  void _goToMeet() {
    context.push(AppRoutes.meet);
  }

  @override
  Widget build(BuildContext context) {
    final msgTheme = Theme.of(context).extension<MessagesThemeExtension>()!;
    final appTheme = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return MessagesBackground(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Precise Image 1 background
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(msgTheme, appTheme),
              _buildSearch(msgTheme),
              _buildCategoryTabs(msgTheme, colorScheme),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(MessagesThemeExtension msgTheme, AppDesignExtension appTheme) {
    final title = switch (_selectedTabIndex) {
      1 => 'Communities',
      2 => 'Calendar',
      _ => 'Messages',
    };
    final showMeet = _selectedTabIndex == 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: msgTheme.titleColor,
            ),
          ),
          if (showMeet)
            InkWell(
              onTap: _goToMeet,
              borderRadius: BorderRadius.circular(26),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0066FF).withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.video, color: Colors.white, size: 20),
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
        ],
      ),
    );
  }

  Widget _buildSearch(MessagesThemeExtension msgTheme) {
    final hintText = switch (_selectedTabIndex) {
      1 => 'Search communities',
      2 => 'Search calendar',
      _ => 'Search conversations',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(LucideIcons.search, size: 22, color: msgTheme.searchBarIconColor),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: GoogleFonts.inter(color: msgTheme.searchBarTextColor, fontSize: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(MessagesThemeExtension msgTheme, ColorScheme colorScheme) {
    final List<({String label, IconData icon})> categories = [
      (label: 'Chat', icon: LucideIcons.messageCircle),
      (label: 'Community', icon: LucideIcons.users),
      (label: 'Calendar', icon: LucideIcons.calendar),
    ];

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < categories.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i == categories.length - 1 ? 0 : 8,
                  left: i == 0 ? 0 : 8,
                ),
                child: _buildCategoryItem(categories, i, msgTheme),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(List<({String label, IconData icon})> categories, int index, MessagesThemeExtension msgTheme) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: isSelected ? const EdgeInsets.only(bottom: 6) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF0066FF).withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected)
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                    ).createShader(bounds),
                    child: Icon(
                      categories[index].icon,
                      size: 24,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(
                    categories[index].icon,
                    size: 22,
                    color: const Color(0xFF4A4A4A).withValues(alpha: 0.7),
                  ),
                const SizedBox(height: 4),
                if (isSelected)
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                    ).createShader(bounds),
                    child: Text(
                      categories[index].label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Text(
                    categories[index].label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4A4A4A),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return switch (_selectedTabIndex) {
      0 => _buildChatList(),
      1 => CommunitiesPage(
          searchQuery: _searchQuery,
          onBack: () => setState(() => _selectedTabIndex = 0),
        ),
      2 => CalendarHomeScreen(
          isEmbedded: true,
          onBack: () => setState(() => _selectedTabIndex = 0),
        ),
      _ => _buildChatList(),
    };
  }

  Widget _buildChatList() {
    final conversationsAsync = ref.watch(conversationsProvider);
    final currentUserId = ref.watch(authProvider).user?.id ?? '';

    return conversationsAsync.when(
      data: (conversations) {
        final filtered = conversations.where((c) => 
          c.getDisplayTitle(currentUserId).toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No messages found'));
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(conversationsProvider.notifier).loadConversations(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 100),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => Divider(
              indent: 84,
              height: 1,
              color: Colors.black.withValues(alpha: 0.05),
            ),
            itemBuilder: (context, index) => ChatItemWidget(
              item: filtered[index],
              onPress: () => context.push('/chat/${filtered[index].id}'),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }
}
