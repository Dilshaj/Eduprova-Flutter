import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/messages_background.dart';
import '../../widgets/messages_button.dart';

import 'create_community.dart';
import 'community_categories.dart';
import 'community_group.dart';
import 'communities_groups.dart';
import '../utils/community_utils.dart';

class CommunitiesHomeScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const CommunitiesHomeScreen({super.key, this.onBack});

  @override
  State<CommunitiesHomeScreen> createState() => _CommunitiesHomeScreenState();
}

class _CommunitiesHomeScreenState extends State<CommunitiesHomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MessagesBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return MessagesBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.onBack != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.arrow_back,
                                size: 24,
                                color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                              ),
                              onPressed: widget.onBack,
                            ),
                          ),
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0066FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.hub,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        Text(
                          'Eduprova',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDD5), // orange-100
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFFFF9100),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Section
                      const SizedBox(height: 8),
                      Text(
                        'Build your',
                        style: GoogleFonts.inter(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF0066FF), Color(0xFFD946EF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds),
                        child: Text(
                          'professional circle',
                          style: GoogleFonts.inter(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white, // Color makes shader work
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text(
                        'Bring your professional network together in one high-fidelity space. Plan events, share insights, and accelerate growth with our premium tools.',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 32),
                      MessagesButton(
                        text: 'Create your own',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateCommunityScreen(),
                          ),
                        ),
                        width: double.infinity,
                      ),

                      const SizedBox(height: 40),

                      // Templates
                      Text(
                        'CREATE WITH A TEMPLATE',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF94A3B8), // slate-400
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        child: Row(
                          children: [
                            _buildTemplateButton(
                              context,
                              Icons.school,
                              'School',
                              const Color(0xFF0066FF),
                            ),
                            _buildTemplateButton(
                              context,
                              Icons.work,
                              'Business',
                              const Color(0xFFEC4899),
                            ),
                            _buildTemplateButton(
                              context,
                              Icons.emoji_events,
                              'Life',
                              const Color(0xFFF97316),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // My Communities Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'MY COMMUNITIES',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 1.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CommunitiesGroupsScreen(
                                  communities: _myCommunities,
                                  onAddNewCommunity: _addNewCommunity,
                                  onUpdateGroups: _updateGroups,
                                ),
                              ),
                            ),
                            child: Text(
                              'View All',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0066FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        child: Row(
                          children: [
                            _buildCommunityCard(
                              context,
                              'Design Hub',
                              '48 members',
                              Icons.palette,
                              const Color(0xFFEC4899),
                            ),
                            _buildCommunityCard(
                              context,
                              'Dev Circle',
                              '120 members',
                              Icons.code,
                              const Color(0xFF10B981),
                            ),
                            _buildCommunityCard(
                              context,
                              'Marketing',
                              '32 members',
                              Icons.campaign,
                              const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Illustration Section
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CommunityGroupScreen(),
                            ),
                          ),
                          child: SizedBox(
                            width: 320,
                            height: 340,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Main Card
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: 20,
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF64748B).withOpacity(0.15),
                                          blurRadius: 30,
                                          offset: const Offset(0, 20),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'COMMUNITY ENGAGEMENT',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(0xFF94A3B8),
                                                    letterSpacing: 1.0,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'Design Lead Circle',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.trending_up,
                                                      size: 14,
                                                      color: Color(0xFF10B981),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'GROWTH +14%',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF10B981),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 60,
                                              height: 32,
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    right: 0,
                                                    child: _buildAvatar(
                                                      'JD',
                                                      const Color(0xFF334155),
                                                      Colors.white,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 14,
                                                    child: _buildAvatar(
                                                      'AS',
                                                      const Color(0xFF3B82F6),
                                                      Colors.white,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 28,
                                                    child: _buildAvatar(
                                                      '+12',
                                                      const Color(0xFFF1F5F9),
                                                      const Color(0xFF475569),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),

                                        // Fake Graph Area
                                        SizedBox(
                                          height: 100,
                                          width: double.infinity,
                                          child: CustomPaint(
                                            painter: _GraphPainter(),
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        // Bottom Grid
                                        Container(
                                          padding: const EdgeInsets.only(top: 20),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                color: isDarkMode ? Colors.white10 : const Color(0xFFF1F5F9),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'ACTIVE CONNECTIONS',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(0xFF94A3B8),
                                                      letterSpacing: 1.0,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '2.4k',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'SUCCESS RATE',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(0xFF94A3B8),
                                                      letterSpacing: 1.0,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '98.2%',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Floating Event Card (Top Right)
                                Positioned(
                                  right: -10,
                                  top: 0,
                                  child: Container(
                                    width: 190,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: isDarkMode ? Colors.white10 : const Color(0xFFF8FAFC)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.calendar_month,
                                            size: 18,
                                            color: Color(0xFF0066FF),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'UPCOMING WORKSHOP',
                                                style: GoogleFonts.inter(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF0066FF),
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Design Systems 101',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                                  height: 1.2,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Starts in 45 min',
                                                style: GoogleFonts.inter(
                                                  fontSize: 9,
                                                  color: const Color(0xFF94A3B8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Floating Message Card (Bottom Left)
                                Positioned(
                                  left: -15,
                                  bottom: 10,
                                  child: Container(
                                    width: 210,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: isDarkMode ? Colors.white10 : const Color(0xFFF8FAFC)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: NetworkImage('https://i.pravatar.cc/150?img=5'),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Sarah Jenkins',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                                  ),
                                                ),
                                                Text(
                                                  'PRODUCT LEAD',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(0xFF94A3B8),
                                                    letterSpacing: 1.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '"Hey Marcus, ready for the Strategy deep-dive today?"',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                            color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }

  List<Map<String, dynamic>> _myCommunities = List.from(initialCommunities);

  void _addNewCommunity(Map<String, dynamic> data) {
    setState(() {
      _myCommunities.insert(0, data);
    });
  }

  void _updateGroups(String communityId, List<Map<String, dynamic>> channels) {
    setState(() {
      final index = _myCommunities.indexWhere((c) => c['id'] == communityId);
      if (index != -1) {
        _myCommunities[index]['channels'] = channels;
      }
    });
  }

  Widget _buildTemplateButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CommunityCategoriesScreen()),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        padding: const EdgeInsets.only(left: 16, right: 24, top: 12, bottom: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDarkMode ? Colors.white10 : const Color(0xFFF8FAFC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard(
    BuildContext context,
    String name,
    String members,
    IconData icon,
    Color color,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommunitiesGroupsScreen(
            communities: initialCommunities,
            onAddNewCommunity: (data) {},
            onUpdateGroups: _updateGroups,
          ),
        ),
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.white10 : const Color(0xFFF8FAFC),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              members,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String text, Color bgColor, Color textColor) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEC4899)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    double sx = size.width / 300;
    double sy = size.height / 140;

    path.moveTo(0 * sx, 100 * sy);
    path.cubicTo(40 * sx, 100 * sy, 60 * sx, 85 * sy, 90 * sx, 85 * sy);
    path.cubicTo(120 * sx, 85 * sy, 140 * sx, 100 * sy, 170 * sx, 100 * sy);
    path.cubicTo(200 * sx, 100 * sy, 220 * sx, 60 * sy, 250 * sx, 60 * sy);
    path.cubicTo(270 * sx, 60 * sy, 290 * sx, 80 * sy, 300 * sx, 90 * sy);

    canvas.drawPath(path, paint);

    final areaPath = Path.from(path);
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFF472B6).withValues(alpha: 0.15),
          const Color(0xFFF472B6).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(areaPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
