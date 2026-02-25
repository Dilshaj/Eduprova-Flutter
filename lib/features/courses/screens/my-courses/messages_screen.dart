import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool _isFullScreen = false;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'id': 1,
      'user': 'Amit V.',
      'time': '10:45 AM',
      'text': 'Is anyone stuck on the final project?',
      'initial': 'A',
      'color': const Color(0xFF2563EB), // blue-600
      'sender': 'other',
    },
    {
      'id': 2,
      'user': 'Priya K.',
      'time': '10:47 AM',
      'text': 'I just finished it! Use the helper function from Lesson 4.',
      'initial': 'P',
      'color': const Color(0xFFDB2777), // pink-600
      'sender': 'other',
    },
    {
      'id': 3,
      'user': 'Kevin J.',
      'time': '11:02 AM',
      'text': 'Thanks Priya, that helped a lot.',
      'initial': 'K',
      'color': const Color(0xFF16A34A), // green-600
      'sender': 'other',
    },
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'user': 'You',
      'time': _formatTime(DateTime.now()),
      'text': text,
      'initial': 'Y',
      'color': const Color(0xFF9333EA), // purple-600
      'sender': 'user',
    };

    setState(() {
      _messages.add(newMessage);
      _inputController.clear();
    });

    _scrollToBottom();

    // Simulate bot reply
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final replyMessage = {
        'id': DateTime.now().millisecondsSinceEpoch + 1,
        'user': 'Class Bot',
        'time': _formatTime(DateTime.now()),
        'text':
            'Thanks for your message! An instructor will review it shortly.',
        'initial': 'B',
        'color': const Color(0xFF4B5563), // gray-600
        'sender': 'other',
      };
      setState(() {
        _messages.add(replyMessage);
      });
      _scrollToBottom();
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

  String _formatTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    String minStr = minute < 10 ? '0$minute' : '$minute';
    return '$hour:$minStr $period';
  }

  @override
  Widget build(BuildContext context) {
    return _isFullScreen ? _buildFullScreen() : _buildInline();
  }

  Widget _buildInline() {
    return Scaffold(backgroundColor: Colors.white, body: _buildUI(false));
  }

  Widget _buildFullScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _buildUI(true)),
    );
  }

  Widget _buildUI(bool isFull) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Classroom Chat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isFullScreen = !_isFullScreen;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFull ? Icons.fullscreen_exit : Icons.fullscreen,
                      size: 20,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final item = _messages[index];
                final isUser = item['sender'] == 'user';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser)
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 12, top: 4),
                          decoration: BoxDecoration(
                            color: item['color'],
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            item['initial'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                textDirection: isUser
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                children: [
                                  Text(
                                    item['user'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['time'],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? const Color(0xFF9333EA)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isUser
                                      ? const Radius.circular(16)
                                      : Radius.zero,
                                  bottomRight: isUser
                                      ? Radius.zero
                                      : const Radius.circular(16),
                                ),
                                border: Border.all(
                                  color: isUser
                                      ? const Color(0xFF9333EA)
                                      : const Color(
                                          0xFFE5E7EB,
                                        ).withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                item['text'],
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: isUser
                                      ? Colors.white
                                      : const Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Input Area
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              12 + (isFull ? 0 : MediaQuery.of(context).padding.bottom),
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      maxLines: 4,
                      minLines: 1,
                      onChanged: (text) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Message classroom...',
                        hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _inputController.text.trim().isNotEmpty
                        ? _handleSend
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: _inputController.text.trim().isNotEmpty
                            ? const Color(0xFF9333EA)
                            : const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (_inputController.text.trim().isNotEmpty)
                            BoxShadow(
                              color: const Color(0xFFA855F7).withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 20,
                      ),
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
