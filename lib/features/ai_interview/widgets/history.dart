import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'ai_theme.dart';
import '../models/interview_session_model.dart';
import '../providers/interview_providers.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  bool _isLoading = true;
  String _selectedTab = 'All Sessions';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<InterviewSession> _applyFilters(List<InterviewSession> sessions) {
    return [
      for (var s in sessions)
        if ((_selectedTab == 'All Sessions' ||
                (_selectedTab == 'Completed' && s.status == 'completed') ||
                (_selectedTab == 'In Progress' && s.status == 'in-progress')) &&
            (s.typeLabel.contains(_searchController.text.toUpperCase()) ||
                (s.config?.techStack?.join(' ') ?? '').toUpperCase().contains(
                  _searchController.text.toUpperCase(),
                ) ||
                _searchController.text.isEmpty))
          s,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = AiTheme.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: Skeletonizer(
        enabled: _isLoading,
        effect: ShimmerEffect(
          baseColor: t.shimmerBase,
          highlightColor: t.shimmerHighlight,
          duration: const Duration(seconds: 1),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double maxWidth = 480;
              double padding = 0;
              if (constraints.maxWidth > maxWidth) {
                padding = (constraints.maxWidth - maxWidth) / 2;
              }
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Stack(
                  children: [
                    _buildBackground(
                      constraints.maxHeight,
                      constraints.maxWidth > maxWidth
                          ? maxWidth
                          : constraints.maxWidth,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 12),
                                _buildActivityChip(),
                                const SizedBox(height: 16),
                                _buildTitle(),
                                const SizedBox(height: 6),
                                _buildSubtitle(),
                                const SizedBox(height: 20),
                                _buildSearchBar(),
                                const SizedBox(height: 16),
                                _buildTabs(),
                                const SizedBox(height: 20),
                                Consumer(
                                  builder: (context, ref, _) {
                                    final historyAsync = ref.watch(
                                      interviewHistoryProvider,
                                    );
                                    return historyAsync.when(
                                      loading: () => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      error: (e, _) => Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.error_outline,
                                              color: Colors.redAccent,
                                              size: 40,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Failed to load history',
                                              style: TextStyle(
                                                color: AiTheme.of(
                                                  context,
                                                ).textMuted,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => ref
                                                  .read(
                                                    interviewHistoryProvider
                                                        .notifier,
                                                  )
                                                  .refresh(),
                                              child: const Text('Retry'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      data: (sessions) {
                                        final filtered = _applyFilters(
                                          sessions,
                                        );
                                        if (filtered.isEmpty) {
                                          return Center(
                                            child: Text(
                                              'No sessions found',
                                              style: TextStyle(
                                                color: AiTheme.of(
                                                  context,
                                                ).textMuted,
                                              ),
                                            ),
                                          );
                                        }
                                        return Column(
                                          children: [
                                            for (final s in filtered)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 16,
                                                ),
                                                child: _buildRealSessionCard(s),
                                              ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                _buildPagination(),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(double height, double width) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -height * 0.1,
            left: -width * 0.1,
            child: Container(
              width: width * 0.7,
              height: width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            top: height * 0.2,
            right: -width * 0.2,
            child: Container(
              width: width * 0.8,
              height: width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: height * 0.1,
            left: -width * 0.2,
            child: Container(
              width: width * 0.8,
              height: width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -height * 0.1,
            right: -width * 0.1,
            child: Container(
              width: width * 0.7,
              height: width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA855F7).withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final t = AiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, color: t.iconBack, size: 18),
              const SizedBox(width: 8),
              Text(
                'Back',
                style: TextStyle(
                  color: t.iconBack,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityChip() {
    final t = AiTheme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: t.chipBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.chipBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '● ACTIVITY LOG',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: t.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final t = AiTheme.of(context);
    return Text(
      'Interview History',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: t.textPrimary,
        height: 1.1,
      ),
    );
  }

  Widget _buildSubtitle() {
    final t = AiTheme.of(context);
    return Text(
      'Track your professional growth through past AI\ninterview sessions and detailed performance analytics.',
      style: TextStyle(
        fontSize: 13,
        height: 1.55,
        color: t.textMuted,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSearchBar() {
    final t = AiTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() {}),
        style: TextStyle(color: t.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search by role or technology...',
          hintStyle: TextStyle(
            color: t.inputHint,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(Icons.search, color: t.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final t = AiTheme.of(context);
    final tabs = ['All Sessions', 'Technical', 'Resume'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (t.isDark ? Colors.white : const Color(0xFF111827))
                      : t.chipBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : t.chipBorder,
                  ),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? (t.isDark ? Colors.black : Colors.white)
                        : t.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRealSessionCard(InterviewSession session) {
    final typeColors = {
      'RESUME BASED': (
        bg: const Color(0xFFEFF6FF),
        text: const Color(0xFF3B82F6),
      ),
      'TECHNICAL': (bg: const Color(0xFFDCFCE7), text: const Color(0xFF22C55E)),
    };
    final colors =
        typeColors[session.typeLabel] ??
        (bg: const Color(0xFFFFF7ED), text: const Color(0xFFF97316));

    final statusColor = session.status == 'completed'
        ? const Color(0xFF22C55E)
        : const Color(0xFFF59E0B);

    // Use transcriptCount as a proxy score (questions answered / total * 100)
    final answeredCount = session.transcript
        .where((t) => t.speaker == 'user')
        .length;
    final totalQ = session.questions.length;
    final scorePercent = totalQ > 0
        ? ((answeredCount / totalQ) * 100).round()
        : 0;

    final dateStr = session.createdAt != null
        ? '${session.createdAt!.day} ${_monthName(session.createdAt!.month)}, ${session.createdAt!.year}'
        : '—';

    return _buildSessionCard({
      'type': session.typeLabel,
      'status': session.status.toUpperCase(),
      'score': scorePercent,
      'title':
          session.config?.techStack?.join(', ') ??
          session.config?.experienceLevel ??
          'Interview',
      'date': dateStr,
      'duration': session.durationDisplay,
      'color': statusColor,
      'badgeColor': colors.text,
      'badgeBg': colors.bg,
    });
  }

  String _monthName(int month) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month];
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final t = AiTheme.of(context);
    final Color typeColor = session['color'] as Color;
    final Color badgeColor = session['badgeColor'] as Color;
    final Color badgeBg = session['badgeBg'] as Color;

    return Container(
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.cardBorder),
        boxShadow: t.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: type + status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    session['type'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: typeColor,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      session['status'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: typeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Score + title
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: (session['score'] as int) / 100,
                        strokeWidth: 5,
                        backgroundColor: Colors.grey.shade100,
                        color: typeColor,
                      ),
                      Center(
                        child: Text(
                          '${session['score']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: t.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session['title'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: t.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: t.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            session['date'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: t.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: t.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            session['duration'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: t.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _buildCardButton(
                    label: 'Download',
                    icon: Icons.download_outlined,
                    onTap: () {},
                    outlined: true,
                    color: const Color(0xFF374151),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildGradientButton('View Report', () {})),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool outlined,
    required Color color,
  }) {
    final t = AiTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: outlined ? Border.all(color: t.chipBorder) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: t.isDark ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: t.isDark ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward, size: 15, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPageArrow(Icons.chevron_left, () {}),
        const SizedBox(width: 8),
        _buildPageNum('1', selected: true),
        const SizedBox(width: 6),
        _buildPageNum('2'),
        const SizedBox(width: 6),
        _buildPageNum('3'),
        const SizedBox(width: 8),
        _buildPageArrow(Icons.chevron_right, () {}),
      ],
    );
  }

  Widget _buildPageNum(String n, {bool selected = false}) {
    final t = AiTheme.of(context);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: selected
            ? (t.isDark ? Colors.white : const Color(0xFF111827))
            : t.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? Colors.transparent : t.chipBorder),
      ),
      child: Center(
        child: Text(
          n,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected
                ? (t.isDark ? Colors.black : Colors.white)
                : t.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPageArrow(IconData icon, VoidCallback onTap) {
    final t = AiTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: t.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: t.chipBorder),
        ),
        child: Icon(icon, size: 18, color: t.textSecondary),
      ),
    );
  }
}
