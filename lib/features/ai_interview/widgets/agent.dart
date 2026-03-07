import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import '../repositories/interview_repository.dart';
import 'ai_theme.dart';

class LiveAgentPage extends StatefulWidget {
  final String sessionId;
  final String role;

  const LiveAgentPage({super.key, required this.sessionId, required this.role});

  @override
  State<LiveAgentPage> createState() => _LiveAgentPageState();
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
  String _currentQuestion = "Connecting to agent...";
  bool _isConnected = false;

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
      final token = await repo.getSessionLivekitToken(widget.sessionId);

      final room = Room();
      _room = room;

      _cancelListen = room.events.listen((event) {
        if (event is ActiveSpeakersChangedEvent) {
          if (mounted) {
            setState(() {
              _agentAudioLevel = event.speakers.isNotEmpty ? 1.0 : 0.0;
            });
          }
        }
      });

      await room.connect('ws://192.168.1.116:7800', token);

      if (mounted) {
        setState(() {
          _isConnected = true;
          _currentQuestion =
              "Hello! I'm your Live Agent. How can I help you today?";
        });
      }
    } catch (e) {
      debugPrint('LiveKit Connection Error: $e');
      if (mounted) {
        setState(
          () => _currentQuestion = "Connection failed. Please try again.",
        );
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
                                  horizontal: 28,
                                ),
                                child: Center(child: _buildQuestion()),
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

  Widget _buildQuestion() {
    final t = AiTheme.of(context);
    return Text(
      '"$_currentQuestion"',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        height: 1.65,
        fontStyle: FontStyle.italic,
        color: t.textSecondary,
        fontWeight: FontWeight.w500,
      ),
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
