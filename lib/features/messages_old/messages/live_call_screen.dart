import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../models/call_room_model.dart';
import '../repository/calling_repository.dart';

class LiveCallScreen extends StatefulWidget {
  final CallRoomModel? initialRoom;
  final String? roomName;
  final bool initialVideo;
  final bool initialAudio;

  const LiveCallScreen({
    super.key,
    this.initialRoom,
    this.roomName,
    this.initialVideo = true,
    this.initialAudio = true,
  });

  @override
  State<LiveCallScreen> createState() => _LiveCallScreenState();
}

class _LiveCallScreenState extends State<LiveCallScreen> {
  final CallingRepository _repository = CallingRepository();

  Room? _room;
  EventsListener<RoomEvent>? _eventsListener;
  CallRoomModel? _roomData;
  bool _isConnecting = true;
  bool _isMicEnabled = true;
  bool _isCameraEnabled = true;
  bool _speakerOn = true;
  String? _error;
  List<Participant> _participants = const [];

  @override
  void initState() {
    super.initState();
    _isMicEnabled = widget.initialAudio;
    _isCameraEnabled = widget.initialVideo;
    _connect();
  }

  Future<void> _connect() async {
    try {
      final roomData =
          widget.initialRoom ??
          await _repository.getToken(widget.roomName ?? '');
      if (roomData.roomName.isEmpty || roomData.serverUrl.isEmpty) {
        throw Exception('Invalid room data received from server');
      }

      final room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultAudioOutputOptions: AudioOutputOptions(speakerOn: true),
        ),
      );

      _roomData = roomData;
      _room = room;
      _eventsListener = room.createListener()
        ..on<ParticipantEvent>((_) {
          if (mounted) setState(_refreshParticipants);
        })
        ..on<RoomEvent>((_) {
          if (mounted) setState(_refreshParticipants);
        });
      room.addListener(_refreshParticipants);

      await room.connect(roomData.serverUrl, roomData.token);
      await room.localParticipant?.setMicrophoneEnabled(_isMicEnabled);
      await room.localParticipant?.setCameraEnabled(_isCameraEnabled);
      await Hardware.instance.setSpeakerphoneOn(_speakerOn);

      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _error = null;
      });
      _refreshParticipants();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _error = e.toString();
      });
    }
  }

  void _refreshParticipants() {
    final room = _room;
    if (room == null) return;
    final items = <Participant>[];
    final local = room.localParticipant;
    if (local != null) {
      items.add(local);
    }
    items.addAll(room.remoteParticipants.values);
    _participants = items;
  }

  Future<void> _toggleMic() async {
    final next = !_isMicEnabled;
    await _room?.localParticipant?.setMicrophoneEnabled(next);
    if (!mounted) return;
    setState(() => _isMicEnabled = next);
  }

  Future<void> _toggleCamera() async {
    final next = !_isCameraEnabled;
    await _room?.localParticipant?.setCameraEnabled(next);
    if (!mounted) return;
    setState(() => _isCameraEnabled = next);
  }

  Future<void> _toggleSpeaker() async {
    final next = !_speakerOn;
    await Hardware.instance.setSpeakerphoneOn(next);
    if (!mounted) return;
    setState(() => _speakerOn = next);
  }

  Future<void> _disconnect() async {
    await _eventsListener?.dispose();
    _eventsListener = null;
    _room?.removeListener(_refreshParticipants);
    await _room?.disconnect();
    await _room?.dispose();
    _room = null;
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _eventsListener?.dispose();
    _room?.removeListener(_refreshParticipants);
    unawaited(_room?.disconnect());
    unawaited(_room?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomName = _roomData?.roomName ?? widget.roomName ?? 'Meeting';
    return Scaffold(
      backgroundColor: const Color(0xFF09101F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09101F),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_titleForRoom(roomName)),
            Text(
              roomName,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: _isConnecting
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorState(message: _error!, onBack: () => Navigator.of(context).pop())
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      itemCount: _participants.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.78,
                          ),
                      itemBuilder: (context, index) {
                        return _ParticipantTile(participant: _participants[index]);
                      },
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CallActionButton(
                          icon: _isMicEnabled ? Icons.mic : Icons.mic_off,
                          active: _isMicEnabled,
                          onTap: _toggleMic,
                        ),
                        _CallActionButton(
                          icon: _isCameraEnabled
                              ? Icons.videocam
                              : Icons.videocam_off,
                          active: _isCameraEnabled,
                          onTap: _toggleCamera,
                        ),
                        _CallActionButton(
                          icon: _speakerOn ? Icons.volume_up : Icons.hearing_disabled,
                          active: _speakerOn,
                          onTap: _toggleSpeaker,
                        ),
                        _CallActionButton(
                          icon: Icons.call_end,
                          active: true,
                          danger: true,
                          onTap: _disconnect,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _titleForRoom(String roomName) {
    if (roomName.startsWith('dm:')) return 'Direct Call';
    if (roomName.startsWith('grp:')) return 'Group Call';
    if (roomName.startsWith('meeting:')) return 'Scheduled Meeting';
    return 'Meeting';
  }
}

class _ParticipantTile extends StatelessWidget {
  final Participant participant;

  const _ParticipantTile({required this.participant});

  @override
  Widget build(BuildContext context) {
    final videoTrack = _firstVideoTrack(participant);
    final audioOn = _isAudioOn(participant);
    final displayName = participant.name.isNotEmpty
        ? participant.name
        : participant.identity;
    final avatarUrl = _avatarUrl(participant.metadata);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF172033),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: participant.isSpeaking
              ? const Color(0xFF3B82F6)
              : Colors.white.withValues(alpha: 0.08),
          width: participant.isSpeaking ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (videoTrack != null)
            VideoTrackRenderer(videoTrack)
          else
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 34,
                        backgroundImage: NetworkImage(avatarUrl),
                      )
                    : CircleAvatar(
                        radius: 34,
                        backgroundColor: const Color(0xFF334155),
                        child: Text(
                          _initials(displayName),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                      ),
              ),
            ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    audioOn ? Icons.mic : Icons.mic_off,
                    color: audioOn ? Colors.white : Colors.redAccent,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static VideoTrack? _firstVideoTrack(Participant participant) {
    for (final publication in participant.videoTrackPublications) {
      if (publication.track != null && !publication.muted) {
        return publication.track as VideoTrack?;
      }
    }
    return null;
  }

  static bool _isAudioOn(Participant participant) {
    for (final publication in participant.audioTrackPublications) {
      if (publication.track != null && !publication.muted) {
        return true;
      }
    }
    return false;
  }

  static String _initials(String name) {
    final parts = name
        .split(' ')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static String? _avatarUrl(String? metadata) {
    if (metadata == null || metadata.isEmpty) return null;
    try {
      final decoded = jsonDecode(metadata);
      if (decoded is Map<String, dynamic>) {
        return decoded['avatar']?.toString();
      }
    } catch (_) {}
    return null;
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool danger;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.icon,
    required this.active,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final background = danger
        ? const Color(0xFFDC2626)
        : active
        ? Colors.white
        : Colors.white.withValues(alpha: 0.12);
    final foreground = danger
        ? Colors.white
        : active
        ? const Color(0xFF0F172A)
        : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 58,
        height: 58,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: foreground),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onBack;

  const _ErrorState({required this.message, required this.onBack});

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
            const Text(
              'Unable to join call',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onBack, child: const Text('Back')),
          ],
        ),
      ),
    );
  }
}
