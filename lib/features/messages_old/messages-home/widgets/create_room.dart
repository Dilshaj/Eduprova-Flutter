import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:eduprova/core/navigation/app_routes.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../models/call_room_model.dart';
import '../../models/search_user_model.dart';
import '../../providers/chat_socket_provider.dart';
import '../../repository/calling_repository.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final CallingRepository _repository = CallingRepository();
  CallRoomModel? _room;
  List<SearchUserModel> _participants = const [];
  bool _loading = false;
  String? _error;
  bool _cameraEnabled = true;
  bool _audioEnabled = true;

  Future<void> _createRoom() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final room = await _repository.createRoom(
        type: 'meet',
        participantIds: _participants.map((user) => user.id).toList(),
      );
      if (!mounted) return;
      setState(() {
        _room = room;
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
    setState(() {
      _participants = result;
      _room = null; // Reset room if participants change to force re-creation
    });
  }

  Future<void> _startMeeting() async {
    final room = _room;
    if (room == null) return;

    final authState = ref.read(authProvider);
    final user = authState.user;
    if (_participants.isNotEmpty && user != null) {
      ref
          .read(chatSocketProvider.notifier)
          .emitCallInvite(
            recipientIds: _participants.map((item) => item.id).toList(),
            roomName: room.roomName,
            conversationType: 'meet',
            callerName: '${user.firstName} ${user.lastName}'.trim(),
            callerAvatar: user.avatar,
          );
    }

    if (!mounted) return;
    context.push(
      AppRoutes.meetCall(room.roomName),
      extra: {
        'initialRoom': room,
        'initialVideo': _cameraEnabled,
        'initialAudio': _audioEnabled,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).extension<AppDesignExtension>()!;
    
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
          'Create Instant Meeting',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF33334F),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopInfo(),
              const SizedBox(height: 32),
              _buildParticipantsSection(),
              if (_room != null) ...[
                const SizedBox(height: 32),
                _buildMeetingLinkCard(),
                const SizedBox(height: 16),
                _buildActionRow(
                  icon: LucideIcons.share2,
                  label: 'Share via',
                  iconColor: const Color(0xFF3B82F6),
                  bgColor: const Color(0xFFEFF6FF),
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildActionRow(
                  icon: LucideIcons.messageSquare,
                  label: 'Send to chat',
                  iconColor: const Color(0xFF8B5CF6),
                  bgColor: const Color(0xFFF5F3FF),
                  onTap: () {},
                ),
                const SizedBox(height: 32),
                _buildJoinOptions(),
                const SizedBox(height: 40),
                _buildStartMeetingButton(),
              ] else ...[
                const SizedBox(height: 48),
                _buildCreateRoomButton(),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F0FF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(LucideIcons.video, color: Color(0xFF3B82F6), size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            'Instant Meeting',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF33334F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a quick meeting and invite others to join you instantly.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF71719A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Participants',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF33334F),
              ),
            ),
            TextButton.icon(
              onPressed: _pickParticipants,
              icon: const Icon(LucideIcons.userPlus, size: 18),
              label: Text(
                'Add',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_participants.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEBE6FF), style: BorderStyle.solid),
            ),
            child: Text(
              'No participants selected yet',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF71719A),
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final participant in _participants)
                Chip(
                  label: Text(
                    participant.displayName,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF33334F)),
                  ),
                  backgroundColor: const Color(0xFFF3EEFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide.none,
                  deleteIcon: const Icon(LucideIcons.x, size: 14, color: Color(0xFF71719A)),
                  onDeleted: () {
                    setState(() {
                      _participants = _participants.where((p) => p.id != participant.id).toList();
                      _room = null;
                    });
                  },
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildMeetingLinkCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F0FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MEETING LINK',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: const Color(0xFFBCBCCF),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _room!.joinUrl,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF33334F),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: _room!.joinUrl));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meeting link copied')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.copy, size: 20, color: Color(0xFF3B82F6)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0F0FF)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF33334F),
                ),
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 18, color: Color(0xFFBCBCCF)),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateRoomButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
        onPressed: _loading ? null : _createRoom,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _loading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.plus, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Create Meeting Room',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStartMeetingButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: .circular(30),
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
        onPressed: _startMeeting,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: .circular(30)),
        ),
        child: Row(
          mainAxisAlignment: .center,
          children: [
            Text(
              'Start Meeting',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Icon(LucideIcons.arrowRight, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinOptions() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'JOIN OPTIONS',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: const Color(0xFFBCBCCF),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _JoinOptionToggle(
                icon: LucideIcons.video,
                offIcon: LucideIcons.videoOff,
                label: 'Camera',
                enabled: _cameraEnabled,
                onToggle: (v) => setState(() => _cameraEnabled = v),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _JoinOptionToggle(
                icon: LucideIcons.mic,
                offIcon: LucideIcons.micOff,
                label: 'Microphone',
                enabled: _audioEnabled,
                onToggle: (v) => setState(() => _audioEnabled = v),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _JoinOptionToggle extends StatelessWidget {
  final IconData icon;
  final IconData offIcon;
  final String label;
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const _JoinOptionToggle({
    required this.icon,
    required this.offIcon,
    required this.label,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? const Color(0xFF0066FF) : const Color(0xFFBCBCCF);
    final bgColor = enabled ? const Color(0xFFEFF6FF) : const Color(0xFFF9F7FF);

    return GestureDetector(
      onTap: () => onToggle(!enabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: .symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: .circular(20),
          border: Border.all(
            color: enabled ? color.withValues(alpha: 0.2) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(enabled ? icon : offIcon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                color: enabled ? const Color(0xFF33334F) : const Color(0xFF71719A),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              enabled ? 'On' : 'Off',
              style: GoogleFonts.inter(
                color: enabled ? color : const Color(0xFFBCBCCF),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

