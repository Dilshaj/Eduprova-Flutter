import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_background/flutter_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' show Helper;
import 'package:livekit_client/livekit_client.dart';

import '../models/call_room_model.dart';
import '../models/search_user_model.dart';
import '../providers/chat_socket_provider.dart';
import '../repository/calling_repository.dart';
import '../widgets/participant_picker_screen.dart';

class LiveCallScreen extends ConsumerStatefulWidget {
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
  ConsumerState<LiveCallScreen> createState() => _LiveCallScreenState();
}

class _LiveCallScreenState extends ConsumerState<LiveCallScreen> {
  final CallingRepository _repository = CallingRepository();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final math.Random _random = math.Random();

  Room? _room;
  EventsListener<RoomEvent>? _eventsListener;
  CallRoomModel? _roomData;
  bool _isConnecting = true;
  bool _isMicEnabled = true;
  bool _isCameraEnabled = true;
  bool _speakerOn = true;
  bool _showChatPanel = false;
  bool _isScreenShareEnabled = false;
  String? _error;
  String? _focusedParticipantIdentity;
  List<Participant> _participants = const [];
  List<_CallChatMessage> _chatMessages = const [];
  List<_FloatingReaction> _floatingReactions = const [];
  Map<String, bool> _raisedHands = const {};

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
          if (mounted) {
            setState(_refreshParticipants);
          }
        })
        ..on<RoomEvent>((_) {
          if (mounted) {
            setState(_refreshParticipants);
          }
        })
        ..on<DataReceivedEvent>(_onDataReceived);
      room.registerTextStreamHandler('chat', _onTextChatReceived);
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

  void _onDataReceived(DataReceivedEvent event) {
    final raw = utf8.decode(event.data);
    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      payload = decoded;
    } catch (_) {
      return;
    }

    final type = payload['type']?.toString() ?? '';
    final senderIdentity =
        event.participant?.identity ?? payload['identity']?.toString() ?? '';
    final senderName =
        event.participant?.name ??
        payload['name']?.toString() ??
        senderIdentity;

    if (type == 'chat') {
      _appendRemoteChatMessage(
        id:
            payload['id']?.toString() ??
            '${senderIdentity}_${DateTime.now().microsecondsSinceEpoch}',
        senderIdentity: senderIdentity,
        senderName: senderName,
        text: payload['text']?.toString() ?? '',
        timestamp: DateTime.tryParse(payload['timestamp']?.toString() ?? ''),
      );
      return;
    }

    if (event.topic == 'interactions' && type == 'emoji') {
      final emoji = payload['emoji']?.toString() ?? '';
      if (emoji.isEmpty) return;
      _showReaction(emoji, senderIdentity);
      return;
    }

    if (event.topic == 'interactions' && type == 'hand_raise') {
      final isRaised = payload['isRaised'] == true;
      setState(() {
        _raisedHands = {..._raisedHands, senderIdentity: isRaised};
      });
    }
  }

  Future<void> _onTextChatReceived(
    TextStreamReader reader,
    String participantIdentity,
  ) async {
    final text = (await reader.readAll()).trim();
    if (text.isEmpty || !mounted) return;
    final info = reader.info;

    final sender = _participants.cast<Participant?>().firstWhere(
      (participant) => participant?.identity == participantIdentity,
      orElse: () => null,
    );

    _appendRemoteChatMessage(
      id:
          info?.id ??
          '${participantIdentity}_${DateTime.now().microsecondsSinceEpoch}',
      senderIdentity: participantIdentity,
      senderName: sender?.name.isNotEmpty == true
          ? sender!.name
          : participantIdentity,
      text: text,
      timestamp: info == null
          ? DateTime.now().toUtc()
          : DateTime.fromMillisecondsSinceEpoch(info.timestamp, isUtc: true),
    );
  }

  void _appendRemoteChatMessage({
    required String id,
    required String senderIdentity,
    required String senderName,
    required String text,
    required DateTime? timestamp,
  }) {
    final clean = text.trim();
    if (clean.isEmpty) return;
    final exists = _chatMessages.any((message) => message.id == id);
    if (exists) return;
    setState(() {
      _chatMessages = [
        ..._chatMessages,
        _CallChatMessage(
          id: id,
          senderIdentity: senderIdentity,
          senderName: senderName,
          text: clean,
          timestamp: timestamp,
          isMine: false,
        ),
      ];
    });
    _scrollChatToEnd();
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

    items.sort((a, b) {
      if (a.isSpeaking == b.isSpeaking) {
        return a.identity.compareTo(b.identity);
      }
      return a.isSpeaking ? -1 : 1;
    });

    _participants = items;
    final identities = items.map((item) => item.identity).toSet();
    if (_focusedParticipantIdentity == null ||
        !identities.contains(_focusedParticipantIdentity)) {
      _focusedParticipantIdentity = items.isNotEmpty
          ? items.first.identity
          : null;
    }

    final activeSpeaker = items
        .where((item) => item.isSpeaking)
        .cast<Participant?>()
        .firstOrNull;
    if (activeSpeaker != null &&
        _focusedParticipantIdentity != activeSpeaker.identity &&
        !_showChatPanel) {
      _focusedParticipantIdentity = activeSpeaker.identity;
    }
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

  Future<void> _toggleScreenShare() async {
    final next = !_isScreenShareEnabled;
    try {
      if (next && lkPlatformIs(PlatformType.android)) {
        final hasCapturePermission = await Helper.requestCapturePermission();
        if (!hasCapturePermission) {
          return;
        }
        await _enableAndroidBackgroundScreenShare();
      }

      await _room?.localParticipant?.setScreenShareEnabled(next);
      if (!mounted) return;
      setState(() => _isScreenShareEnabled = next);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share screen: $e')));
      }
    }
  }

  Future<void> _enableAndroidBackgroundScreenShare([
    bool isRetry = false,
  ]) async {
    try {
      bool hasPermissions = await FlutterBackground.hasPermissions;
      if (!isRetry) {
        const androidConfig = FlutterBackgroundAndroidConfig(
          notificationTitle: 'Screen Sharing',
          notificationText: 'Eduprova is sharing your screen.',
          notificationImportance: AndroidNotificationImportance.normal,
          notificationIcon: AndroidResource(
            name: 'ic_launcher',
            defType: 'mipmap',
          ),
        );
        hasPermissions = await FlutterBackground.initialize(
          androidConfig: androidConfig,
        );
      }
      if (hasPermissions && !FlutterBackground.isBackgroundExecutionEnabled) {
        await FlutterBackground.enableBackgroundExecution();
      }
    } catch (e) {
      if (!isRetry) {
        await Future<void>.delayed(
          const Duration(seconds: 1),
          () => _enableAndroidBackgroundScreenShare(true),
        );
        return;
      }
      rethrow;
    }
  }

  Future<void> _disconnect() async {
    await _eventsListener?.dispose();
    _eventsListener = null;
    _room?.unregisterTextStreamHandler('chat');
    _room?.removeListener(_refreshParticipants);
    await _room?.disconnect();
    await _room?.dispose();
    _room = null;
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _sendChatMessage() async {
    final text = _chatController.text.trim();
    final room = _room;
    final local = room?.localParticipant;
    if (text.isEmpty || local == null) return;

    final info = await local.sendText(
      text,
      options: SendTextOptions(topic: 'chat'),
    );

    final fallbackPayload = {
      'type': 'chat',
      'id': info.id,
      'identity': local.identity,
      'name': local.name,
      'text': text,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    unawaited(
      local.publishData(
        utf8.encode(jsonEncode(fallbackPayload)),
        reliable: true,
        topic: 'chat',
      ),
    );

    if (!mounted) return;
    setState(() {
      _chatMessages = [
        ..._chatMessages,
        _CallChatMessage(
          id: info.id,
          senderIdentity: local.identity,
          senderName: local.name,
          text: text,
          timestamp: DateTime.now(),
          isMine: true,
        ),
      ];
    });
    _chatController.clear();
    _scrollChatToEnd();
  }

  Future<void> _sendReaction(String emoji) async {
    final local = _room?.localParticipant;
    if (local == null) return;
    final payload = {
      'type': 'emoji',
      'emoji': emoji,
      'identity': local.identity,
      'name': local.name,
    };
    _showReaction(emoji, local.identity);
    await local.publishData(
      utf8.encode(jsonEncode(payload)),
      reliable: false,
      topic: 'interactions',
    );
  }

  Future<void> _toggleHandRaise() async {
    final local = _room?.localParticipant;
    if (local == null) return;
    final next = !(_raisedHands[local.identity] ?? false);
    setState(() {
      _raisedHands = {..._raisedHands, local.identity: next};
    });
    final payload = {
      'type': 'hand_raise',
      'identity': local.identity,
      'name': local.name,
      'isRaised': next,
    };
    await local.publishData(
      utf8.encode(jsonEncode(payload)),
      reliable: true,
      topic: 'interactions',
    );
  }

  Future<void> _inviteParticipants() async {
    final roomName = _roomData?.roomName ?? widget.roomName;
    final local = _room?.localParticipant;
    if (roomName == null || roomName.isEmpty || local == null) return;

    final selected = await Navigator.of(context).push<List<SearchUserModel>>(
      MaterialPageRoute(
        builder: (_) => const ParticipantPickerScreen(
          title: 'Add Participants',
          submitLabel: 'Invite',
        ),
      ),
    );

    if (!mounted || selected == null || selected.isEmpty) return;

    ref
        .read(chatSocketProvider.notifier)
        .emitCallInvite(
          recipientIds: selected.map((item) => item.id).toList(),
          roomName: roomName,
          conversationType: roomName.startsWith('grp:') ? 'group' : 'meet',
          callerName: local.name,
          callerAvatar: _avatarFromMetadata(local.metadata),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invited ${selected.length} participant(s)')),
    );
  }

  void _showReaction(String emoji, String identity) {
    final reaction = _FloatingReaction(
      id: '${identity}_${DateTime.now().microsecondsSinceEpoch}',
      emoji: emoji,
      startX: 0.12 + (_random.nextDouble() * 0.7),
    );

    setState(() {
      _floatingReactions = [..._floatingReactions, reaction];
    });

    Future<void>.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      setState(() {
        _floatingReactions = _floatingReactions
            .where((item) => item.id != reaction.id)
            .toList();
      });
    });
  }

  void _scrollChatToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScrollController.hasClients) return;
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Participant? get _focusedParticipant {
    final identity = _focusedParticipantIdentity;
    if (identity == null) {
      return _participants.isNotEmpty ? _participants.first : null;
    }
    for (final participant in _participants) {
      if (participant.identity == identity) return participant;
    }
    return _participants.isNotEmpty ? _participants.first : null;
  }

  List<Participant> get _otherParticipants {
    final focused = _focusedParticipant;
    if (focused == null) return _participants;
    return _participants
        .where((participant) => participant.identity != focused.identity)
        .toList();
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    _eventsListener?.dispose();
    _room?.unregisterTextStreamHandler('chat');
    _room?.removeListener(_refreshParticipants);
    unawaited(_room?.disconnect());
    unawaited(_room?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomName = _roomData?.roomName ?? widget.roomName ?? 'Meeting';
    final focusedParticipant = _focusedParticipant;
    final localIdentity = _room?.localParticipant?.identity;
    final localHandRaised =
        localIdentity != null && (_raisedHands[localIdentity] ?? false);

    return Scaffold(
      backgroundColor: const Color(0xFF08111E),
      body: _isConnecting
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorState(
              message: _error!,
              onBack: () => Navigator.of(context).pop(),
            )
          : SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      _CallTopBar(
                        title: _titleForRoom(roomName),
                        roomName: roomName,
                        participantCount: _participants.length,
                        onChatToggle: () {
                          setState(() => _showChatPanel = !_showChatPanel);
                          if (_showChatPanel) {
                            _scrollChatToEnd();
                          }
                        },
                        showChat: _showChatPanel,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                          child: focusedParticipant == null
                              ? const Center(
                                  child: Text(
                                    'Waiting for participants...',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                )
                              : _FocusedMeetingBody(
                                  focused: focusedParticipant,
                                  others: _otherParticipants,
                                  raisedHands: _raisedHands,
                                  onSelectParticipant: (participant) {
                                    setState(() {
                                      _focusedParticipantIdentity =
                                          participant.identity;
                                    });
                                  },
                                ),
                        ),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _CallActionButton(
                                icon: _isMicEnabled ? Icons.mic : Icons.mic_off,
                                active: _isMicEnabled,
                                label: _isMicEnabled ? 'Mic' : 'Mic Off',
                                onTap: _toggleMic,
                              ),
                              _CallActionButton(
                                icon: _isCameraEnabled
                                    ? Icons.videocam
                                    : Icons.videocam_off,
                                active: _isCameraEnabled,
                                label: _isCameraEnabled
                                    ? 'Camera'
                                    : 'Camera Off',
                                onTap: _toggleCamera,
                              ),
                              _CallActionButton(
                                icon: _speakerOn
                                    ? Icons.volume_up
                                    : Icons.hearing_disabled,
                                active: _speakerOn,
                                label: _speakerOn ? 'Speaker' : 'Earpiece',
                                onTap: _toggleSpeaker,
                              ),
                              _CallActionButton(
                                icon: _isScreenShareEnabled
                                    ? Icons.stop_screen_share
                                    : Icons.screen_share,
                                active: _isScreenShareEnabled,
                                label: _isScreenShareEnabled
                                    ? 'Stop Share'
                                    : 'Share Screen',
                                onTap: _toggleScreenShare,
                              ),
                              _ReactionMenuButton(
                                onEmojiSelected: _sendReaction,
                              ),
                              _CallActionButton(
                                icon: Icons.pan_tool_alt,
                                active: localHandRaised,
                                label: localHandRaised ? 'Hand Up' : 'Raise',
                                tint: const Color(0xFFF59E0B),
                                onTap: _toggleHandRaise,
                              ),
                              _CallActionButton(
                                icon: Icons.person_add_alt_1,
                                active: true,
                                label: 'Add People',
                                onTap: _inviteParticipants,
                              ),
                              _CallActionButton(
                                icon: Icons.call_end,
                                active: true,
                                danger: true,
                                label: 'Leave',
                                onTap: _disconnect,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  IgnorePointer(
                    ignoring: true,
                    child: _ReactionLayer(reactions: _floatingReactions),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    top: 0,
                    right: _showChatPanel ? 0 : -320,
                    bottom: 0,
                    width: 320,
                    child: _CallChatPanel(
                      messages: _chatMessages,
                      controller: _chatController,
                      scrollController: _chatScrollController,
                      onClose: () => setState(() => _showChatPanel = false),
                      onSend: _sendChatMessage,
                    ),
                  ),
                ],
              ),
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

class _FocusedMeetingBody extends StatelessWidget {
  final Participant focused;
  final List<Participant> others;
  final Map<String, bool> raisedHands;
  final ValueChanged<Participant> onSelectParticipant;

  const _FocusedMeetingBody({
    required this.focused,
    required this.others,
    required this.raisedHands,
    required this.onSelectParticipant,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _ParticipantCard(
            participant: focused,
            raisedHand: raisedHands[focused.identity] ?? false,
            large: true,
          ),
        ),
        if (others.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: others.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final participant = others[index];
                return SizedBox(
                  width: 138,
                  child: GestureDetector(
                    onTap: () => onSelectParticipant(participant),
                    child: _ParticipantCard(
                      participant: participant,
                      raisedHand: raisedHands[participant.identity] ?? false,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  final Participant participant;
  final bool raisedHand;
  final bool large;

  const _ParticipantCard({
    required this.participant,
    required this.raisedHand,
    this.large = false,
  });

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
        color: const Color(0xFF162235),
        borderRadius: BorderRadius.circular(large ? 28 : 22),
        border: Border.all(
          color: participant.isSpeaking
              ? const Color(0xFF38BDF8)
              : Colors.white.withValues(alpha: 0.08),
          width: participant.isSpeaking ? 2.4 : 1,
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
                        radius: large ? 52 : 28,
                        backgroundImage: NetworkImage(avatarUrl),
                      )
                    : Container(
                        width: large ? 112 : 56,
                        height: large ? 112 : 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(large ? 36 : 20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _initials(displayName),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: large ? 34 : 18,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          if (raisedHand)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE68A),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Hand Raised',
                  style: TextStyle(
                    color: Color(0xFF854D0E),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: large ? 15 : 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    audioOn ? Icons.mic : Icons.mic_off,
                    color: audioOn ? Colors.white : Colors.redAccent,
                    size: large ? 20 : 18,
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
    // Prioritize screen share tracks
    for (final publication in participant.videoTrackPublications) {
      if (publication.track != null &&
          !publication.muted &&
          publication.source == TrackSource.screenShareVideo) {
        return publication.track as VideoTrack?;
      }
    }

    // Fallback to camera tracks
    for (final publication in participant.videoTrackPublications) {
      if (publication.track != null &&
          !publication.muted &&
          publication.source == TrackSource.camera) {
        return publication.track as VideoTrack?;
      }
    }

    // Default to the first available non-muted video track
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

class _CallTopBar extends StatelessWidget {
  final String title;
  final String roomName;
  final int participantCount;
  final bool showChat;
  final VoidCallback onChatToggle;

  const _CallTopBar({
    required this.title,
    required this.roomName,
    required this.participantCount,
    required this.showChat,
    required this.onChatToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$participantCount participants • $roomName',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonalIcon(
            onPressed: onChatToggle,
            style: FilledButton.styleFrom(
              backgroundColor: showChat
                  ? const Color(0xFFDBEAFE)
                  : Colors.white.withValues(alpha: 0.1),
              foregroundColor: showChat
                  ? const Color(0xFF1D4ED8)
                  : Colors.white,
            ),
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(showChat ? 'Hide Chat' : 'Chat'),
          ),
        ],
      ),
    );
  }
}

class _ReactionMenuButton extends StatelessWidget {
  final ValueChanged<String> onEmojiSelected;

  const _ReactionMenuButton({required this.onEmojiSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Send reaction',
      color: const Color(0xFF132033),
      onSelected: onEmojiSelected,
      itemBuilder: (context) => const [
        PopupMenuItem(value: '👍', child: Text('👍  Like')),
        PopupMenuItem(value: '❤️', child: Text('❤️  Love')),
        PopupMenuItem(value: '😂', child: Text('😂  Laugh')),
        PopupMenuItem(value: '🎉', child: Text('🎉  Celebrate')),
        PopupMenuItem(value: '🔥', child: Text('🔥  Fire')),
      ],
      child: const _CallActionButton(
        icon: Icons.emoji_emotions_outlined,
        active: true,
        label: 'React',
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool danger;
  final String label;
  final Color? tint;
  final VoidCallback? onTap;

  const _CallActionButton({
    required this.icon,
    required this.active,
    required this.label,
    this.onTap,
    this.danger = false,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final background = danger
        ? const Color(0xFFDC2626)
        : active
        ? (tint?.withValues(alpha: 0.18) ?? Colors.white)
        : Colors.white.withValues(alpha: 0.12);
    final foreground = danger
        ? Colors.white
        : active
        ? (tint ?? const Color(0xFF0F172A))
        : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foreground, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallChatPanel extends StatelessWidget {
  final List<_CallChatMessage> messages;
  final TextEditingController controller;
  final ScrollController scrollController;
  final VoidCallback onClose;
  final VoidCallback onSend;

  const _CallChatPanel({
    required this.messages,
    required this.controller,
    required this.scrollController,
    required this.onClose,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0B1524),
      elevation: 12,
      child: SafeArea(
        left: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 10, 6),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'In-call chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: messages.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No messages yet.\nSend a message to everyone in the meeting.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white60),
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                      itemCount: messages.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return Align(
                          alignment: message.isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 240),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: message.isMine
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF17263B),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.isMine ? 'You' : message.senderName,
                                  style: TextStyle(
                                    color: message.isMine
                                        ? Colors.white70
                                        : const Color(0xFF93C5FD),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Message everyone',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF132033),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: onSend,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      minimumSize: const Size(52, 52),
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionLayer extends StatelessWidget {
  final List<_FloatingReaction> reactions;

  const _ReactionLayer({required this.reactions});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final reaction in reactions)
          _ReactionBubble(reaction: reaction, key: ValueKey(reaction.id)),
      ],
    );
  }
}

class _ReactionBubble extends StatefulWidget {
  final _FloatingReaction reaction;

  const _ReactionBubble({super.key, required this.reaction});

  @override
  State<_ReactionBubble> createState() => _ReactionBubbleState();
}

class _ReactionBubbleState extends State<_ReactionBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        final bottom = 80 + (progress * 260);
        final opacity = progress < 0.1
            ? progress / 0.1
            : progress > 0.8
            ? 1 - ((progress - 0.8) / 0.2)
            : 1.0;
        final drift = math.sin(progress * math.pi * 2) * 18;

        return Positioned(
          left:
              MediaQuery.sizeOf(context).width * widget.reaction.startX + drift,
          bottom: bottom,
          child: Opacity(
            opacity: opacity.clamp(0, 1),
            child: Text(
              widget.reaction.emoji,
              style: const TextStyle(fontSize: 34),
            ),
          ),
        );
      },
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

class _CallChatMessage {
  final String id;
  final String senderIdentity;
  final String senderName;
  final String text;
  final DateTime? timestamp;
  final bool isMine;

  const _CallChatMessage({
    required this.id,
    required this.senderIdentity,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isMine,
  });
}

class _FloatingReaction {
  final String id;
  final String emoji;
  final double startX;

  const _FloatingReaction({
    required this.id,
    required this.emoji,
    required this.startX,
  });
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

String? _avatarFromMetadata(String? metadata) {
  if (metadata == null || metadata.isEmpty) return null;
  try {
    final decoded = jsonDecode(metadata);
    if (decoded is Map<String, dynamic>) {
      final value = decoded['avatar']?.toString();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
  } catch (_) {}
  return null;
}
