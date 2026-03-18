import '../../auth/models/user_model.dart';

enum MessageType {
  text,
  image,
  file,
  system,
  storyReply,
  meetingInvite,
  voice,
  doodle;

  static MessageType fromString(String value) => switch (value) {
    'text' => MessageType.text,
    'image' => MessageType.image,
    'file' => MessageType.file,
    'system' => MessageType.system,
    'story_reply' => MessageType.storyReply,
    'meeting_invite' => MessageType.meetingInvite,
    'voice' => MessageType.voice,
    'doodle' => MessageType.doodle,
    _ => MessageType.text,
  };

  String toJson() => switch (this) {
    MessageType.text => 'text',
    MessageType.image => 'image',
    MessageType.file => 'file',
    MessageType.system => 'system',
    MessageType.storyReply => 'story_reply',
    MessageType.meetingInvite => 'meeting_invite',
    MessageType.voice => 'voice',
    MessageType.doodle => 'doodle',
  };
}

class MessageReaction {
  final String emoji;
  final List<String> userIds;

  const MessageReaction({required this.emoji, required this.userIds});

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    final users = json['users'] ?? json['userIds'] ?? [];
    final ids = <String>[];
    for (final u in users) {
      if (u is String) {
        ids.add(u);
      } else if (u is Map) {
        ids.add(u['_id']?.toString() ?? u['id']?.toString() ?? '');
      }
    }
    return MessageReaction(emoji: json['emoji'] ?? '', userIds: ids);
  }
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final UserModel? sender; // populated sender object
  final String? content;
  final MessageType type;
  final DateTime createdAt;
  final List<dynamic> attachments;
  final String? replyTo; // ID of replied-to message
  final Map<String, dynamic>? replyToMessage; // populated reply message
  final bool isForwarded;
  final List<MessageReaction> reactions;
  final List<dynamic> readBy;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.sender,
    this.content,
    required this.type,
    required this.createdAt,
    this.attachments = const [],
    this.replyTo,
    this.replyToMessage,
    this.isForwarded = false,
    this.reactions = const [],
    this.readBy = const [],
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // senderId can be a string or populated object
    final senderRaw = json['senderId'];
    final senderId = senderRaw is Map
        ? (senderRaw['_id'] ?? senderRaw['id'] ?? '')
        : (senderRaw?.toString() ?? '');

    final senderUser = senderRaw is Map
        ? UserModel.fromJson(senderRaw as Map<String, dynamic>)
        : null;

    // replyTo can be a string ID or a populated object
    final replyRaw = json['replyTo'];
    final replyTo = replyRaw is Map
        ? (replyRaw['_id']?.toString() ?? replyRaw['id']?.toString())
        : replyRaw?.toString();
    final replyToMessage = replyRaw is Map
        ? Map<String, dynamic>.from(replyRaw)
        : null;

    // Reactions
    final reactionsList = json['reactions'] as List? ?? [];
    final reactions = [
      for (final r in reactionsList)
        if (r is Map<String, dynamic>) MessageReaction.fromJson(r),
    ];

    return MessageModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      conversationId: json['conversationId'] is Map
          ? (json['conversationId']['_id'] ?? json['conversationId']['id'])
                .toString()
          : (json['conversationId'] ?? '').toString(),
      senderId: senderId.toString(),
      sender: senderUser,
      content: json['content'],
      type: MessageType.fromString(json['type'] ?? 'text'),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      attachments: json['attachments'] ?? [],
      replyTo: replyTo,
      replyToMessage: replyToMessage,
      isForwarded: json['isForwarded'] ?? false,
      reactions: reactions,
      readBy: json['readBy'] ?? [],
    );
  }

  MessageModel copyWith({List<MessageReaction>? reactions}) => MessageModel(
    id: id,
    conversationId: conversationId,
    senderId: senderId,
    sender: sender,
    content: content,
    type: type,
    createdAt: createdAt,
    attachments: attachments,
    replyTo: replyTo,
    replyToMessage: replyToMessage,
    isForwarded: isForwarded,
    reactions: reactions ?? this.reactions,
    readBy: readBy,
  );
}
