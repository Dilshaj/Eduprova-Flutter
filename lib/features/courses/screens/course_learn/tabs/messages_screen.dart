import 'package:eduprova/theme.dart';
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
    {
      'id': 4,
      'user': 'Kevin J.',
      'time': '11:02 AM',
      'text': 'Thanks Priya, that helped a lot.',
      'initial': 'K',
      'color': const Color(0xFF16A34A), // green-600
      'sender': 'other',
    },
    {
      'id': 5,
      'user': 'Kevin J.',
      'time': '11:02 AM',
      'text': 'Thanks Priya, that helped a lot.',
      'initial': 'K',
      'color': const Color(0xFF16A34A), // green-600
      'sender': 'other',
    },
    {
      'id': 6,
      'user': 'Kevin J.',
      'time': '11:02 AM',
      'text': 'Thanks Priya, that helped a lot.',
      'initial': 'K',
      'color': const Color(0xFF16A34A), // green-600
      'sender': 'other',
    },
    {
      'id': 7,
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
      if (!mounted) return;
      final ctrl = _isFullScreen
          ? _scrollController
          : PrimaryScrollController.of(context);
      if (ctrl.hasClients) {
        ctrl.animateTo(
          ctrl.position.maxScrollExtent,
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
    return _buildInline();
  }

  Widget _buildInline() {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    return Scaffold(
      backgroundColor: themeExt.scaffoldBackgroundColor,
      body: _buildUI(false),
    );
  }

  Widget _buildFullScreen() {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    return Scaffold(
      backgroundColor: themeExt.scaffoldBackgroundColor,
      body: SafeArea(child: _buildUI(true)),
    );
  }

  Widget _buildUI(bool isFull) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: isFull ? themeExt.scaffoldBackgroundColor : themeExt.cardColor,
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(20, isFull ? 16 : 16 + 48, 20, 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: themeExt.borderColor)),
              color: isFull
                  ? themeExt.scaffoldBackgroundColor
                  : themeExt.cardColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Classroom Chat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    if (isFull) {
                      Navigator.pop(context);
                    } else {
                      _isFullScreen = true;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => _buildFullScreen(),
                          fullscreenDialog: true,
                        ),
                      );
                      _isFullScreen = false;
                      setState(() {});
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeExt.skeletonBase,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFull ? Icons.fullscreen_exit : Icons.fullscreen,
                      size: 20,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: isFull ? _scrollController : null,
              primary: !isFull,
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
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['time'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: themeExt.secondaryText,
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
                                    ? colorScheme.primary
                                    : themeExt.skeletonBase,
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
                                      ? colorScheme.primary
                                      : themeExt.borderColor.withValues(
                                          alpha: 0.5,
                                        ),
                                ),
                              ),
                              child: Text(
                                item['text'],
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: isUser
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
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
            decoration: BoxDecoration(
              color: isFull
                  ? themeExt.scaffoldBackgroundColor
                  : themeExt.cardColor,
              border: Border(top: BorderSide(color: themeExt.borderColor)),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: themeExt.skeletonBase,
                border: Border.all(color: themeExt.borderColor),
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
                      decoration: InputDecoration(
                        hintText: 'Message classroom...',
                        hintStyle: TextStyle(
                          color: themeExt.secondaryText,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
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
                            ? colorScheme.primary
                            : themeExt.borderColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (_inputController.text.trim().isNotEmpty)
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
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
