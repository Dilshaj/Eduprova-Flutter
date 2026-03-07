import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'ai_theme.dart';
import '../providers/interview_providers.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isLoading = false);
    });
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
                                const SizedBox(height: 16),
                                _buildInsightsChip(),
                                const SizedBox(height: 16),
                                _buildTitle(),
                                const SizedBox(height: 8),
                                _buildSubtitle(),
                                const SizedBox(height: 24),
                                _buildScoreCards(),
                                const SizedBox(height: 20),
                                _buildScoreProgressionCard(),
                                const SizedBox(height: 20),
                                _buildRepetitiveStrengths(),
                                const SizedBox(height: 20),
                                _buildFocusAreas(),
                                const SizedBox(height: 32),
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
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
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
        ],
      ),
    );
  }

  Widget _buildInsightsChip() {
    final t = AiTheme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: t.chipBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.chipBorder, width: 1.5),
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
              'PERFORMANCE INSIGHTS',
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
      'Interview Analytics',
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        color: t.textPrimary,
        height: 1.15,
      ),
    );
  }

  Widget _buildSubtitle() {
    final t = AiTheme.of(context);
    return Text(
      'Advanced AI-driven diagnostic report of your\ninterview progression and behavioral patterns.',
      style: TextStyle(
        fontSize: 13,
        height: 1.55,
        color: t.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildScoreCards() {
    return Consumer(
      builder: (context, ref, _) {
        final analyticsAsync = ref.watch(interviewAnalyticsProvider);
        return analyticsAsync.when(
          loading: () => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.grid_view_rounded,
                  label: 'AVG SCORE',
                  value: '—',
                  unit: '/10',
                  iconColor: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.diamond_outlined,
                  label: 'TOTAL SESSIONS',
                  value: '—',
                  unit: 'TOTAL',
                  iconColor: const Color(0xFFD946EF),
                ),
              ),
            ],
          ),
          error: (_, _) => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.grid_view_rounded,
                  label: 'AVG SCORE',
                  value: '—',
                  unit: '/10',
                  iconColor: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.diamond_outlined,
                  label: 'TOTAL SESSIONS',
                  value: '—',
                  unit: 'TOTAL',
                  iconColor: const Color(0xFFD946EF),
                ),
              ),
            ],
          ),
          data: (analytics) => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.grid_view_rounded,
                  label: 'AVG SCORE',
                  value: analytics.averages.overall.toString(),
                  unit: '/10',
                  iconColor: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.diamond_outlined,
                  label: 'TOTAL SESSIONS',
                  value: analytics.totalSessions.toString(),
                  unit: 'TOTAL',
                  iconColor: const Color(0xFFD946EF),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color iconColor,
  }) {
    final t = AiTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.cardBorder),
        boxShadow: t.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: t.textMuted,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: t.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: t.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreProgressionCard() {
    final t = AiTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.cardBorder),
        boxShadow: t.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score Progression',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: t.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Historical performance trend',
                    style: TextStyle(
                      fontSize: 11,
                      color: t.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '● OVERALL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 100,
            child: CustomPaint(
              painter: _LineChartPainter(),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['WEEK 1', 'WEEK 2', 'WEEK 3', 'NOW']
                .map(
                  (label) => Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade400,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRepetitiveStrengths() {
    final t = AiTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Repetitive Strengths',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: t.textPrimary,
              ),
            ),
            Text(
              'VIEW ALL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.blue.shade500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: t.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.cardBorder),
            boxShadow: t.cardShadow,
          ),
          child: Column(
            children: [
              _buildStrengthItem(
                'Exceptional narrative structure',
                'HIGH',
                const Color(0xFF22C55E),
                const Color(0xFFDCFCE7),
              ),
              _buildDivider(),
              _buildStrengthItem(
                'SQL precision & Logic',
                'STABLE',
                const Color(0xFF3B82F6),
                const Color(0xFFEFF6FF),
              ),
              _buildDivider(),
              _buildStrengthItem(
                'Consistent pacing',
                'STABLE',
                const Color(0xFF3B82F6),
                const Color(0xFFEFF6FF),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFocusAreas() {
    final t = AiTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Focus Areas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: t.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '3 PENDING',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFF97316),
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: t.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.cardBorder),
            boxShadow: t.cardShadow,
          ),
          child: Column(
            children: [
              _buildStrengthItem(
                'System Design rationale',
                'ACTION',
                const Color(0xFF3B82F6),
                const Color(0xFFEFF6FF),
              ),
              _buildDivider(),
              _buildStrengthItem(
                'Filler word reduction',
                'URGENT',
                const Color(0xFFF97316),
                const Color(0xFFFFF7ED),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthItem(
    String title,
    String badge,
    Color badgeColor,
    Color badgeBg,
  ) {
    final t = AiTheme.of(context);
    final darkBadgeBg = badgeColor.withValues(alpha: 0.15);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: t.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: t.isDark ? darkBadgeBg : badgeBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: badgeColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    final t = AiTheme.of(context);
    return Divider(height: 1, color: t.divider, indent: 18, endIndent: 18);
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height - (size.height / 4 * i);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Gradient fill under curve
    final points = [
      Offset(0, size.height * 0.85),
      Offset(size.width * 0.25, size.height * 0.65),
      Offset(size.width * 0.5, size.height * 0.55),
      Offset(size.width * 0.75, size.height * 0.35),
      Offset(size.width, size.height * 0.05),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final cp1x = (points[i].dx + points[i + 1].dx) / 2;
      final cp1y = points[i].dy;
      final cp2x = (points[i].dx + points[i + 1].dx) / 2;
      final cp2y = points[i + 1].dy;
      path.cubicTo(cp1x, cp1y, cp2x, cp2y, points[i + 1].dx, points[i + 1].dy);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF3B82F6).withValues(alpha: 0.12),
          const Color(0xFF3B82F6).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, fillPaint);

    // Curve line
    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1x = (points[i].dx + points[i + 1].dx) / 2;
      final cp1y = points[i].dy;
      final cp2x = (points[i].dx + points[i + 1].dx) / 2;
      final cp2y = points[i + 1].dy;
      linePath.cubicTo(
        cp1x,
        cp1y,
        cp2x,
        cp2y,
        points[i + 1].dx,
        points[i + 1].dy,
      );
    }

    final linePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // Dot at midpoint
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final midPoint = points[2];
    canvas.drawCircle(midPoint, 5, dotPaint);
    canvas.drawCircle(midPoint, 5, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
