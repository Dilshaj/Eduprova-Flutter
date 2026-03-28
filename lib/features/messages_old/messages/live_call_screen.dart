import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_background/flutter_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' show Helper;
import 'package:google_fonts/google_fonts.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/call_room_model.dart';
import '../models/search_user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:eduprova/core/navigation/app_routes.dart';
import '../providers/chat_socket_provider.dart';
import '../repository/calling_repository.dart';

// ─── Live Call Screen ────────────────────────────────────────────────────────

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
  bool _isScreenShareEnabled = false;
  String? _error;
  String? _focusedParticipantIdentity;
  List<Participant> _participants = const [];
  List<_CallChatMessage> _chatMessages = const [];
  List<_FloatingReaction> _floatingReactions = const [];
  Map<String, bool> _raisedHands = const {};

  // Timer
  late final Stopwatch _callTimer = Stopwatch()..start();
  late final Timer _timerTick;

  @override
  void initState() {
    super.initState();
    _isMicEnabled = widget.initialAudio;
    _isCameraEnabled = widget.initialVideo;
    _timerTick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _connect();
  }

  @override
  void dispose() {
    _timerTick.cancel();
    _chatController.dispose();
    _chatScrollController.dispose();
    _eventsListener?.dispose();
    _room?.unregisterTextStreamHandler('chat');
    _room?.removeListener(_refreshParticipants);
    unawaited(_room?.disconnect());
    unawaited(_room?.dispose());
    super.dispose();
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
      if (emoji.isNotEmpty) _showReaction(emoji, senderIdentity);
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
      (p) => p?.identity == participantIdentity,
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
    if (_chatMessages.any((m) => m.id == id)) return;
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
    if (local != null) items.add(local);
    items.addAll(room.remoteParticipants.values);
    items.sort((a, b) {
      if (a.isSpeaking == b.isSpeaking) return a.identity.compareTo(b.identity);
      return a.isSpeaking ? -1 : 1;
    });
    _participants = items;
    final identities = items.map((i) => i.identity).toSet();
    if (_focusedParticipantIdentity == null ||
        !identities.contains(_focusedParticipantIdentity)) {
      _focusedParticipantIdentity = items.isNotEmpty
          ? items.first.identity
          : null;
    }
    final activeSpeaker = items
        .where((i) => i.isSpeaking)
        .cast<Participant?>()
        .firstWhere((_) => true, orElse: () => null);
    if (activeSpeaker != null &&
        _focusedParticipantIdentity != activeSpeaker.identity) {
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
        final ok = await Helper.requestCapturePermission();
        if (!ok) return;
        await _enableAndroidBackgroundScreenShare();
      }
      await _room?.localParticipant?.setScreenShareEnabled(next);
      if (!mounted) return;
      setState(() => _isScreenShareEnabled = next);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share screen: $e')));
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
    final local = _room?.localParticipant;
    if (text.isEmpty || local == null) return;
    final info = await local.sendText(
      text,
      options: SendTextOptions(topic: 'chat'),
    );
    final fallback = {
      'type': 'chat',
      'id': info.id,
      'identity': local.identity,
      'name': local.name,
      'text': text,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    unawaited(
      local.publishData(
        utf8.encode(jsonEncode(fallback)),
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
    final selected = await context.push<List<SearchUserModel>>(
      AppRoutes.meetInvite,
      extra: {
        'title': 'Add Participants',
        'submitLabel': 'Invite',
      },
    );
    if (!mounted || selected == null || selected.isEmpty) return;
    ref
        .read(chatSocketProvider.notifier)
        .emitCallInvite(
          recipientIds: selected.map((s) => s.id).toList(),
          roomName: roomName,
          conversationType: roomName.startsWith('grp:') ? 'group' : 'meet',
          callerName: local.name,
          callerAvatar: _avatarFromMetadata(local.metadata),
        );
    if (mounted)
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
            .where((r) => r.id != reaction.id)
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

  String get _timerLabel {
    final elapsed = _callTimer.elapsed;
    final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Participant? get _focusedParticipant {
    final identity = _focusedParticipantIdentity;
    if (identity == null)
      return _participants.isNotEmpty ? _participants.first : null;
    for (final p in _participants) {
      if (p.identity == identity) return p;
    }
    return _participants.isNotEmpty ? _participants.first : null;
  }

  List<Participant> get _otherParticipants {
    final focused = _focusedParticipant;
    if (focused == null) return _participants;
    return _participants.where((p) => p.identity != focused.identity).toList();
  }

  String _titleForRoom(String roomName) {
    if (roomName.startsWith('dm:')) return 'Direct Call';
    if (roomName.startsWith('grp:')) return 'Group Call';
    if (roomName.startsWith('meeting:')) return 'Scheduled Meeting';
    return 'Meeting';
  }

  // ─── More Options bottom sheet ─────────────────────────────────────────────
  void _showMoreOptions() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _MoreOptionsSheet(
        onEmojiSelected: (e) {
          Navigator.pop(ctx);
          _sendReaction(e);
        },
        onChat: () {
          Navigator.pop(ctx);
          _showChatSheet();
        },
        onPeople: () {
          Navigator.pop(ctx);
          _showPeopleSheet();
        },
        onShare: () {
          Navigator.pop(ctx);
          _toggleScreenShare();
        },
        onRaise: () {
          Navigator.pop(ctx);
          _toggleHandRaise();
        },
      ),
    );
  }

  void _showChatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, sc) => _ChatSheet(
          messages: _chatMessages,
          controller: _chatController,
          scrollController: sc,
          onSend: _sendChatMessage,
        ),
      ),
    );
  }

  void _showPeopleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, sc) => _PeopleSheet(
          participants: _participants,
          raisedHands: _raisedHands,
          scrollController: sc,
          onAddPeople: () {
            Navigator.pop(ctx);
            _inviteParticipants();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomNameValue = _roomData?.roomName ?? widget.roomName ?? 'Meeting';
    final focusedParticipant = _focusedParticipant;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final title = _titleForRoom(roomNameValue);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isConnecting
          ? Center(child: CircularProgressIndicator(color: cs.primary))
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
                      // ── Top bar ──────────────────────────────────────────
                      _TeamsTopBar(
                        title: title,
                        timer: _timerLabel,
                        participantCount: _participants.length,
                        onBack: _disconnect,
                        onChat: _showChatSheet,
                        onPeople: _showPeopleSheet,
                      ),
                      // ── Main video area ──────────────────────────────────
                      Expanded(
                        child: focusedParticipant == null
                            ? _InviteBody(
                                onAddParticipants: _inviteParticipants,
                              )
                            : _FocusedMeetingBody(
                                focused: focusedParticipant,
                                others: _otherParticipants,
                                raisedHands: _raisedHands,
                                onSelectParticipant: (p) => setState(
                                  () =>
                                      _focusedParticipantIdentity = p.identity,
                                ),
                              ),
                      ),
                      // ── Teams-style bottom bar ───────────────────────────
                      _TeamsBottomBar(
                        isMicOn: _isMicEnabled,
                        isCameraOn: _isCameraEnabled,
                        isSpeakerOn: _speakerOn,
                        onMic: _toggleMic,
                        onCamera: _toggleCamera,
                        onSpeaker: _toggleSpeaker,
                        onMore: _showMoreOptions,
                        onLeave: _disconnect,
                      ),
                    ],
                  ),
                  // ── Floating reactions ───────────────────────────────────
                  IgnorePointer(
                    child: _ReactionLayer(reactions: _floatingReactions),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─── Teams Top Bar ────────────────────────────────────────────────────────────

class _TeamsTopBar extends StatelessWidget {
  final String title;
  final String timer;
   final int participantCount;
  final VoidCallback onBack;
  final VoidCallback onChat;
  final VoidCallback onPeople;

  const _TeamsTopBar({
    required this.title,
    required this.timer,
    required this.participantCount,
    required this.onBack,
    required this.onChat,
    required this.onPeople,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(LucideIcons.chevronLeft, color: cs.onSurface, size: 22),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      timer,
                      style: GoogleFonts.inter(
                        color: cs.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      LucideIcons.shield,
                      color: cs.onSurface.withValues(alpha: 0.4),
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Chat badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onChat,
                icon: Icon(
                  LucideIcons.messageCircle,
                  color: cs.onSurface,
                  size: 22,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          // People
          IconButton(
            onPressed: onPeople,
            icon: Icon(LucideIcons.users, color: cs.onSurface, size: 22),
          ),
        ],
      ),
    );
  }
}

// ─── Teams Bottom Bar ─────────────────────────────────────────────────────────

class _TeamsBottomBar extends StatelessWidget {
  final bool isMicOn;
  final bool isCameraOn;
  final bool isSpeakerOn;
  final VoidCallback onMic;
  final VoidCallback onCamera;
  final VoidCallback onSpeaker;
  final VoidCallback onMore;
  final VoidCallback onLeave;

  const _TeamsBottomBar({
    required this.isMicOn,
    required this.isCameraOn,
    required this.isSpeakerOn,
    required this.onMic,
    required this.onCamera,
    required this.onSpeaker,
    required this.onMore,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TeamsBarIcon(
            icon: isCameraOn ? LucideIcons.video : LucideIcons.videoOff,
            active: isCameraOn,
            onTap: onCamera,
          ),
          _TeamsBarIcon(
            icon: isMicOn ? LucideIcons.mic : LucideIcons.micOff,
            active: isMicOn,
            onTap: onMic,
          ),
          _TeamsBarIcon(
            icon: isSpeakerOn ? LucideIcons.volume2 : LucideIcons.volumeX,
            active: isSpeakerOn,
            onTap: onSpeaker,
          ),
          _TeamsBarIcon(
            icon: LucideIcons.ellipsis,
            active: true,
            onTap: onMore,
            hasBadge: true,
          ),
          // Leave button
          GestureDetector(
            onTap: onLeave,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFC62828),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.phoneOff,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    LucideIcons.chevronUp,
                    color: Colors.white70,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamsBarIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final bool hasBadge;

  const _TeamsBarIcon({
    required this.icon,
    required this.active,
    required this.onTap,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: active
                  ? cs.onSurface
                  : cs.onSurface.withValues(alpha: 0.4),
              size: 24,
            ),
          ),
          if (hasBadge)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF6264A7),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Invite Body (when alone in meeting) ─────────────────────────────────────

class _InviteBody extends StatelessWidget {
  final VoidCallback onAddParticipants;

  const _InviteBody({required this.onAddParticipants});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9), // Light sage green
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'PV',
                style: GoogleFonts.inter(
                  color: const Color(0xFF2E7D32), // Dark green text
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Invite people to join you',
            style: GoogleFonts.inter(
              color: cs.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 250,
            child: ElevatedButton(
              onPressed: onAddParticipants,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF7B61FF,
                ), // Microsoft Teams purple
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: Text(
                'Add participants',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 250,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF7B61FF), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: const Color(0xFF7B61FF),
              ),
              child: Text(
                'Share meeting invite',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Focused Meeting Body ─────────────────────────────────────────────────────

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
          const SizedBox(height: 8),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: others.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final p = others[i];
                return SizedBox(
                  width: 138,
                  child: GestureDetector(
                    onTap: () => onSelectParticipant(p),
                    child: _ParticipantCard(
                      participant: p,
                      raisedHand: raisedHands[p.identity] ?? false,
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

// ─── Participant Card ─────────────────────────────────────────────────────────

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

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(large ? 16 : 14),
        border: Border.all(
          color: participant.isSpeaking
              ? cs.primary
              : cs.outlineVariant.withValues(alpha: 0.1),
          width: participant.isSpeaking ? 2.5 : 1,
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
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
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
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _initials(displayName),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E7D32),
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
                  '✋ Hand Raised',
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: large ? 14 : 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    audioOn ? LucideIcons.mic : LucideIcons.micOff,
                    color: audioOn ? cs.onSurface : cs.error,
                    size: large ? 18 : 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static VideoTrack? _firstVideoTrack(Participant p) {
    for (final pub in p.videoTrackPublications) {
      if (pub.track != null &&
          !pub.muted &&
          pub.source == TrackSource.screenShareVideo)
        return pub.track as VideoTrack?;
    }
    for (final pub in p.videoTrackPublications) {
      if (pub.track != null && !pub.muted && pub.source == TrackSource.camera)
        return pub.track as VideoTrack?;
    }
    for (final pub in p.videoTrackPublications) {
      if (pub.track != null && !pub.muted) return pub.track as VideoTrack?;
    }
    return null;
  }

  static bool _isAudioOn(Participant p) {
    for (final pub in p.audioTrackPublications) {
      if (pub.track != null && !pub.muted) return true;
    }
    return false;
  }

  static String _initials(String name) {
    final parts = name
        .split(' ')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static String? _avatarUrl(String? metadata) {
    if (metadata == null || metadata.isEmpty) return null;
    try {
      final decoded = jsonDecode(metadata);
      if (decoded is Map<String, dynamic>) return decoded['avatar']?.toString();
    } catch (_) {}
    return null;
  }
}

// ─── More Options Bottom Sheet ────────────────────────────────────────────────

class _MoreOptionsSheet extends StatelessWidget {
  final ValueChanged<String> onEmojiSelected;
  final VoidCallback onChat;
  final VoidCallback onPeople;
  final VoidCallback onShare;
  final VoidCallback onRaise;

  const _MoreOptionsSheet({
    required this.onEmojiSelected,
    required this.onChat,
    required this.onPeople,
    required this.onShare,
    required this.onRaise,
  });

  @override
  Widget build(BuildContext context) {
    const emojis = ['👍', '❤️', '👏', '😆', '😮', '✋'];
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: .fromLTRB(16, 12, 16, MediaQuery.paddingOf(context).bottom + 20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: .vertical(top: .circular(24)),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.1),
              borderRadius: .circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Emoji row
          Padding(
            padding: .symmetric(horizontal: 8),
            child: Row(
              children: [
                // Main reactions
                for (int i = 0; i < 5; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onEmojiSelected(emojis[i]),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 48,
                        alignment: .center,
                        child: Text(
                          emojis[i],
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                  ),
                // Divider
                Container(
                  width: 1,
                  height: 32,
                  margin: .symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                // Hand raise separated by divider
                GestureDetector(
                  onTap: onRaise,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: .center,
                    child: Text(
                      emojis[5],
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Action grid in teams card style
          Row(
            children: [
              _MoreOptionCard(
                icon: LucideIcons.messageSquare,
                label: 'Chat',
                onTap: onChat,
              ),
              _MoreOptionCard(
                icon: LucideIcons.users,
                label: 'People',
                onTap: onPeople,
              ),
              _MoreOptionCard(
                icon: LucideIcons.share,
                label: 'Share',
                onTap: onShare,
              ),
              _MoreOptionCard(
                icon: LucideIcons.layoutGrid,
                label: 'Views',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoreOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MoreOptionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Expanded(
      child: Padding(
        padding: .symmetric(horizontal: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: .circular(12),
          child: Container(
            padding: .symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: .circular(12),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: .min,
              children: [
                Icon(
                  icon,
                  color: cs.onSurface.withValues(alpha: 0.8),
                  size: 26,
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: cs.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ─── People / Participants Sheet ──────────────────────────────────────────────

class _PeopleSheet extends StatelessWidget {
  final List<Participant> participants;
  final Map<String, bool> raisedHands;
  final ScrollController scrollController;
  final VoidCallback onAddPeople;

  const _PeopleSheet({
    required this.participants,
    required this.raisedHands,
    required this.scrollController,
    required this.onAddPeople,
  });

  String _initials(String name) {
    final parts = name
        .split(' ')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: .vertical(top: .circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.1),
              borderRadius: .circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: .symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(LucideIcons.chevronLeft, color: cs.onSurface),
                ),
                Expanded(
                  child: Text(
                    'Meeting participants (${participants.length})',
                    style: GoogleFonts.inter(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(LucideIcons.share, color: cs.onSurface, size: 20),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: .zero,
              children: [
                _buildActionTile(
                  context,
                  icon: LucideIcons.userPlus,
                  label: 'Add people',
                  iconColor: const Color(0xFF6264A7),
                  bgColor: const Color(0xFFF0F0F8),
                  onTap: onAddPeople,
                ),
                _buildActionTile(
                  context,
                  icon: LucideIcons.settings,
                  label: 'Meeting options',
                  iconColor: const Color(0xFF5B5B5B),
                  bgColor: const Color(0xFFF2F2F2),
                  onTap: () {},
                ),
                Padding(
                  padding: .fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'IN THE MEETING (${participants.length})',
                    style: GoogleFonts.inter(
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                for (int i = 0; i < participants.length; i++)
                  _buildParticipantTile(context, participants[i], i == 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      contentPadding: .symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: bgColor, shape: .circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing:
          Icon(LucideIcons.chevronRight, color: cs.onSurface.withValues(alpha: 0.3), size: 18),
    );
  }

  Widget _buildParticipantTile(BuildContext context, Participant p, bool isOrganizer) {
    final cs = Theme.of(context).colorScheme;
    final name = p.name.isNotEmpty ? p.name : p.identity;
    final micOn = p.audioTrackPublications.any((pub) => pub.track != null && !pub.muted);
    final videoOn = p.videoTrackPublications.any((pub) => pub.track != null && !pub.muted);

    return Padding(
      padding: .symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: .all(8),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: .circular(16),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: p.isSpeaking
                        ? const Color(0xFFE8F5E9)
                        : cs.surfaceContainerHighest,
                    shape: .circle,
                  ),
                  child: Center(
                    child: Text(
                      _initials(name),
                      style: TextStyle(
                        color: p.isSpeaking
                            ? const Color(0xFF2E7D32)
                            : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: .circle,
                      border: Border.all(color: cs.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: GoogleFonts.inter(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: .ellipsis,
                        ),
                      ),
                      if (isOrganizer) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: .symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBEBFF),
                            borderRadius: .circular(4),
                          ),
                          child: const Text(
                            'ORGANIZER',
                            style: TextStyle(
                              color: Color(0xFF6264A7),
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    isOrganizer ? 'You' : 'Participant',
                    style: GoogleFonts.inter(
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              videoOn ? LucideIcons.video : LucideIcons.videoOff,
              color: videoOn ? cs.onSurface.withValues(alpha: 0.4) : const Color(0xFFC62828),
              size: 20,
            ),
            const SizedBox(width: 16),
            Icon(
              micOn ? LucideIcons.mic : LucideIcons.micOff,
              color: micOn ? const Color(0xFF7B61FF) : const Color(0xFFC62828),
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}


// ─── Chat Sheet ───────────────────────────────────────────────────────────────

class _ChatSheet extends StatefulWidget {
  final List<_CallChatMessage> messages;
  final TextEditingController controller;
  final ScrollController scrollController;
  final VoidCallback onSend;

  const _ChatSheet({
    required this.messages,
    required this.controller,
    required this.scrollController,
    required this.onSend,
  });

  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  void didUpdateWidget(_ChatSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollController.hasClients) {
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: .vertical(top: .circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.1),
              borderRadius: .circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: .symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(LucideIcons.chevronLeft, color: cs.onSurface),
                ),
                Text(
                  'In-call chat',
                  style: GoogleFonts.inter(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: widget.messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet',
                      style: GoogleFonts.inter(color: cs.onSurface.withValues(alpha: 0.4)),
                    ),
                  )
                : ListView.separated(
                    controller: widget.scrollController,
                    padding: .fromLTRB(16, 16, 16, 20),
                    itemCount: widget.messages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 24),
                    itemBuilder: (context, i) {
                      final msg = widget.messages[i];
                      final timeStr = _formatTime(msg.timestamp);
                      final displayName = msg.isMine ? 'You' : msg.senderName;

                      return Column(
                        crossAxisAlignment:
                            msg.isMine ? .end : .start,
                        children: [
                          Padding(
                            padding: .only(bottom: 6, left: msg.isMine ? 0 : 48),
                            child: Text(
                              '$displayName • $timeStr',
                              style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.45),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment:
                                msg.isMine ? .end : .start,
                            crossAxisAlignment: .start,
                            children: [
                              if (!msg.isMine) ...[
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade700,
                                    shape: .circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _initials(msg.senderName),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Flexible(
                                child: Container(
                                  padding: .symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: msg.isMine
                                        ? const Color(0xFF3B82F6)
                                        : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(!msg.isMine ? 0 : 18),
                                      topRight: Radius.circular(msg.isMine ? 0 : 18),
                                      bottomLeft: const Radius.circular(18),
                                      bottomRight: const Radius.circular(18),
                                    ),
                                  ),
                                  child: Text(
                                    msg.text,
                                    style: TextStyle(
                                      color: msg.isMine ? Colors.white : const Color(0xFF1F2937),
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 20,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              // Line removed for cleaner look as requested
            ),
            child: Container(
              padding: .symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: .circular(30),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      LucideIcons.plus,
                      color: cs.onSurface.withValues(alpha: 0.4),
                      size: 20,
                    ),
                    padding: .zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      decoration: const InputDecoration(
                        hintText: 'Send a message to everyone',
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        border: .none,
                        isDense: true,
                        contentPadding: .symmetric(vertical: 10),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      onSubmitted: (_) => widget.onSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onSend,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        shape: .circle,
                      ),
                      child: const Icon(LucideIcons.send, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// ─── Reaction Layer ───────────────────────────────────────────────────────────

class _ReactionLayer extends StatelessWidget {
  final List<_FloatingReaction> reactions;

  const _ReactionLayer({required this.reactions});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final r in reactions)
          _ReactionBubble(reaction: r, key: ValueKey(r.id)),
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

// ─── Error State ──────────────────────────────────────────────────────────────

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
            Text(
              'Unable to join call',
              style: GoogleFonts.inter(
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
            FilledButton(
              onPressed: onBack,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6264A7),
              ),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data Classes ─────────────────────────────────────────────────────────────

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

// ─── Helpers ──────────────────────────────────────────────────────────────────

String? _avatarFromMetadata(String? metadata) {
  if (metadata == null || metadata.isEmpty) return null;
  try {
    final decoded = jsonDecode(metadata);
    if (decoded is Map<String, dynamic>) {
      final value = decoded['avatar']?.toString();
      if (value != null && value.isNotEmpty) return value;
    }
  } catch (_) {}
  return null;
}
