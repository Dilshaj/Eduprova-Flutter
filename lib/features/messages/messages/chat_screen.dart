import 'package:edupurva/core/navigation/app_routes.dart';
import 'package:edupurva/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatefulWidget {
  final String id;
  const ChatScreen({super.key, required this.id});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Hey! Did you get a chance to look at the MacBook Pro mockups I shared earlier? 💻',
      isMe: false,
      time: '5:38 PM',
      avatarUrl: 'https://i.pravatar.cc/150?u=1',
    ),
    ChatMessage(
      text:
          'Yes! They look absolutely stunning. The attention to detail on the bezel is perfect. 👌',
      isMe: true,
      time: '5:40 PM',
      avatarUrl: 'https://i.pravatar.cc/150?u=2',
      isRead: true,
    ),
    ChatMessage(
      isMe: false,
      time: '5:42 PM',
      avatarUrl: 'https://i.pravatar.cc/150?u=1',
      attachment: AttachmentFile(
        fileName: 'brand_assets_v2.zip',
        fileSize: '4.2 MB',
        icon: Icons.insert_drive_file,
      ),
      text: 'Great! Sending over the refined logo files now.',
    ),
    ChatMessage(
      text:
          'Received. I\'ll review these with the UI team in the workshop tomorrow morning.',
      isMe: true,
      time: '5:45 PM',
      avatarUrl: 'https://i.pravatar.cc/150?u=2',
      isRead: true,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
        Colors.grey;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: InkWell(
          onTap: () {
            context.push(AppRoutes.contactDetail(widget.id));
          },
          child: Row(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?u=1',
                    ), // dummy image
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Varahanarasimha L.',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ONLINE',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call_outlined, color: subTextColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.videocam_outlined, color: subTextColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: subTextColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Date separator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'TODAY',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildChatBubble(_messages[index], context);
              },
            ),
          ),

          // Typing indicator placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?u=1',
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    _buildTypingDot(context),
                    const SizedBox(width: 4),
                    _buildTypingDot(context),
                    const SizedBox(width: 4),
                    _buildTypingDot(context),
                  ],
                ),
              ],
            ),
          ),

          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildTypingDot(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[700]
            : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final otherMsgBg = isDark ? Colors.grey[800]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey.shade600;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey.shade100;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(message.avatarUrl),
            ),
            const SizedBox(width: 12),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: message.isMe ? null : otherMsgBg,
                    gradient: message.isMe ? AppTheme.primaryGradient : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: message.isMe
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                      bottomRight: message.isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                    ),
                    boxShadow: message.isMe
                        ? [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.4)
                                  : Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                    border: message.isMe
                        ? null
                        : Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.text.isNotEmpty)
                        Text(
                          message.text,
                          style: TextStyle(
                            color: message.isMe ? Colors.white : textColor,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      if (message.attachment != null) ...[
                        if (message.text.isNotEmpty) const SizedBox(height: 16),
                        _buildAttachment(message.attachment!, context),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.time,
                      style: TextStyle(color: subTextColor, fontSize: 11),
                    ),
                    if (message.isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all,
                        size: 14,
                        color: message.isRead
                            ? Colors.blue
                            : Colors.grey.shade400,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          if (message.isMe) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(message.avatarUrl),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachment(AttachmentFile attachment, BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
        Colors.grey;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(attachment.icon, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  attachment.fileSize,
                  style: TextStyle(color: subTextColor, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.download_outlined, color: subTextColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey.shade500;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey.shade200;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, color: subTextColor),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: subTextColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.sentiment_satisfied_alt,
                      color: subTextColor,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final String avatarUrl;
  final bool isRead;
  final AttachmentFile? attachment;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    required this.avatarUrl,
    this.isRead = false,
    this.attachment,
  });
}

class AttachmentFile {
  final String fileName;
  final String fileSize;
  final IconData icon;

  AttachmentFile({
    required this.fileName,
    required this.fileSize,
    required this.icon,
  });
}
