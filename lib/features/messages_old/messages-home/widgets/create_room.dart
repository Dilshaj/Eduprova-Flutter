import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../messages/live_call_screen.dart';
import '../../models/call_room_model.dart';
import '../../models/search_user_model.dart';
import '../../providers/chat_socket_provider.dart';
import '../../repository/calling_repository.dart';
import '../../widgets/participant_picker_screen.dart';

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
    final result = await Navigator.of(context).push<List<SearchUserModel>>(
      MaterialPageRoute(
        builder: (_) => ParticipantPickerScreen(
          title: 'Add Participants',
          submitLabel: 'Done',
          initialSelected: _participants,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _participants = result);
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveCallScreen(
          initialRoom: room,
          initialVideo: true,
          initialAudio: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instant Meeting')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _room == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Column(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: Color(0xFFDBEAFE),
                            child: Icon(
                              Icons.videocam_rounded,
                              color: Color(0xFF2563EB),
                              size: 34,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Create an instant meeting',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add people first if you want to notify them as soon as you start.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      title: const Text('Participants'),
                      subtitle: Text(
                        _participants.isEmpty
                            ? 'No participants selected'
                            : _participants
                                  .map((item) => item.displayName)
                                  .join(', '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.group_add_outlined),
                      onTap: _pickParticipants,
                    ),
                    if (_participants.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final participant in _participants)
                            InputChip(
                              label: Text(participant.displayName),
                              onDeleted: () {
                                setState(() {
                                  _participants = _participants
                                      .where(
                                        (item) => item.id != participant.id,
                                      )
                                      .toList();
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _loading ? null : _createRoom,
                      icon: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.videocam_rounded),
                      label: Text(
                        _loading ? 'Creating...' : 'Create Meeting Room',
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ],
                )
              : _error != null
              ? _ErrorPanel(message: _error!, onRetry: _createRoom)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 34,
                            backgroundColor: Color(0xFFDBEAFE),
                            child: Icon(
                              Icons.videocam_rounded,
                              color: Color(0xFF2563EB),
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Your meeting room is ready',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _room!.roomName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Join link',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(_room!.joinUrl),
                    ),
                    if (_participants.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Inviting ${_participants.length} participant(s) when you start',
                        style: const TextStyle(color: Color(0xFF475569)),
                      ),
                    ],
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await Clipboard.setData(
                          ClipboardData(text: _room!.joinUrl),
                        );
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Meeting link copied')),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text('Copy Link'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _startMeeting,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Start Meeting'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 36, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
