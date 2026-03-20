import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduprova/theme/theme_model.dart';

class LiveSessionOverlay extends StatefulWidget {
  final AppDesignExtension themeExt;
  final VoidCallback onFinish;

  const LiveSessionOverlay({
    super.key,
    required this.themeExt,
    required this.onFinish,
  });

  @override
  State<LiveSessionOverlay> createState() => _LiveSessionOverlayState();
}

class _LiveSessionOverlayState extends State<LiveSessionOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _voiceController;

  @override
  void initState() {
    super.initState();
    _voiceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _voiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: widget.themeExt.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          ),
        ),
        title: Text(
          'Live Session',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          _buildAIPersona(colorScheme),
          const SizedBox(height: 40),
          _buildStatsRow(),
          const SizedBox(height: 30),
          _buildInsights(),
          const Spacer(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildAIPersona(ColorScheme colorScheme) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.2), width: 2),
              ),
              child: const CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=300'),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.themeExt.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [for (int i = 0; i < 3; i++) _buildAnimatedBar(i)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Interviewer AI',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Listening to your response...',
          style: TextStyle(
            color: widget.themeExt.secondaryText,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedBar(int index) {
    return AnimatedBuilder(
      animation: _voiceController,
      builder: (context, child) {
        final height = 12 + (index * 4) + (8 * _voiceController.value);
        return Container(
          width: 3,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard('COMM.', '88%', const Color(0xFFE11D48)),
          const SizedBox(width: 12),
          _buildStatCard('CONF.', '92%', const Color(0xFF2563EB)),
          const SizedBox(width: 12),
          _buildStatCard('GRAMMAR', '95%', const Color(0xFF059669)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: widget.themeExt.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.themeExt.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: widget.themeExt.secondaryText,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildInsightCard(
            title: 'Recent Korrection',
            text: 'Instead of saying "I did some research," try "I conducted comprehensive user research to identify pain points."',
            bgColor: const Color(0xFFFFFBEB),
            titleColor: const Color(0xFF92400E),
            icon: Icons.edit_note,
            iconBg: const Color(0xFFFEF3C7),
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            title: 'Pro-Tip',
            text: "When discussing conflict, focus on the 'Resolution' and 'Impact' rather than the disagreement itself. It shows emotional intelligence.",
            bgColor: const Color(0xFFEFF6FF),
            titleColor: const Color(0xFF1E40AF),
            icon: Icons.lightbulb_outline,
            iconBg: const Color(0xFFDBEAFE),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String text,
    required Color bgColor,
    required Color titleColor,
    required IconData icon,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: titleColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: titleColor.withValues(alpha: 0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Column(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.onFinish,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Finish Session',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
          const SizedBox(height: 20),
          Text(
            'SESSION TIME: 12:45',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.themeExt.secondaryText,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
