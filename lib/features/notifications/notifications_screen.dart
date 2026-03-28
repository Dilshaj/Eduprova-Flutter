import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eduprova/theme/theme_model.dart';

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
      category: 'Freelancing',
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
    NotificationItem(
      id: '7',
      title: 'Freelance project: Mobile App redesign near you',
      category: 'Freelancing',
      timestamp: yesterday.subtract(const Duration(hours: 4)),
      icon: LucideIcons.rocket,
      iconBg: Colors.white,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final notifications = ref.watch(filteredNotificationsProvider);
    final selectedFilter = ref.watch(notificationFilterProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            _buildAppBar(context, colorScheme),
            _NotificationFilters(selectedFilter: selectedFilter),
            Expanded(
              child: _buildNotificationList(notifications, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: .fromLTRB(8, 12, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(LucideIcons.arrowLeft, color: colorScheme.onSurface),
          ),
          const SizedBox(width: 4),
          Text(
            'Notifications',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: .w800,
              color: colorScheme.onSurface,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationItem> items, ColorScheme colorScheme) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No notifications found',
          style: GoogleFonts.inter(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
      );
    }

    final todayItems = items.where((i) => i.timestamp.isAfter(DateTime.now().subtract(const Duration(hours: 12)))).toList();
    final earlierItems = items.where((i) => !todayItems.contains(i)).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (todayItems.isNotEmpty) ...[
          const SizedBox(height: 24),
          const _SectionHeader(title: 'TODAY'),
          const SizedBox(height: 16),
          ...todayItems.map((item) => NotificationCard(item: item)),
        ],
        if (earlierItems.isNotEmpty) ...[
          const SizedBox(height: 32),
          const _SectionHeader(title: 'YESTERDAY'),
          const SizedBox(height: 16),
          ...earlierItems.map((item) => NotificationCard(item: item)),
        ],
        const SizedBox(height: 40),
      ],
    );
  }
}

class _NotificationFilters extends ConsumerStatefulWidget {
  final String selectedFilter;
  const _NotificationFilters({required this.selectedFilter});

  @override
  ConsumerState<_NotificationFilters> createState() => _NotificationFiltersState();
}

class _NotificationFiltersState extends ConsumerState<_NotificationFilters> {
  final List<String> _filters = const ['All', 'Social', 'Courses', 'Jobs', 'Freelancing'];
  final List<GlobalKey> _keys = List.generate(5, (_) => GlobalKey());
  final GlobalKey _stackKey = GlobalKey();
  
  double _pillLeft = 0;
  double _pillWidth = 0;
  bool _isMeasured = false;

  @override
  void initState() {
    super.initState();
    _handleMeasurements();
  }

  @override
  void didUpdateWidget(covariant _NotificationFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFilter != widget.selectedFilter) {
      _handleMeasurements();
    }
  }

  void _handleMeasurements() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final index = _filters.indexOf(widget.selectedFilter);
      if (index == -1) return;

      final RenderBox? chipBox = _keys[index].currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;

      if (chipBox != null && stackBox != null) {
        final position = chipBox.localToGlobal(Offset.zero, ancestor: stackBox);
        setState(() {
          _pillLeft = position.dx;
          _pillWidth = chipBox.size.width;
          _isMeasured = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: .horizontal,
        padding: .symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: theme.brightness == .dark ? colorScheme.surfaceContainer : colorScheme.surfaceContainerHighest,
            borderRadius: .circular(18),
          ),
          padding: .all(4),
          child: Stack(
            key: _stackKey,
            alignment: .centerLeft,
            children: [
              // Perfection: The Sliding Pill
              AnimatedPositioned(
                duration: 350.ms,
                curve: Curves.fastOutSlowIn,
                left: _pillLeft,
                width: _isMeasured ? _pillWidth : 0,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [themeExt.gradiantStart, themeExt.gradiantEnd],
                      begin: .topLeft,
                      end: .bottomRight,
                    ),
                    borderRadius: .circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: themeExt.gradiantEnd.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: .new(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Chips Row - Labels only
              Row(
                mainAxisSize: .min,
                children: [
                  for (var i = 0; i < _filters.length; i++)
                    _FilterChip(
                      key: _keys[i],
                      label: _filters[i],
                      isSelected: widget.selectedFilter == _filters[i],
                      onTap: () => ref.read(notificationFilterProvider.notifier).setFilter(_filters[i]),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1);
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: .symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            // Background is entirely handled by the track and the sliding pill
            color: _isHovered && !widget.isSelected
                ? colorScheme.onSurface.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: .circular(14),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: widget.isSelected ? .w700 : .w500,
              color: widget.isSelected ? Colors.white : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: .w800,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        letterSpacing: 1.5,
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationItem item;

  const NotificationCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final colorScheme = theme.colorScheme;

    return Container(
      margin: .only(bottom: 12),
      padding: .all(16),
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        borderRadius: .circular(24),
        border: Border.all(
          color: themeExt.borderColor,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: themeExt.shadowColor,
            blurRadius: 10,
            offset: .new(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          // Left Icon/Avatar
          Stack(
            clipBehavior: .none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: .circular(16),
                  image: item.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(item.avatarUrl!),
                          fit: .cover,
                        )
                      : null,
                ),
                child: item.icon != null
                    ? Icon(item.icon, color: colorScheme.primary, size: 22)
                    : null,
              ),
              if (item.badgeIcon != null)
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    padding: .all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: .circle,
                      border: Border.all(color: themeExt.borderColor),
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
              crossAxisAlignment: .start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.4,
                      color: colorScheme.onSurface,
                    ),
                    children: _parseStyledText(item.title, colorScheme),
                  ),
                ),
                if (item.grade != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: .symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: .circular(8),
                    ),
                    child: Text(
                      'Grade: ${item.grade}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: .w700,
                        color: colorScheme.primary,
                      ),
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
                        fontWeight: .w700,
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                        shape: .circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(item.timestamp),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: .w500,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (item.isUnread)
            Padding(
              padding: .only(top: 4, left: 8),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: .circle,
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

  List<TextSpan> _parseStyledText(String text, ColorScheme colorScheme) {
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
