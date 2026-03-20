import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../core/network/livekit_config.dart';
import '../core/repositories/interview_repository.dart';
import 'ai_theme.dart';

class LiveAgentPage extends StatefulWidget {
  final String sessionId;
  final String role;

  const LiveAgentPage({super.key, required this.sessionId, required this.role});

  @override
  State<LiveAgentPage> createState() => _LiveAgentPageState();
}

class _ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime time;

  _ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class _LiveAgentPageState extends State<LiveAgentPage>
    with TickerProviderStateMixin {
  Timer? _durTimer;
  int _elapsedSeconds = 0;
  bool _isMuted = false;

  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  Room? _room;
  void Function()? _cancelListen;
  double _agentAudioLevel = 0.0;
  bool _isConnected = false;

  final ScrollController _scrollController = ScrollController();
  final Map<String, _ChatMessage> _messages = {};

  List<_ChatMessage> get _sortedMessages {
    final list = _messages.values.toList();
    list.sort((a, b) => a.time.compareTo(b.time));
    return list;
  }

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnim = Tween(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _durTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _elapsedSeconds++);
    });

    _connectToLiveKit();
  }

  Future<void> _connectToLiveKit() async {
    try {
      final repo = InterviewRepository();

      final participantName =
          'Candidate-${DateTime.now().millisecondsSinceEpoch}';
      final token = await repo.getLivekitToken(
        participantName: participantName,
        roomName: widget.sessionId,
      );

      final room = Room(
        roomOptions: const RoomOptions(
          defaultAudioOutputOptions: AudioOutputOptions(speakerOn: true),
        ),
      );
      _room = room;

      _cancelListen = room.events.listen((event) {
        if (event is ActiveSpeakersChangedEvent) {
          if (mounted) {
            setState(() {
              _agentAudioLevel = event.speakers.isNotEmpty ? 1.0 : 0.0;
            });
          }
        } else if (event is TranscriptionEvent) {
          if (mounted) {
            setState(() {
              final isUser = event.participant is LocalParticipant;
              for (final segment in event.segments) {
                if (segment.text.trim().isEmpty && !segment.isFinal) {
                  continue;
                }
                _messages[segment.id] = _ChatMessage(
                  id: segment.id,
                  text: segment.text,
                  isUser: isUser,
                  time: segment.firstReceivedTime,
                );
              }
            });

            Future.delayed(const Duration(milliseconds: 100), () {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        }
      });

      await room.connect(LiveKitConfig.serverUrl, token);

      // Route audio to speakerphone
      // await Hardware.instance.setSpeakerphoneOn(true);

      // Enable microphone to start recording and sending audio
      await room.localParticipant?.setMicrophoneEnabled(true);
      await Hardware.instance.setSpeakerphoneOn(true);
      await Hardware.instance.setSpeakerphoneOn(true);

      if (mounted) {
        setState(() {
          _isConnected = true;
        });
      }
    } catch (e) {
      debugPrint('LiveKit Connection Error: $e');
      if (mounted) {
        // Handle connection error if needed
      }
    }
  }

  void _toggleMute() async {
    if (_room == null) return;
    final localParticipant = _room!.localParticipant;
    final enabled = !_isMuted;

    for (var pub in localParticipant?.audioTrackPublications ?? []) {
      if (enabled) {
        await pub.track?.mute();
      } else {
        await pub.track?.unmute();
      }
    }

    setState(() => _isMuted = enabled);
  }

  @override
  void dispose() {
    _durTimer?.cancel();
    _waveController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    _cancelListen?.call();
    _room?.disconnect();
    _room?.dispose();
    super.dispose();
  }

  String get _formattedDuration {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AiTheme.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const double maxWidth = 480;
            double hPad = 0;
            if (constraints.maxWidth > maxWidth) {
              hPad = (constraints.maxWidth - maxWidth) / 2;
            }
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: t.cardBg,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: t.cardBorder),
                          boxShadow: t.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 18,
                                right: 18,
                              ),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: _buildLiveBadge(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              flex: 5,
                              child: Center(child: _buildAvatarArea()),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(child: _buildWaveform()),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: _buildChatHistory(),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildActions(context),
                  const SizedBox(height: 28),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final t = AiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.arrow_back, color: t.iconBack, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.role,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: t.textPrimary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Duration',
                style: TextStyle(
                  fontSize: 10,
                  color: t.textMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formattedDuration,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: t.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarArea() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return Transform.scale(
          scale: _pulseAnim.value,
          child: SizedBox(
            width: 185,
            height: 185,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 185,
                  height: 185,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7C3AED).withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 155,
                  height: 155,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6D28D9).withValues(alpha: 0.28),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                ),
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1040), Color(0xFF0A0820)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.6),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.45),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/ai-bot.png',
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, st) => const Icon(
                        Icons.face_3_rounded,
                        color: Colors.white60,
                        size: 56,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(16, (i) {
            final tValue = _waveController.value * 2 * pi;
            final scale = _isConnected ? (0.2 + _agentAudioLevel * 0.8) : 0.2;
            final height =
                (6.0 + 22.0 * (0.5 + 0.5 * sin(tValue + i * pi / 3.5))) * scale;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 4,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFFE056FD)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildChatHistory() {
    final t = AiTheme.of(context);
    final messages = _sortedMessages;

    if (messages.isEmpty) {
      return Center(
        child: Text(
          _isConnected ? "Listening for audio..." : "Connecting to agent...",
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: t.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return Align(
          alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: msg.isUser
                  ? const Color(0xFF3B82F6).withValues(alpha: 0.1) // blue-500
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: msg.isUser
                    ? const Radius.circular(16)
                    : Radius.zero,
                bottomRight: msg.isUser
                    ? Radius.zero
                    : const Radius.circular(16),
              ),
              border: Border.all(
                color: msg.isUser
                    ? const Color(0xFF60A5FA).withValues(alpha: 0.2) // blue-400
                    : Colors.white.withValues(alpha: 0.05),
              ),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment: msg.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  '"${msg.text}"',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: msg.isUser
                        ? const Color(0xFFDBEAFE).withValues(
                            alpha: 0.9,
                          ) // blue-100
                        : t.textSecondary,
                  ),
                  textAlign: msg.isUser ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.isUser ? 'CANDIDATE' : 'SAGE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: msg.isUser
                            ? const Color(0xFF93C5FD).withValues(
                                alpha: 0.5,
                              ) // blue-300
                            : Colors.white30,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '• LIVE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: t.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _toggleMute,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E1E28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            _durTimer?.cancel();
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 17),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.phone_disabled_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 10),
                Text(
                  'END SESSION',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
