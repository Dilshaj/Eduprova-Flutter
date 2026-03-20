import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduprova/theme/theme_model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:eduprova/core/network/api_client.dart';
import 'package:eduprova/core/network/livekit_config.dart';
import 'package:livekit_client/livekit_client.dart';

class CoachSection extends ConsumerStatefulWidget {
  final AppDesignExtension themeExt;
  final VoidCallback onBack;
  final String? mode;
  final String? topic;

  const CoachSection({
    super.key,
    required this.themeExt,
    required this.onBack,
    this.mode,
    this.topic,
  });

  @override
  ConsumerState<CoachSection> createState() => _CoachSectionState();
}

class _CoachSectionState extends ConsumerState<CoachSection> {
  final ScrollController _chatScrollController = ScrollController();

  Room? _room;
  EventsListener<RoomEvent>? _listener;
  String? _token;

  bool _isConnecting = true;
  bool _isMuted = false;
  bool _isListening = false;
  String _agentState = 'loading';
  String _lastWords = '';

  int _fluencyScore = 0;
  int _grammarScore = 0;

  final Map<String, Map<String, dynamic>> _messagesById = {};

  List<Map<String, dynamic>> get _messages {
    final list = _messagesById.values.toList();
    list.sort((a, b) => (a['rawTime'] as int).compareTo(b['rawTime'] as int));
    return list;
  }

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    if (!mounted) return;
    setState(() => _isConnecting = true);

