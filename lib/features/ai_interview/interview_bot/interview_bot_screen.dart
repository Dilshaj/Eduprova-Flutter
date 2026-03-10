import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:eduprova/globals.dart';
import 'package:eduprova/core/network/api_client.dart';
import 'package:eduprova/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../core/services/deepgram_stt_service.dart';
import '../widgets/ai_theme.dart';
import '../core/models/interview_session_model.dart';
import 'widgets/interview_header.dart';
import 'widgets/question_progress_bar.dart';
import 'widgets/ai_avatar_widget.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/interview_input_area.dart';

class InterviewBotPage extends StatefulWidget {
  final String sessionId;
  final List<InterviewQuestion> questions;
  final String role;
  final String duration;
  final String voice;

  const InterviewBotPage({
    super.key,
    required this.sessionId,
    required this.questions,
    required this.role,
    required this.duration,
    required this.voice,
  });

  @override
  State<InterviewBotPage> createState() => _InterviewBotPageState();
}

class _InterviewBotPageState extends State<InterviewBotPage> {
  bool _isLoading = true;
  bool _isEndingSession = false;

  // Timer — driven by server SESSION_TIMER event
  Timer? _timer;
  int _secondsRemaining = 0;
  final int _currentQuestionIndex = 0;

  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  final AudioPlayer _audioPlayer = AudioPlayer();
  late io.Socket _socket;
  final DeepgramSttService _deepgramService = DeepgramSttService();

  bool _isListening = false;
  double _speechLevel = 0.0;

  // Staging buffer: raw base64 chunks accumulate here until AI_AUDIO_SEGMENT_DONE
  final List<String> _incomingChunks = [];
  // Queue of ready-to-play temp file paths (one per sentence/segment)
  final List<String> _audioQueue = [];
  bool _isPlaying = false;

  // Whether we should enable microphone once audio queue drains
  bool _shouldEnableMicrophone = false;

  // Whether AI has finished transmitting ALL audio (AUDIO_DONE received)
  bool _audioTransmissionDone = false;

  bool _isAiSpeaking = true;
  bool _ignoreIncomingAi = false;

