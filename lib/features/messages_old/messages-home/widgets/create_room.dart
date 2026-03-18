import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../messages/live_call_screen.dart';
import '../../models/call_room_model.dart';
import '../../repository/calling_repository.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final CallingRepository _repository = CallingRepository();
  CallRoomModel? _room;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _createRoom();
  }

  Future<void> _createRoom() async {
    try {
      final room = await _repository.createRoom(type: 'meet');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instant Meeting')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
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
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await Clipboard.setData(ClipboardData(text: _room!.joinUrl));
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
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LiveCallScreen(
                              initialRoom: _room,
                              initialVideo: true,
                              initialAudio: true,
                            ),
                          ),
                        );
                      },
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