    try {
      final String participantName =
          'User-${DateTime.now().millisecondsSinceEpoch}';
      final String roomName = 'coach-${DateTime.now().millisecondsSinceEpoch}';
      final String metadata = jsonEncode({
        'mode': widget.mode ?? 'free_talk',
        'topic': widget.topic ?? '',
      });

      final response = await ApiClient.instance.post(
        '/interview/livekit-token-coach',
        data: {
          'participantName': participantName,
          'roomName': roomName,
          'metadata': metadata,
        },
      );

      if (response.data['token'] != null) {
        _token = response.data['token'];
        _room = Room();
        _listener = _room!.createListener();
        _setupListeners();

        final String livekitUrl = LiveKitConfig.serverUrl;
        await _room!.connect(livekitUrl, _token!);

        // Auto-enable mic on connect
        await _room!.localParticipant?.setMicrophoneEnabled(true);

        if (mounted) {
          setState(() {
            _isConnecting = false;
            _isListening = true;
            _agentState = 'active';
          });
        }
      }
    } catch (e) {
      debugPrint('[LiveKit Coach] Connection error: $e');
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _agentState = 'error';
          final errorMsgId = 'err_${DateTime.now().millisecondsSinceEpoch}';
          _messagesById[errorMsgId] = {
            'id': errorMsgId,
            'isUser': false,
            'text': "Failed to connect: $e",
            'time': 'Just now',
            'type': 'coach',
            'rawTime': DateTime.now().millisecondsSinceEpoch,
          };
        });
      }
    }
  }

  void _setupListeners() {
    if (_listener == null) return;
    _listener!
      ..on<RoomDisconnectedEvent>((event) {
        if (mounted) {
          setState(() {
            _agentState = 'disconnected';
            _isListening = false;
          });
        }
      })
      ..on<TranscriptionEvent>((event) {
        _handleTranscription(event);
      })
      ..on<ParticipantMetadataUpdatedEvent>((event) {
        if (event.participant is RemoteParticipant) {
          _parseAgentMetadata(event.participant.metadata);
        }
      })
      ..on<DataReceivedEvent>((event) {
        _handleDataReceived(event);
      })
      ..on<ParticipantConnectedEvent>((event) {
        debugPrint(
          '[LiveKit] Participant connected: ${event.participant.identity}',
        );
      });
  }

  void _parseAgentMetadata(String? metadata) {
    if (metadata == null) return;
    try {
      final data = jsonDecode(metadata);
      if (mounted) {
        setState(() {
          if (data['agent_state'] != null) _agentState = data['agent_state'];
          if (data['fluency'] != null) _fluencyScore = data['fluency'];
          if (data['grammar'] != null) _grammarScore = data['grammar'];
        });
      }
    } catch (_) {}
  }

  void _handleDataReceived(DataReceivedEvent event) {
    try {
      final raw = utf8.decode(event.data);
      final decoded = jsonDecode(raw);
      if (decoded['type'] == 'analysis' && decoded['id'] != null) {
        final id = decoded['id'];
        if (_messagesById.containsKey(id)) {
          setState(() {
            _messagesById[id]!['alternatives'] = decoded['alternatives'];
            _messagesById[id]!['alerts'] = decoded['alerts'];
          });
        }
      }
    } catch (_) {}
  }

  void _handleTranscription(TranscriptionEvent event) {
    if (event.segments.isEmpty) return;
    final isUser = event.participant is LocalParticipant;

    if (mounted) {
      setState(() {
        for (final segment in event.segments) {
          if (segment.text.trim().isEmpty && !segment.isFinal) {
            continue;
          }
          if (isUser && !segment.isFinal) {
            _lastWords = segment.text;
          } else if (isUser && segment.isFinal) {
            _lastWords = ''; // clear on final
          }

          _messagesById[segment.id] = {
            'id': segment.id,
            'isUser': isUser,
            'text': segment.text,
            'type': isUser ? 'user' : 'coach',
            'time': 'Just now',
            'rawTime': segment.firstReceivedTime.millisecondsSinceEpoch,
            'alternatives': _messagesById[segment.id]?['alternatives'],
            'alerts': _messagesById[segment.id]?['alerts'],
          };
        }
      });
      _scrollToBottom();
    }
  }

  Future<void> _disconnect() async {
    try {
      await _room?.disconnect();
    } catch (_) {}
    _listener?.dispose();
    _room = null;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _toggleListening() async {
    if (_room?.localParticipant == null) return;
    setState(() {
      _isMuted = !_isMuted;
      _isListening = !_isMuted;
    });
    try {
      await _room!.localParticipant!.setMicrophoneEnabled(!_isMuted);
    } catch (e) {
      debugPrint('[LiveKit Coach] Microphone toggle error: $e');
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    if (_room?.localParticipant == null) return;

    final payload = {
      'type': 'chat',
      'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
      'text': text,
    };

    try {
      _room!.localParticipant!.publishData(
        utf8.encode(jsonEncode(payload)),
        reliable: true,
        topic: 'chat',
      );
    } catch (_) {}

    setState(() {
      _lastWords = '';
      _messagesById[payload['id']!] = {
        'id': payload['id'],
        'isUser': true,
        'text': text,
        'type': 'user',
        'time': 'Just now',
        'rawTime': DateTime.now().millisecondsSinceEpoch,
        'alternatives': null,
        'alerts': null,
      };
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _disconnect();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Skeletonizer(
      enabled: _isConnecting,
      child: Column(
        children: [
          _buildTopCompactHeader(colorScheme),
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatMessage(msg, colorScheme);
              },
            ),
          ),
          _buildChatInput(colorScheme),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildTopCompactHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        boxShadow: [
          BoxShadow(
            color: widget.themeExt.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=300',
                        ),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0066FF).withValues(alpha: 0.2),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI COACH',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isConnecting
                                ? 'Connecting...'
                                : 'Live Intelligence Active',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF166534),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    _toggleListening();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isMuted
                          ? const Color(0xFFFEF2F2)
                          : const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isMuted
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFE0E7FF),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isMuted ? Icons.mic_off : Icons.mic_none,
                          size: 16,
                          color: _isMuted
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF0066FF),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isMuted ? 'UNMUTE' : 'MUTE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _isMuted
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF0066FF),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMetricBadge(
                'FLUENCY',
                '$_fluencyScore%',
                const Color(0xFF0066FF),
                Icons.insights,
              ),
              const SizedBox(width: 12),
              _buildMetricBadge(
                'GRAMMAR',
                '$_grammarScore/100',
                const Color(0xFF059669),
                Icons.spellcheck,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBadge(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: widget.themeExt.secondaryText,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> msg, ColorScheme colorScheme) {
    final bool isUser = msg['isUser'] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0066FF), Color(0xFFC026D3)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: isUser
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF0066FF), Color(0xFF6366F1)],
                              )
                            : null,
                        color: isUser ? null : widget.themeExt.cardColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(24),
                          topRight: const Radius.circular(24),
                          bottomLeft: Radius.circular(isUser ? 24 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isUser
                                ? const Color(
                                    0xFF0066FF,
                                  ).withValues(alpha: 0.05)
                                : widget.themeExt.shadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        msg['text'],
                        style: TextStyle(
                          fontSize: 16,
                          color: isUser
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          height: 1.5,
                          fontWeight: isUser
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (msg['label'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified,
                              size: 12,
                              color: Color(0xFF22C55E),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              msg['label'],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF059669),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (isUser)
                const SizedBox(
                  width: 48,
                ), // Padding on the left for user messages
            ],
          ),
          if (msg['alternatives'] != null)
            ...List.generate(
              msg['alternatives'].length,
              (i) => _buildSubBubble(
                msg['alternatives'][i],
                const Color(0xFFE11D48),
                'BETTER ALTERNATIVE',
                Icons.auto_fix_high,
              ),
            ),
          if (msg['alerts'] != null)
            ...List.generate(
              msg['alerts'].length,
              (i) => _buildSubBubble(
                msg['alerts'][i],
                const Color(0xFFF59E0B),
                'PACING ALERT',
                Icons.speed,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubBubble(
    String text,
    Color color,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, top: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: color.withValues(alpha: 0.9),
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: widget.themeExt.cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _isMuted
                  ? 'Microphone muted'
                  : (_isListening
                        ? (_lastWords.isEmpty ? 'Listening...' : _lastWords)
                        : (_lastWords.isNotEmpty
                              ? _lastWords
                              : 'Tap mic to dictate...')),
              style: TextStyle(
                color: _isMuted
                    ? const Color(0xFFEF4444)
                    : widget.themeExt.secondaryText,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                _toggleListening();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isMuted
                        ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                        : (_isListening
                              ? [
                                  const Color(0xFF10B981),
                                  const Color(0xFF059669),
                                ]
                              : [
                                  const Color(0xFF0066FF),
                                  const Color(0xFF7C3AED),
                                ]),
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isMuted
                                  ? const Color(0xFFEF4444)
                                  : (_isListening
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF0066FF)))
                              .withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _isMuted
                      ? Icons.mic_off_rounded
                      : (_isListening ? Icons.stop_rounded : Icons.mic_rounded),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          if (_lastWords.isNotEmpty && !_isListening) ...[
            const SizedBox(width: 8),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  final text = _lastWords;
                  setState(() {
                    _lastWords = '';
                  });
                  _sendMessage(text);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
