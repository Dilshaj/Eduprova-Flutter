import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'ai_theme.dart';
import '../models/interview_feedback_model.dart';

class InterviewAnalysisPage extends StatefulWidget {
  final InterviewFeedback feedback;

  const InterviewAnalysisPage({super.key, required this.feedback});

  @override
  State<InterviewAnalysisPage> createState() => _InterviewAnalysisPageState();
}

class _InterviewAnalysisPageState extends State<InterviewAnalysisPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _animController;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scoreAnim = Tween(begin: 0.0, end: widget.feedback.overallScore / 10)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AiTheme.of(context);
    final f = widget.feedback;

    final skills = [
      {'label': 'TECHNICAL PROFICIENCY', 'value': f.technicalScore / 10},
      {'label': 'COMMUNICATION CLARITY', 'value': f.communicationScore / 10},
      {'label': 'OVERALL PERFORMANCE', 'value': f.overallScore / 10},
    ];

    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: Skeletonizer(
        enabled: _isLoading,
        effect: ShimmerEffect(
          baseColor: t.shimmerBase,
          highlightColor: t.shimmerHighlight,
          duration: const Duration(seconds: 1),
        ),
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
                  SafeArea(
                    child: Column(
                      children: [
                        _buildHeader(context),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: .stretch,
                              children: [
                                const SizedBox(height: 8),
                                _buildScoreGauge(f.overallScore),
                                const SizedBox(height: 28),
                                _buildSkillBars(skills),
                                const SizedBox(height: 24),
                                _buildStrengthsCard(f.strengths),
                                const SizedBox(height: 14),
                                _buildGrowthCard(f.improvements),
                                const SizedBox(height: 24),
                                ...f.detailedAnalysis.asMap().entries.map(
                                  (e) => _buildModuleCard(e.key + 1, e.value),
                                ),
                                if (f.recommendations.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _buildRecommendationsCard(f.recommendations),
                                ],
                                const SizedBox(height: 24),
                                _buildRetryButton(),
                                const SizedBox(height: 14),
                                _buildBackToDashboard(context),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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
                color: const Color(0xFFF43F5E).withValues(alpha: 0.07),
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
                color: const Color(0xFF6366F1).withValues(alpha: 0.07),
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
                color: const Color(0xFF3B82F6).withValues(alpha: 0.07),
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
                color: const Color(0xFFA855F7).withValues(alpha: 0.07),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.arrow_back, color: t.iconBack, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Interview Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: t.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreGauge(double score) {
    final t = AiTheme.of(context);
    return Column(
      children: [
        Text(
          'OVERALL SCORE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: t.textMuted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 150,
          height: 150,
          child: AnimatedBuilder(
            animation: _scoreAnim,
            builder: (context, _) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _scoreAnim.value,
                    strokeWidth: 10,
                    backgroundColor: t.gaugeTrack,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF7C3AED),
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Text(
                      score.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: t.textPrimary,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkillBars(List<Map<String, dynamic>> skills) {
    final t = AiTheme.of(context);
    return Column(
      children: [
        for (final skill in skills)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      skill['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: t.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${((skill['value'] as double) * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: t.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: skill['value'] as double,
                    minHeight: 5,
                    backgroundColor: t.barTrack,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4F46E5),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStrengthsCard(List<String> items) {
    return _buildAnalysisCard(
      icon: Icons.star_border_rounded,
      title: 'KEY STRENGTHS',
      iconColor: const Color(0xFF22C55E),
      iconBg: const Color(0xFF22C55E).withValues(alpha: 0.1),
      items: items,
      dotColor: const Color(0xFF22C55E),
    );
  }

  Widget _buildGrowthCard(List<String> items) {
    return _buildAnalysisCard(
      icon: Icons.trending_up_rounded,
      title: 'GROWTH AREAS',
      iconColor: const Color(0xFFF97316),
      iconBg: const Color(0xFFF97316).withValues(alpha: 0.1),
      items: items,
      dotColor: const Color(0xFFF97316),
    );
  }

  Widget _buildRecommendationsCard(List<String> items) {
    return _buildAnalysisCard(
      icon: Icons.lightbulb_outline_rounded,
      title: 'RECOMMENDATIONS',
      iconColor: const Color(0xFF3B82F6),
      iconBg: const Color(0xFF3B82F6).withValues(alpha: 0.1),
      items: items,
      dotColor: const Color(0xFF3B82F6),
    );
  }

  Widget _buildAnalysisCard({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color iconBg,
    required List<String> items,
    required Color dotColor,
  }) {
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
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: t.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: .start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dotColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.55,
                        color: t.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(int moduleNum, DetailedAnalysisItem item) {
    final t = AiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: t.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.cardBorder),
          boxShadow: t.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'MODULE ${moduleNum.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: t.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  'SCORE  ${item.score.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.question,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: t.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'YOUR RESPONSE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: t.textMuted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '"${item.userAnswer}"',
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: t.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'AI ANALYSIS',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: t.textMuted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.feedback,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: t.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
          begin: .centerLeft,
          end: .centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
        label: const Text(
          'RETRY INTERVIEW',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildBackToDashboard(BuildContext context) {
    return TextButton.icon(
      onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
      icon: Icon(
        Icons.grid_view_rounded,
        size: 16,
        color: Colors.grey.shade500,
      ),
      label: Text(
        'BACK TO DASHBOARD',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
