import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:eduprova/theme/messages_theme_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';


import 'join_meeting.dart';
import '../../models/meeting_model.dart';
import '../../repository/calling_repository.dart';
import '../../../auth/providers/auth_provider.dart';
import 'create_room.dart';
import 'schedule_meeting.dart';

class MeetScreen extends ConsumerStatefulWidget {
  const MeetScreen({super.key});

  @override
  ConsumerState<MeetScreen> createState() => _MeetScreenState();
}

class _MeetScreenState extends ConsumerState<MeetScreen> {
  final CallingRepository _repository = CallingRepository();
  final TextEditingController _searchController = TextEditingController();
  List<MeetingModel> _meetings = const [];
  bool _loading = true;
  String _query = '';
  String? _error;
  String _activeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadMeetings();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _query = _searchController.text);
  }

  Future<void> _loadMeetings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final meetings = await _repository.getMeetings();
      if (!mounted) return;
      setState(() {
        _meetings = meetings;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<MeetingModel> get _filteredMeetings {
    final q = _query.trim().toLowerCase();
    var filtered = _meetings;
    if (q.isNotEmpty) {
      filtered = filtered.where((meeting) {
        return meeting.title.toLowerCase().contains(q) ||
            (meeting.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
    
    // In a real app, we'd filter by _activeFilter here
    return filtered;
  }



  @override
  Widget build(BuildContext context) {
    final msgTheme = Theme.of(context).extension<MessagesThemeExtension>()!;
    final appTheme = Theme.of(context).extension<AppDesignExtension>()!;
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF), // Very light lavender background like image 1
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(user?.avatar, msgTheme),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadMeetings,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildQuickActions(),
                      const SizedBox(height: 32),
                      _buildUpcomingMeetingsHeader(),
                      const SizedBox(height: 16),
                      if (_loading)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ))
                      else if (_error != null)
                        Center(child: Text('Error: $_error'))
                      else if (_filteredMeetings.isEmpty)
                        const _EmptyMeetings()
                      else
                        ..._filteredMeetings.map((m) => _buildMeetingCard(m, appTheme)),
                      const SizedBox(height: 32),
                      _buildFilters(),
                      const SizedBox(height: 24),
                      _buildRecentCallsHeader(),
                      const SizedBox(height: 16),
                      _buildRecentCallsList(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String? profileImage, MessagesThemeExtension msgTheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFDFBFF),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            backgroundImage: profileImage != null ? CachedNetworkImageProvider(profileImage) : null,
            child: profileImage == null ? const Icon(LucideIcons.user, size: 20, color: Colors.grey) : null,
          ),
          Text(
            'Meet',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF33334F),
            ),
          ),
          IconButton(
            onPressed: () => _searchController.clear(),
            icon: const Icon(LucideIcons.search, size: 24, color: Color(0xFF33334F)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildQuickActionCard(
          icon: LucideIcons.link,
          label: 'Create link',
          iconColor: const Color(0xFF8B5CF6),
          bgColor: const Color(0xFFF5F3FF),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRoomScreen())),
        ),
        const SizedBox(width: 12),
        _buildQuickActionCard(
          icon: LucideIcons.calendar,
          label: 'Schedule',
          iconColor: const Color(0xFF3B82F6),
          bgColor: const Color(0xFFEFF6FF),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleMeetingScreen())),
        ),
        const SizedBox(width: 12),
        _buildQuickActionCard(
          icon: LucideIcons.layoutGrid,
          label: 'Join with ID',
          iconColor: const Color(0xFFEC4899),
          bgColor: const Color(0xFFFDF2F8),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinMeetingScreen())),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF33334F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingMeetingsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Upcoming Meetings',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF33334F),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'TODAY',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8B5CF6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingCard(MeetingModel meeting, AppDesignExtension appTheme) {
    final startTime = meeting.startTime.toLocal();
    final month = _getMonthName(startTime.month);
    final day = startTime.day.toString();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEBE6FF)),
      ),
      child: Row(
        children: [
          // Date block
          Column(
            children: [
              Text(
                month,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              Text(
                day,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF33334F),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Divider
          Container(
            height: 40,
            width: 1,
            color: const Color(0xFFDED9FF),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF33334F),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatTime(meeting.startTime)} - ${_formatTime(meeting.endTime)}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF71719A),
                  ),
                ),
              ],
            ),
          ),
          // Join Button
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinMeetingScreen())),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFFA855F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(LucideIcons.arrowRight, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'Links', 'Scheduled', 'Call logs'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters) ...[
            GestureDetector(
              onTap: () => setState(() => _activeFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: _activeFilter == filter
                      ? const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFFA855F7)],
                        )
                      : null,
                  color: _activeFilter == filter ? null : const Color(0xFFF3EEFF),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  filter,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _activeFilter == filter ? Colors.white : const Color(0xFF71719A),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentCallsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent calls',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF33334F),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'See all',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3B82F6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCallsList() {
    // Current backend doesn't seem to have call logs, using dummy data based on image
    final dummyCalls = [
      (name: 'Person 1', details: 'Last call: 10:48 • 11sec', type: 'outgoing'),
      (name: 'Person 7', details: 'Last call: Yesterday • 4m 20s', type: 'missed'),
      (name: 'Sarah Miller', details: 'Last call: Monday • 1h 12m', type: 'incoming'),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dummyCalls.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
      itemBuilder: (context, index) {
        final call = dummyCalls[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF3EEFF),
                child: Text(call.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF33334F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      call.details,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF71719A),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                call.type == 'missed' 
                  ? LucideIcons.arrowDownLeft 
                  : LucideIcons.arrowUpRight,
                size: 20,
                color: call.type == 'missed' ? Colors.red : const Color(0xFF71719A),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final minutes = local.minute.toString().padLeft(2, '0');
    return '$hour:$minutes';
  }
}

class _EmptyMeetings extends StatelessWidget {
  const _EmptyMeetings();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            LucideIcons.video,
            size: 40,
            color: Color(0xFFDED9FF),
          ),
          const SizedBox(height: 12),
          Text(
            'No meetings yet',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF33334F)),
          ),
          const SizedBox(height: 6),
          Text(
            'Create or schedule one to get started.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: const Color(0xFF71719A), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
