import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduprova/theme/theme_model.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:eduprova/features/ai_grammar/widgets/live_session_overlay.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String senderName;
  final String avatarUrl;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.senderName,
    required this.avatarUrl,
  });
}

class ActiveRoleplaySession extends StatefulWidget {
  final String title;
  final String difficulty;
  final AppDesignExtension themeExt;
  final VoidCallback onBack;

  const ActiveRoleplaySession({
    super.key,
    required this.title,
    required this.difficulty,
    required this.themeExt,
    required this.onBack,
  });

  @override
  State<ActiveRoleplaySession> createState() => _ActiveRoleplaySessionState();
}

class _ActiveRoleplaySessionState extends State<ActiveRoleplaySession> {
  final List<ChatMessage> _messages = [
    const ChatMessage(
      text: "Welcome to your Senior Product Designer interview. Let's start with your design process. How do you handle ambiguity in the early stages of a product lifecycle?",
      isUser: false,
      senderName: "AI INTERVIEWER",
      avatarUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150",
    ),
    const ChatMessage(
      text: "I begin by conducting stakeholder interviews and user research to define the core problem space. I find that creating a shared understanding of the \"Why\" before moving into wireframing helps navigate any initial uncertainty.",
      isUser: true,
      senderName: "YOU",
      avatarUrl: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=150",
    ),
    const ChatMessage(
      text: "That's a solid approach. Can you describe a time you had a significant conflict with a developer regarding a design decision? How did you resolve it?",
      isUser: false,
      senderName: "AI INTERVIEWER",
      avatarUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150",
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speechToText.initialize();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
    } else {
      final available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        await _speechToText.listen(
          listenOptions: SpeechListenOptions(
            partialResults: true,
            listenMode: ListenMode.deviceDefault,
          ),
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
              // Move cursor to the end
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            });
            if (result.finalResult) {
              setState(() => _isListening = false);
            }
          },
        );
      }
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        senderName: "YOU",
        avatarUrl: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=150",
      ));
      _controller.clear();
    });
    _scrollToBottom();
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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: widget.themeExt.scaffoldBackgroundColor,
      child: Column(
        children: [
          _buildHeader(colorScheme),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildChatBubble(_messages[index]),
            ),
          ),
          _buildInputArea(colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  onPressed: widget.onBack,
                  icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'END SESSION',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge('LIVE SESSION', widget.themeExt.borderColor),
              const SizedBox(width: 8),
              _buildBadge(widget.difficulty, const Color(0xFF2563EB).withValues(alpha: 0.1), textColor: const Color(0xFF2563EB)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, {Color? textColor}) {
    final isLive = label == 'LIVE SESSION';
    return MouseRegion(
      cursor: isLive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isLive ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LiveSessionOverlay(
                themeExt: widget.themeExt,
                onFinish: () => Navigator.pop(context),
              ),
            ),
          );
        } : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
            border: isLive ? Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.1)) : null,
          ),
          child: Row(
            children: [
              if (label.contains('ADVANCED')) 
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.bar_chart, size: 14, color: Color(0xFF2563EB)),
                ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? widget.themeExt.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              message.senderName,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2563EB),
                letterSpacing: 1.0,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isUser) ...[
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(message.avatarUrl),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: message.isUser ? const Color(0xFF2563EB) : widget.themeExt.cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(24),
                      topRight: const Radius.circular(24),
                      bottomLeft: Radius.circular(message.isUser ? 24 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.themeExt.shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : colorScheme.onSurface,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(message.avatarUrl),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: widget.themeExt.scaffoldBackgroundColor,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: widget.themeExt.cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: widget.themeExt.borderColor),
          boxShadow: [
            BoxShadow(
              color: widget.themeExt.shadowColor,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _toggleListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isListening ? const Color(0xFF2563EB).withValues(alpha: 0.1) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none_outlined,
                    color: _isListening ? const Color(0xFF2563EB) : widget.themeExt.secondaryText,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: 3,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your response here',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintStyle: TextStyle(
                      color: widget.themeExt.secondaryText.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Send',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.near_me_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
