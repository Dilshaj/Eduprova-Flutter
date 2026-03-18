import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../messages/live_call_screen.dart';
import '../../models/meeting_model.dart';
import '../../repository/calling_repository.dart';
import 'create_room.dart';
import 'join_with_id.dart';
import 'schedule_meeting.dart';

class MeetScreen extends StatefulWidget {
  const MeetScreen({super.key});

  @override
  State<MeetScreen> createState() => _MeetScreenState();
}

class _MeetScreenState extends State<MeetScreen> {
  final CallingRepository _repository = CallingRepository();
  final TextEditingController _searchController = TextEditingController();
  List<MeetingModel> _meetings = const [];
  bool _loading = true;
  String _query = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    if (q.isEmpty) return _meetings;
    return _meetings.where((meeting) {
      return meeting.title.toLowerCase().contains(q) ||
          (meeting.description?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> _cancelMeeting(MeetingModel meeting) async {
    final updated = await _repository.cancelMeeting(meeting.id);
    if (!mounted) return;
    setState(() {
      _meetings = [
        for (final item in _meetings) if (item.id == updated.id) updated else item,
      ];
    });
  }

  Future<void> _joinMeeting(MeetingModel meeting) async {
    if (meeting.status == MeetingStatus.scheduled &&
        DateTime.now().isAfter(meeting.startTime)) {
      try {
        await _repository.updateMeetingStatus(meeting.id, 'ongoing');
      } catch (_) {}
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveCallScreen(
          roomName: meeting.roomName,
          initialVideo: true,
          initialAudio: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Meet'),
        actions: [
          IconButton(onPressed: _loadMeetings, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search meetings',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.video_call_rounded,
                      label: 'Instant',
                      color: const Color(0xFF2563EB),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.schedule_rounded,
                      label: 'Schedule',
                      color: const Color(0xFFDB2777),
                      onTap: () async {
                        final created = await Navigator.of(context).push<MeetingModel>(
                          MaterialPageRoute(
                            builder: (_) => const ScheduleMeetingScreen(),
                          ),
                        );
                        if (created != null && mounted) {
                          setState(() => _meetings = [created, ..._meetings]);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.login_rounded,
                      label: 'Join',
                      color: const Color(0xFF475569),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const JoinWithIdScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? _ErrorBody(message: _error!, onRetry: _loadMeetings)
                  : _filteredMeetings.isEmpty
                  ? const _EmptyMeetings()
                  : RefreshIndicator(
                      onRefresh: _loadMeetings,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: _filteredMeetings.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final meeting = _filteredMeetings[index];
                          return _MeetingCard(
                            meeting: meeting,
                            onJoin: () => _joinMeeting(meeting),
                            onCopy: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              await Clipboard.setData(
                                ClipboardData(text: meeting.meetingLink),
                              );
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Meeting link copied')),
                              );
                            },
                            onCancel: meeting.status == MeetingStatus.cancelled
                                ? null
                                : () => _cancelMeeting(meeting),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final MeetingModel meeting;
  final VoidCallback onJoin;
  final VoidCallback onCopy;
  final VoidCallback? onCancel;

  const _MeetingCard({
    required this.meeting,
    required this.onJoin,
    required this.onCopy,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final canJoin =
        meeting.status != MeetingStatus.cancelled &&
        now.isAfter(meeting.startTime) &&
        now.isBefore(meeting.endTime);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  meeting.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              _StatusChip(status: meeting.status),
            ],
          ),
          if (meeting.description != null && meeting.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              meeting.description!,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            '${_formatDate(meeting.startTime)} • ${_formatTime(meeting.startTime)} - ${_formatTime(meeting.endTime)}',
            style: const TextStyle(color: Color(0xFF475569)),
          ),
          const SizedBox(height: 6),
          Text(
            '${meeting.participants.length} participant(s)',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: canJoin ? onJoin : null,
                  icon: const Icon(Icons.video_call_rounded),
                  label: Text(canJoin ? 'Join now' : 'Starts later'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy'),
              ),
              if (onCancel != null) ...[
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }

  static String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final minutes = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minutes $suffix';
  }
}

class _StatusChip extends StatelessWidget {
  final MeetingStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      MeetingStatus.ongoing => ('Live', const Color(0xFF16A34A)),
      MeetingStatus.completed => ('Done', const Color(0xFF475569)),
      MeetingStatus.cancelled => ('Cancelled', const Color(0xFFDC2626)),
      MeetingStatus.scheduled => ('Scheduled', const Color(0xFF2563EB)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _EmptyMeetings extends StatelessWidget {
  const _EmptyMeetings();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_camera_front_outlined, size: 40, color: Color(0xFF94A3B8)),
            SizedBox(height: 12),
            Text(
              'No meetings yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Create an instant meeting or schedule one for later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => onRetry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