  @override
  void initState() {
    super.initState();
    // Initialize timer from widget params as a fallback; server SESSION_TIMER will override
    _secondsRemaining = (widget.duration == '45M') ? 45 * 60 : 30 * 60;

    _initSocket();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isLoading = false);
      _initSpeech();
    });
  }

  void _initSocket() {
    _socket = io.io(
      ApiClient.baseUrl,
      io.OptionBuilder().setTransports(['websocket']).setAuth({
        'token': prefs.getString('access_token'),
      }).build(),
    );

    _socket.onConnect((_) {
      debugPrint('Connected to Interview Socket');
      _socket.emit('START_SESSION', {'sessionId': widget.sessionId});
    });

    // ── Server-side timer sync ───────────────────────────────────────────────
    _socket.on('SESSION_TIMER', (data) {
      final endTime = data['endTime'] as int;
      final remaining =
          ((endTime - DateTime.now().millisecondsSinceEpoch) / 1000)
              .ceil()
              .clamp(0, 60 * 60);
      if (mounted) {
        setState(() => _secondsRemaining = remaining);
        _timer?.cancel();
        _startTimer();
      }
    });

    // ── Text chunks ──────────────────────────────────────────────────────────
    _socket.on('AI_TEXT_CHUNK', (data) {
      if (_ignoreIncomingAi) return;
      final text = data['text'] as String;
      final isFirst = data['isFirst'] as bool;

      if (mounted) {
        setState(() {
          if (isFirst ||
              _messages.isEmpty ||
              !(_messages.last['isAI'] as bool)) {
            _messages.add({
              'sender': 'AI INTERVIEWER',
              'text': text,
              'isAI': true,
            });
          } else {
            _messages.last['text'] = (_messages.last['text'] as String) + text;
          }
        });
        _scrollToBottom();
      }
    });

    // ── Audio chunk accumulation ─────────────────────────────────────────────
    _socket.on('AI_AUDIO_CHUNK', (data) {
      if (_ignoreIncomingAi) return;
      if (mounted) setState(() => _isAiSpeaking = true);
      _incomingChunks.add(data['audio'] as String);
    });

    // Fired when the backend finishes one sentence/segment of TTS
    _socket.on('AI_AUDIO_SEGMENT_DONE', (_) async {
      if (_ignoreIncomingAi || _incomingChunks.isEmpty) return;

      // Concatenate all raw bytes of this segment into one MP3 file
      final allBytes = _incomingChunks
          .map(base64.decode)
          .expand((b) => b)
          .toList();
      _incomingChunks.clear();

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/seg_${DateTime.now().millisecondsSinceEpoch}.mp3',
      );
      await file.writeAsBytes(allBytes);

      _audioQueue.add(file.path);
      if (!_isPlaying) {
        _playNextInQueue();
      }
    });

    // ── All audio transmitted — now we can safely arm the mic enable ─────────
    // AUDIO_DONE arrives after all AI_AUDIO_SEGMENT_DONE events.
    // We only enable the microphone AFTER this AND after the queue drains.
    _socket.on('AUDIO_DONE', (_) {
      debugPrint('AUDIO_DONE received');
      _audioTransmissionDone = true;
      // If nothing is playing right now (all segments already played) AND
      // ENABLE_MICROPHONE was already received, start listening.
      if (!_isPlaying && _shouldEnableMicrophone) {
        _enableMicrophoneNow();
      }
    });

    // ── Enable mic — defer until AUDIO_DONE + queue empty ──────────────────-
    _socket.on('ENABLE_MICROPHONE', (_) {
      debugPrint(
        'ENABLE_MICROPHONE received (isPlaying=$_isPlaying, audioDone=$_audioTransmissionDone)',
      );
      if (mounted) {
        _shouldEnableMicrophone = true;
        // Only start if audio is truly done (both transmitted & played)
        if (!_isPlaying && _audioTransmissionDone) {
          _enableMicrophoneNow();
        }
      }
    });

    // ── Session complete — navigate to feedback ──────────────────────────────
    _socket.on('SESSION_COMPLETE', (_) {
      debugPrint('SESSION_COMPLETE received');
      if (mounted) _endSession();
    });

    _socket.on('SESSION_TIMEOUT', (_) {
      if (mounted) setState(() => _secondsRemaining = 0);
    });

    _socket.on('ERROR', (data) {
      debugPrint('Socket Error: ${data['message']}');
    });

    _socket.onDisconnect((_) => debugPrint('Disconnected from Socket'));
  }

  /// Called only when both AUDIO_DONE was received AND the audio queue is empty.
  void _enableMicrophoneNow() {
    // Small delay to let ExoPlayer/AVPlayer fully release audio focus
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_isPlaying && _audioQueue.isEmpty) {
        // Only reset trigger flags when we actually start listening
        _shouldEnableMicrophone = false;
        _audioTransmissionDone = false;
        setState(() => _isAiSpeaking = false);
        _startListening();
      }
    });
  }

  Future<void> _playNextInQueue() async {
    if (_audioQueue.isEmpty) {
      if (mounted) setState(() => _isPlaying = false);
      // Only enable mic if BOTH conditions are met:
      // 1. ENABLE_MICROPHONE was received
      // 2. AUDIO_DONE was received (all segments transmitted)
      if (_shouldEnableMicrophone && _audioTransmissionDone) {
        _enableMicrophoneNow();
      }
      return;
    }

    if (mounted) {
      setState(() => _isPlaying = true);
      // Stop microphone so AI doesn't hear itself
      if (_isListening) await _stopListening();
    }

    final filePath = _audioQueue.removeAt(0);

    try {
      await _audioPlayer.setFilePath(filePath);
      await _audioPlayer.play();
      // Wait for natural playback completion with a timeout as safety
      await _audioPlayer.playerStateStream
          .firstWhere((s) => s.processingState == ProcessingState.completed)
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      debugPrint('Error playing audio segment: $e');
    } finally {
      if (mounted) setState(() => _isPlaying = false);
    }

    // Delete temp file
    try {
      File(filePath).deleteSync();
    } catch (_) {}

    _playNextInQueue();
  }

  Future<void> _initSpeech() async {
    // Deepgram initialization happens internally when starting
  }

  void _startListening({bool userInitiated = false}) async {
    if (userInitiated) {
      _ignoreIncomingAi = true;
      _incomingChunks.clear();
      _audioQueue.clear();
      await _audioPlayer.stop();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isAiSpeaking = false;
        });
      }
    }

    _shouldEnableMicrophone = false;

    if (mounted) {
      setState(() {
        _isListening = true;
        _speechLevel = 10.0;
      });
    }

    try {
      _chatController.clear();

      await _deepgramService.start(
        onTranscript: (text) {
          if (mounted) {
            setState(() {
              _chatController.text = text;
              // Fake varying speech level based on text length to animate UI
              _speechLevel = text.isNotEmpty
                  ? 10.0 + (text.length % 5) * 5.0
                  : 0.0;
            });
          }
        },
        onError: (error) {
          debugPrint('Deepgram error: $error');
          if (mounted) {
            setState(() {
              _isListening = false;
              _speechLevel = 0.0;
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Recording error: $error')));
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isListening = false;
              _speechLevel = 0.0;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Error starting Deepgram STT: $e');
      if (mounted) {
        setState(() {
          _isListening = false;
          _speechLevel = 0.0;
        });
      }
    }
  }

  Future<void> _stopListening() async {
    await _deepgramService.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
        _speechLevel = 0.0;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _endSession();
        }
      });
    });
  }

  void _sendMessage() {
    _ignoreIncomingAi = false;
    _stopListening();
    if (_chatController.text.trim().isEmpty) return;
    final text = _chatController.text.trim();
    _chatController.clear();

    if (mounted) {
      setState(() {
        _messages.add({'sender': 'CANDIDATE', 'text': text, 'isAI': false});
        _isAiSpeaking = true;
        _audioTransmissionDone = false;
      });
    }

    _scrollToBottom();
    _socket.emit('USER_SPEECH_END', {
      'sessionId': widget.sessionId,
      'transcript': text,
    });
  }

  void _scrollToBottom() {
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

  Future<void> _endSession() async {
    _timer?.cancel();
    await _stopListening();
    await _audioPlayer.stop();

    if (_isEndingSession) return;
    if (mounted) setState(() => _isEndingSession = true);

    if (mounted) {
      context.push(AppRoutes.interviewFeedback(widget.sessionId));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _socket.dispose();
    _deepgramService.stop();
    _timer?.cancel();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} Left';
  }

  String get _interviewerName =>
      widget.voice == 'MALE' ? 'Alex Interviewer' : 'Sarah Interviewer';
  IconData get _interviewerIcon =>
      widget.voice == 'MALE' ? Icons.face : Icons.face_3;

  @override
  Widget build(BuildContext context) {
    final t = AiTheme.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBg,
      appBar: AppBar(
        backgroundColor: t.scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 80,
        toolbarHeight: 50,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Row(
            mainAxisAlignment: .center,
            children: [
              const SizedBox(width: 8),
              Icon(Icons.arrow_back, color: t.iconBack, size: 18),
              const SizedBox(width: 4),
              Text(
                'Back',
                style: TextStyle(
                  color: t.iconBack,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Skeletonizer(
        enabled: _isLoading,
        effect: ShimmerEffect(
          baseColor: t.shimmerBase,
          highlightColor: t.shimmerHighlight,
          duration: const Duration(seconds: 1),
        ),
        child: SafeArea(
          child: Column(
            children: [
              InterviewHeader(
                interviewerName: _interviewerName,
                interviewerIcon: _interviewerIcon,
                role: widget.role,
                formattedTime: _formattedTime,
                isEndingSession: _isEndingSession,
                onEndSession: _endSession,
                isMale: widget.voice == 'MALE',
              ),
              QuestionProgressBar(
                currentQuestionIndex: _currentQuestionIndex,
                totalQuestions: widget.questions.length,
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 4,
                child: AiAvatarWidget(isMale: widget.voice == 'MALE'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.format_align_left,
                          color: t.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'LIVE TRANSCRIPT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: .circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4CAF50),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 5,
                child: ChatMessageList(
                  messages: _messages,
                  scrollController: _scrollController,
                  isListening: _isListening,
                  speechLevel: _speechLevel,
                ),
              ),
              InterviewInputArea(
                isListening: _isListening,
                isAiSpeaking: _isAiSpeaking,
                transcript: _chatController.text,
                onSendMessage: _sendMessage,
                onStartListening: () => _startListening(userInitiated: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
