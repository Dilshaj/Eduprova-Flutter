import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:eduprova/core/navigation/app_routes.dart';
import '../../../auth/providers/auth_provider.dart';

import '../../models/meeting_model.dart';
import '../../models/search_user_model.dart';
import '../../repository/calling_repository.dart';

class ScheduleMeetingScreen extends ConsumerStatefulWidget {
  const ScheduleMeetingScreen({super.key});

  @override
  ConsumerState<ScheduleMeetingScreen> createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends ConsumerState<ScheduleMeetingScreen> {
  final CallingRepository _repository = CallingRepository();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  List<SearchUserModel> _participants = const [];
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));
  Duration _duration = const Duration(hours: 1);
  bool _submitting = false;

  bool _repeatWeekly = true;
  bool _reminder = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6))),
          child: child!,
        );
      },
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );
    if (time == null) return;

    setState(() {
      _startTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meeting title is required')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final meeting = await _repository.createMeeting(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        startTime: _startTime,
        endTime: _startTime.add(_duration),
        participantIds: _participants.map((user) => user.id).toList(),
      );
      if (!mounted) return;
      Navigator.of(context).pop<MeetingModel>(meeting);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to schedule meeting: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickParticipants() async {
    final result = await context.push<List<SearchUserModel>>(
      AppRoutes.meetInvite,
      extra: {
        'title': 'Add Participants',
        'submitLabel': 'Done',
        'initialSelected': _participants,
      },
    );
    if (result == null || !mounted) return;
    setState(() => _participants = result);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF33334F)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Schedule Meeting',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E2D),
          ),
        ),
        actions: [
          if (user?.avatar != null)
             Padding(
               padding: const EdgeInsets.only(right: 16),
               child: CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(user!.avatar!),
              ),
             )
          else
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: CircleAvatar(radius: 14, child: Icon(LucideIcons.user, size: 16)),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('MEETING TITLE'),
              const SizedBox(height: 12),
              _buildTitleInput(),
              const SizedBox(height: 24),
              _buildSectionLabel('MEETING SCHEDULE'),
              const SizedBox(height: 12),
              _buildScheduleCard(),
              const SizedBox(height: 24),
              _buildSectionLabel('ADD PARTICIPANTS'),
              _buildParticipantsHeader(),
              const SizedBox(height: 12),
              _buildSearchContacts(),
              const SizedBox(height: 16),
              _buildParticipantsList(),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildToggleCard(
                      icon: LucideIcons.calendar,
                      label: 'Repeat Weekly',
                      subtitle: 'Every Tuesday at 10:00 AM',
                      value: _repeatWeekly,
                      onChanged: (v) => setState(() => _repeatWeekly = v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildToggleCard(
                      icon: LucideIcons.bell,
                      label: 'Reminder',
                      subtitle: '15 minutes before meeting',
                      value: _reminder,
                      onChanged: (v) => setState(() => _reminder = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildGradientButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF71719A),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTitleInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _titleController,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF1E1E2D)),
        decoration: InputDecoration(
          hintText: 'e.g. Design Sync Session',
          hintStyle: GoogleFonts.inter(color: const Color(0xFFBCBCCF)),
          prefixIcon: const Icon(LucideIcons.pencil, size: 20, color: Color(0xFF8B5CF6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickDateTime,
            child: Row(
              children: [
                const Icon(LucideIcons.calendar, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 12),
                Text(
                  _formatDate(_startTime),
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1E1E2D)),
                ),
                const Spacer(),
                const Icon(LucideIcons.chevronDown, size: 20, color: Color(0xFF71719A)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildTimeSlot('START TIME', _startTime)),
              const SizedBox(width: 16),
              Expanded(child: _buildTimeSlot('END TIME', _startTime.add(_duration))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String label, DateTime time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF71719A)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(label.contains('START') ? LucideIcons.clock : LucideIcons.history, size: 14, color: const Color(0xFF8B5CF6)),
              const SizedBox(width: 6),
              Text(
                _formatTime(time),
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E1E2D)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_participants.length} Selected',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF3B82F6)),
          ),
          Text(
            'SELECT ALL',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF71719A)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContacts() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search contacts...',
          hintStyle: GoogleFonts.inter(color: const Color(0xFFBCBCCF)),
          prefixIcon: const Icon(LucideIcons.search, size: 20, color: Color(0xFFBCBCCF)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget _buildParticipantsList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final participant in _participants)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _buildParticipantAvatar(participant),
            ),
          _buildAddParticipantButton(),
        ],
      ),
    );
  }

  Widget _buildParticipantAvatar(SearchUserModel user) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EEFF),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                user.displayName[0],
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF8B5CF6)),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Color(0xFF8B5CF6), shape: BoxShape.circle),
                child: const Icon(LucideIcons.check, size: 10, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          user.displayName.split(' ')[0],
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF71719A)),
        ),
      ],
    );
  }

  Widget _buildAddParticipantButton() {
    return GestureDetector(
      onTap: _pickParticipants,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: CustomPaint(
              painter: DashedBorderPainter(color: const Color(0xFFDCDCF5), borderRadius: 25),
              child: const Icon(LucideIcons.plus, size: 20, color: Color(0xFFBCBCCF)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ADD',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFFBCBCCF)),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 20, color: const Color(0xFF8B5CF6)),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF8B5CF6),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E1E2D)),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF71719A), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFFE056FD)]),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066FF).withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: _submitting
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
                'Schedule Meeting',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${_getMonthName(d.month)} ${d.day}, ${d.year}';
  }

  String _formatTime(DateTime d) {
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $ampm';
  }

  String _getMonthName(int m) {
    return switch (m) {
      1 => 'January', 2 => 'February', 3 => 'March', 4 => 'April',
      5 => 'May', 6 => 'June', 7 => 'July', 8 => 'August',
      9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December',
      _ => '',
    };
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
