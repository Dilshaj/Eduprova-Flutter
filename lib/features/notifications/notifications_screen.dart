import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

// --- Notification State Management ---

class NotificationItem {
  final String id;
  final String title;
  final String category;
  final DateTime timestamp;
  final IconData? icon;
  final String? avatarUrl;
  final Color? iconBg;
  final IconData? badgeIcon;
  final Color? badgeColor;
  final bool isUnread;
  final String? grade;

  NotificationItem({
    required this.id,
    required this.title,
    required this.category,
    required this.timestamp,
    this.icon,
    this.avatarUrl,
    this.iconBg,
    this.badgeIcon,
    this.badgeColor,
    this.isUnread = false,
    this.grade,
  });
}

final notificationFilterProvider = NotifierProvider<NotificationFilterNotifier, String>(NotificationFilterNotifier.new);

class NotificationFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setFilter(String val) => state = val;
}

final notificationsProvider = Provider<List<NotificationItem>>((ref) {
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));

  // Mock data as per the reference image
  return [
    NotificationItem(
      id: '1',
      title: 'Your Mock Interview report is ready',
      category: 'AI Tools',
      timestamp: now.subtract(const Duration(minutes: 2)),
      icon: LucideIcons.sparkles,
      iconBg: Colors.white,
      isUnread: true,
    ),
    NotificationItem(
      id: '2',
      title: 'New module added to Data Science',
      category: 'Courses',
      timestamp: now.subtract(const Duration(minutes: 45)),
      icon: LucideIcons.graduationCap,
      iconBg: Colors.white,
      isUnread: true,
    ),
    NotificationItem(
      id: '3',
      title: 'Rahul Gamer liked your post about UI design',
      category: 'Social',
      timestamp: now.subtract(const Duration(hours: 2)),
      avatarUrl: 'https://i.pravatar.cc/150?u=rahul',
      badgeIcon: LucideIcons.heart,
      badgeColor: Colors.pink,
    ),
    NotificationItem(
      id: '4',
      title: 'New Graphic Designer role at Google matches you',
      category: 'Jobs',
      timestamp: yesterday.copyWith(hour: 10, minute: 20),
      icon: LucideIcons.briefcase,
      iconBg: Colors.white,
    ),
    NotificationItem(
      id: '5',
      title: 'Assignment graded: Advanced React',
      category: 'Courses',
      timestamp: yesterday.copyWith(hour: 16, minute: 15),
      icon: LucideIcons.fileText,
      iconBg: Colors.white,
      grade: 'A+ (98/100)',
    ),
    NotificationItem(
      id: '6',
      title: 'New message from Alex M.',
      category: 'Social',
      timestamp: yesterday.copyWith(hour: 18, minute: 30),
      avatarUrl: 'https://i.pravatar.cc/150?u=alex',
      badgeIcon: LucideIcons.messageSquare,
      badgeColor: Colors.blue,
    ),
  ];
});

final filteredNotificationsProvider = Provider<List<NotificationItem>>((ref) {
  final filter = ref.watch(notificationFilterProvider);
  final allNotifications = ref.watch(notificationsProvider);

  if (filter == 'All') return allNotifications;
  return allNotifications.where((n) => n.category == filter).toList();
});

// --- Screens & Widgets ---

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = ref.watch(filteredNotificationsProvider);
    final selectedFilter = ref.watch(notificationFilterProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context, isDark),
            _NotificationFilters(selectedFilter: selectedFilter, isDark: isDark),
            Expanded(
              child: _buildNotificationList(notifications, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              LucideIcons.arrowLeft,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Notifications',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationItem> items, bool isDark) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No notifications found',
          style: GoogleFonts.inter(color: Colors.grey),
        ),
      );
    }

    // Simple grouping logic for Mock presentation
    final todayItems = items.where((i) => i.timestamp.isAfter(DateTime.now().subtract(const Duration(hours: 12)))).toList();
    final earlierItems = items.where((i) => !todayItems.contains(i)).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (todayItems.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(title: 'TODAY', isDark: isDark),
          const SizedBox(height: 16),
          ...todayItems.map((item) => NotificationCard(item: item, isDark: isDark)),
        ],
        if (earlierItems.isNotEmpty) ...[
          const SizedBox(height: 32),
          _SectionHeader(title: 'YESTERDAY', isDark: isDark),
          const SizedBox(height: 16),
          ...earlierItems.map((item) => NotificationCard(item: item, isDark: isDark)),
        ],
        const SizedBox(height: 40),
      ],
    );
  }
}

class _NotificationFilters extends ConsumerWidget {
  final String selectedFilter;
  final bool isDark;
  final List<String> filters = ['All', 'Courses', 'Social', 'Jobs', 'AI Tools'];

  _NotificationFilters({required this.selectedFilter, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = selectedFilter == filters[index];
          return GestureDetector(
            onTap: () => ref.read(notificationFilterProvider.notifier).setFilter(filters[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  filters[index],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.grey[400] : const Color(0xFF64748B)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.grey[600] : const Color(0xFF94A3B8),
        letterSpacing: 1.5,
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final bool isDark;

  const NotificationCard({super.key, required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Icon/Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: item.iconBg ?? Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  image: item.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(item.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: item.icon != null
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: item.icon != null
                    ? Icon(item.icon, color: const Color(0xFF64748B), size: 22)
                    : null,
              ),
              if (item.badgeIcon != null)
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: Icon(item.badgeIcon, size: 12, color: item.badgeColor),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.4,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    children: _parseStyledText(item.title, isDark),
                  ),
                ),
                if (item.grade != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Grade: ${item.grade}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      item.category,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : const Color(0xFFCBD5E1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(item.timestamp),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[500] : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (item.isUnread)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  String _formatTimestamp(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${t.hour}:${t.minute.toString().padLeft(2, '0')} AM';
  }

  List<TextSpan> _parseStyledText(String text, bool isDark) {
    // [Styling logic remains the same for premium scannability]
    final boldWords = [
      'Mock Interview', 'Data Science', 'Rahul Gamer', 'UI design',
      'Graphic Designer', 'Google', 'Advanced React', 'Alex M.'
    ];
    List<TextSpan> spans = [];
    String currentText = text;
    for (var word in boldWords) {
      if (currentText.contains(word)) {
        final index = currentText.indexOf(word);
        if (index > 0) spans.add(TextSpan(text: currentText.substring(0, index)));
        spans.add(TextSpan(text: word, style: const TextStyle(fontWeight: FontWeight.w700)));
        currentText = currentText.substring(index + word.length);
      }
    }
    if (currentText.isNotEmpty) spans.add(TextSpan(text: currentText));
    if (spans.isEmpty) spans.add(TextSpan(text: text));
    return spans;
  }
}
