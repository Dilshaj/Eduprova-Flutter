import 'package:eduprova/theme.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduprova/features/communication/providers/messages_provider.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  final String courseId;

  const MessagesScreen({super.key, required this.courseId});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  bool _isFullScreen = false;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Messages state removed, now fetched from messagesProvider

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    ref.read(allMessagesProvider.notifier).sendMessage(widget.courseId, text);
    _inputController.clear();
    _scrollToBottom();
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

    final messageState = ref.watch(messagesProvider(widget.courseId));
    final messages = messageState.messages;
    final isConnected = messageState.isConnected;
    final viewerCount = messageState.viewerCount;

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
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      'Classroom Chat ($viewerCount watching)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
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
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final item = messages[index];
                final isUser = item.userId == messageState.currentUserId;

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
                            // Extract color assuming the format sent like 'bg-blue-600' or default
                            // to a generic color. For UI simplicity, hardcode a color or derive from initials
                            color: const Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            item.initials,
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
                                    item.user,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.time,
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
                                item.text,
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
