import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'new_meeting.dart';

class CalendarHomeScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool isEmbedded;
  const CalendarHomeScreen({super.key, this.onBack, this.isEmbedded = false});

  @override
  State<CalendarHomeScreen> createState() => _CalendarHomeScreenState();
}

class _CalendarHomeScreenState extends State<CalendarHomeScreen> {
  DateTime _currentMonth = DateTime(2026, 3);
  DateTime _selectedDate = DateTime(2026, 3, 24);
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Helper method to get days in month
  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  void _scrollToCenter(int index) {
    // index is 0-based. Each item width 56 + margin 8 = 64
    final double itemWidth = 64.0;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _openNewMeetingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewMeetingScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget body = _buildBody(context);

    if (widget.isEmbedded) {
      return Stack(
        children: [
          body,
          Positioned(
            bottom: 24,
            right: 24,
            child: _buildGradientAddButton(),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: Icon(LucideIcons.arrowLeft),
                onPressed: widget.onBack,
              )
            : null,
        title: Text(
          'Schedule',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: _buildGradientAddButton(),
      body: SafeArea(child: body),
    );
  }

  Widget _buildGradientAddButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066FF).withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openNewMeetingSheet,
          borderRadius: BorderRadius.circular(30),
          child: const Center(
            child: Icon(
              LucideIcons.plus,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isEmbedded) ...[
            Text(
              'Schedule',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            'Manage and schedule your meetings',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24), // Increased from 20 but removed button

          // Date Strip Header
          _buildDateStripHeader(context),
          const SizedBox(height: 16),

          // Date Strip
          _buildDateStrip(context),
          const SizedBox(height: 32),

          // Today's Schedule Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Schedule",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '4 meetings',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Meeting Cards
          _buildMeetingCard(
            context: context,
            title: 'Team Standup',
            time: '9:00 AM • 30 min',
            participantsCount: 3,
            accentColor: const Color(0xFF0066FF),
            avatars: [
              'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=100&h=100&fit=crop',
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop',
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
            ],
          ),
          const SizedBox(height: 16),
          _buildMeetingCard(
            context: context,
            title: 'Product Review',
            time: '11:00 AM • 1 hr',
            participantsCount: 5,
            accentColor: const Color(0xFFE056FD), 
            avatars: [
              'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=100&h=100&fit=crop',
              'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=100&h=100&fit=crop',
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop',
            ],
            extraParticipants: 2,
          ),
          const SizedBox(height: 16),
          _buildMeetingCard(
            context: context,
            title: 'Client Presentation',
            time: '2:00 PM • 45 min',
            participantsCount: 2,
            accentColor: const Color(0xFF00C853), // Green/Cyan accent (from theme)
            avatars: [
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
              'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=100&h=100&fit=crop',
            ],
          ),
          const SizedBox(height: 16),
          _buildMeetingCard(
            context: context,
            title: 'Design Workshop',
            time: '4:00 PM • 2 hrs',
            participantsCount: 4,
            accentColor: const Color(0xFF0066FF),
            avatars: [
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop',
              'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=100&h=100&fit=crop',
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
            ],
            extraParticipants: 1,
          ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildDateStripHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(LucideIcons.chevronLeft, size: 24, color: colorScheme.onSurface.withValues(alpha: 0.6)),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
            });
          },
        ),
        Column(
          children: [
            Text(
              'Today',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(LucideIcons.chevronRight, size: 24, color: colorScheme.onSurface.withValues(alpha: 0.6)),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateStrip(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final daysInMonth = _daysInMonth(_currentMonth);

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: daysInMonth,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, index) {
          final day = index + 1;
          final date = DateTime(_currentMonth.year, _currentMonth.month, day);
          final isSelected = _selectedDate.year == date.year &&
                             _selectedDate.month == date.month &&
                             _selectedDate.day == date.day;
          
          final weekDayStr = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1];

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              _scrollToCenter(index);
            },
            child: Container(
              width: 56,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0066FF) : (isDark ? colorScheme.surfaceContainer : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: isSelected ? null : Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekDayStr,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$day',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeetingCard({
    required BuildContext context,
    required String title,
    required String time,
    required int participantsCount,
    required Color accentColor,
    required List<String> avatars,
    int? extraParticipants,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Stacked Avatars
                        SizedBox(
                          height: 28,
                          width: (avatars.length * 20.0) + (extraParticipants != null ? 28.0 : 8.0),
                          child: Stack(
                            children: [
                              for (int i = 0; i < avatars.length; i++)
                                Positioned(
                                  left: i * 20.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundImage: NetworkImage(avatars[i]),
                                    ),
                                  ),
                                ),
                              if (extraParticipants != null)
                                Positioned(
                                  left: avatars.length * 20.0,
                                  child: Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0066FF),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '+$extraParticipants',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          LucideIcons.users,
                          size: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$participantsCount participants',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Right Accent Edge
            Container(
              width: 4,
              margin: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
