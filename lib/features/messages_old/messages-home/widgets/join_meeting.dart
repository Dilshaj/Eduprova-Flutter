import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:eduprova/core/navigation/app_routes.dart';
import '../../repository/calling_repository.dart';

class JoinMeetingScreen extends StatefulWidget {
  const JoinMeetingScreen({super.key});

  @override
  State<JoinMeetingScreen> createState() => _JoinMeetingScreenState();
}

class _JoinMeetingScreenState extends State<JoinMeetingScreen> {
  final CallingRepository _repository = CallingRepository();
  String _meetingId = '';
  bool _loading = false;

  void _onDigitPressed(String digit) {
    if (_meetingId.length < 9) {
      setState(() => _meetingId += digit);
    }
  }

  void _onBackspace() {
    if (_meetingId.isNotEmpty) {
      setState(() => _meetingId = _meetingId.substring(0, _meetingId.length - 1));
    }
  }

  Future<void> _joinMeeting() async {
    if (_meetingId.isEmpty) return;

    setState(() => _loading = true);
    try {
      final room = await _repository.getToken(_meetingId);
      if (!mounted) return;
      if (!mounted) return;
      context.pushReplacement(
        AppRoutes.meetCall(room.roomName),
        extra: {
          'initialRoom': room,
          'initialVideo': true,
          'initialAudio': true,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join meeting: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF1E1E2D)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Join Meeting',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E2D),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Enter the meeting ID or code provided by the organizer',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF71719A),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildMeetingIdBox(),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildGradientButton(),
            ),
            const Spacer(),
            _buildKeypad(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingIdBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEBE6FF),
          width: 2,
          style: BorderStyle.none, // We'll use a custom painter if we want dashed, but let's approximate with a dashed decoration if possible or just soft border
        ),
      ),
      // Since standard BoxDecoration doesn't support dashed easily, we use a CustomPaint for the border if needed
      child: CustomPaint(
        painter: DashedBorderPainter(color: const Color(0xFFDCDCF5), borderRadius: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 9; i++) ...[
                if (i == 3 || i == 6) const SizedBox(width: 12),
                _buildDigitSlot(i < _meetingId.length ? _meetingId[i] : '', i),
              ],
              if (_meetingId.length < 9)
                _buildCursor(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitSlot(String char, int index) {
    final color = index < 3 ? const Color(0xFF3B82F6) : const Color(0xFF8B5CF6);
    return Container(
      width: 20,
      alignment: Alignment.center,
      child: Text(
        char,
        style: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCursor() {
    return Container(
      width: 2,
      height: 32,
      margin: const EdgeInsets.only(left: 8),
      color: const Color(0xFF3B82F6),
    );
  }

  Widget _buildGradientButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066FF).withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _loading || _meetingId.isEmpty ? null : _joinMeeting,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _loading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
                'Join Now',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              _buildKey('1'),
              _buildKey('2'),
              _buildKey('3'),
            ],
          ),
          Row(
            children: [
              _buildKey('4'),
              _buildKey('5'),
              _buildKey('6'),
            ],
          ),
          Row(
            children: [
              _buildKey('7'),
              _buildKey('8'),
              _buildKey('9'),
            ],
          ),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              _buildKey('0'),
              _buildBackspaceKey(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String digit) {
    return Expanded(
      child: InkWell(
        onTap: () => _onDigitPressed(digit),
        child: Container(
          height: 60,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            digit,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E2D),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return Expanded(
      child: InkWell(
        onTap: _onBackspace,
        child: Container(
          height: 60,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(LucideIcons.delete, color: Color(0xFF71719A)),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  DashedBorderPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    
    const double dashWidth = 8, dashSpace = 6;
    double distance = 0;
    for (final PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
