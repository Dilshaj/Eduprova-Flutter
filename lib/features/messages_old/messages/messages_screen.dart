import 'package:eduprova/core/navigation/app_routes.dart';
import 'package:eduprova/theme/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../communities/communities_view.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  final List<MessageItem> _messages = [
    MessageItem(
      initiatorInitials: 'VL',
      name: 'Varahanarasimha Logisa',
      lastMessage: 'Shared: MacBook Pro 16_ - 22...',
      time: '5:38 PM',
      // color: AppTheme.purpleBlob,
      color: Colors.purple,
      textStyleColor: Colors.purple,
      isOnline: true,
      isRead: true,
    ),
    MessageItem(
      initiatorInitials: 'BK',
      name: 'Bharath Kumar Kunkipudi',
      lastMessage: 'You: [File: logo.png]',
      time: '4:13 PM',
      // color: AppTheme.roseBlob,
      color: Colors.pink,
      textStyleColor: Colors.pink,
      isOnline: false,
      isRead: true,
    ),
    MessageItem(
      initiatorInitials: 'GT',
      name: 'Ganesh Tamarana',
      lastMessage: 'Are we still on for the worksho...',
      time: '2:39 PM',
      // color: AppTheme.indigoBlob,
      color: Colors.indigo,
      textStyleColor: Colors.indigo,
      isOnline: true,
      isRead: true,
    ),
    MessageItem(
      initiatorInitials: 'SP',
      name: 'Satya Padala',
      lastMessage: 'Let me know when the design ...',
      time: '2:27 PM',
      // color: AppTheme.purpleBlob,
      color: Colors.purple,
      textStyleColor: Colors.purple,
      isOnline: false,
      isRead: false,
      isUrgent: true,
    ),
    MessageItem(
      initiatorInitials: 'ST',
      name: 'Sanku Surya Teja',
      lastMessage: 'You: Mock interview screens ar...',
      time: '10:06 AM',
      // color: AppTheme.indigoBlob,
      color: Colors.indigo,
      textStyleColor: Colors.indigo,
      isOnline: false,
      isRead: true,
    ),
    MessageItem(
      initiatorInitials: 'UX',
      name: 'UI/UX Designers',
      lastMessage: 'Sanku: The prototype is updat...',
      time: 'Yesterday',
      // color: AppTheme.roseBlob,
      color: Colors.pink,
      textStyleColor: Colors.pink,
      isOnline: true,
      isRead: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = Theme.of(context).dividerColor;
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
        Colors.grey;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // User Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  // backgroundColor: AppTheme.purpleBlob,
                  backgroundColor: Colors.purple,
                  child: Text(
                    'VL',
                    style: TextStyle(
                      color: Colors.purple.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Meet Button
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.video_call_outlined,
                    color: Colors.blue,
                  ),
                  label: const Text('Meet'),
                ),
                const SizedBox(width: 12),
                // Filter Button
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(
                    Icons.filter_alt_outlined,
                    color: subTextColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildTabBar(textColor, subTextColor),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Messages
          _buildMessagesTab(textColor, subTextColor, borderColor),
          // Tab 2: Communities
          const CommunitiesView(),
          // Tab 3: Meet
          _buildPlaceholderTab('Meet', Icons.video_call_rounded, subTextColor),
          // Tab 4: Activity
          _buildPlaceholderTab(
            'Activity',
            Icons.notifications_outlined,
            subTextColor,
          ),
          // Tab 5: Calendar
          _buildPlaceholderTab(
            'Calendar',
            Icons.calendar_month_rounded,
            subTextColor,
          ),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () => context.push(AppRoutes.createCommunity),
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // gradient: AppTheme.primaryGradient,
            color: Colors.purple,
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildTabBar(Color textColor, Color subTextColor) {
    final cs = Theme.of(context).colorScheme;
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: textColor,
      unselectedLabelColor: subTextColor,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 3,
          color: cs.primary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      labelPadding: const EdgeInsets.symmetric(horizontal: 12),
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(text: 'Messages'),
        Tab(text: 'Communities'),
        Tab(text: 'Meet'),
        Tab(text: 'Activity'),
        Tab(text: 'Calendar'),
      ],
    );
  }

  Widget _buildMessagesTab(
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search conversations',
                hintStyle: TextStyle(color: subTextColor),
                prefixIcon: Icon(Icons.search, color: subTextColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Messages List
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return _buildMessageTile(msg, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderTab(String title, IconData icon, Color subTextColor) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: themeExt.buyNowGradient,
            ),
            child: Icon(icon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: TextStyle(fontSize: 15, color: subTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(MessageItem msg, BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
        Colors.grey;

    return InkWell(
      onTap: () {
        context.push(AppRoutes.chat(msg.initiatorInitials));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: msg.color,
                  child: Text(
                    msg.initiatorInitials,
                    style: TextStyle(
                      color: msg.textStyleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (msg.isOnline || msg.isUrgent)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: msg.isUrgent ? Colors.red : Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          msg.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        msg.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: msg.isRead ? subTextColor : textColor,
                          fontWeight: msg.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          msg.lastMessage,
                          style: TextStyle(
                            color: msg.isRead ? subTextColor : textColor,
                            fontWeight: msg.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (msg.isRead)
                        Icon(
                          Icons.done_all,
                          color: Colors.green.shade400,
                          size: 16,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageItem {
  final String initiatorInitials;
  final String name;
  final String lastMessage;
  final String time;
  final Color color;
  final Color textStyleColor;
  final bool isOnline;
  final bool isRead;
  final bool isUrgent;

  MessageItem({
    required this.initiatorInitials,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.color,
    required this.textStyleColor,
    this.isOnline = false,
    this.isRead = true,
    this.isUrgent = false,
  });
}
