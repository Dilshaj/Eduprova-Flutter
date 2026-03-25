import 'package:flutter/material.dart';

import '../../messages/live_call_screen.dart';

class JoinWithIdScreen extends StatefulWidget {
  const JoinWithIdScreen({super.key});

  @override
  State<JoinWithIdScreen> createState() => _JoinWithIdScreenState();
}

class _JoinWithIdScreenState extends State<JoinWithIdScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _join() {
    final parsed = _parseRoomName(_controller.text);
    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid room name or meeting link'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveCallScreen(
          roomName: parsed,
          initialVideo: true,
          initialAudio: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Meeting')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Paste a room name or a full Eduprova meeting link.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Room / Link',
                  hintText:
                      'meeting:abc123 or https://.../dashboard/meet/meeting:abc123',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _join,
                icon: const Icon(Icons.login_rounded),
                label: const Text('Join Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _parseRoomName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('dm:') ||
        trimmed.startsWith('grp:') ||
        trimmed.startsWith('meet:') ||
        trimmed.startsWith('meeting:')) {
      return trimmed;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      final segments = uri.pathSegments;
      final meetIndex = segments.indexOf('meet');
      if (meetIndex != -1 && meetIndex + 1 < segments.length) {
        return Uri.decodeComponent(segments[meetIndex + 1]);
      }
    }

    return null;
  }
}
