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
    'text' => .text,
    'image' => .image,
    'file' => .file,
    'system' => .system,
    'story_reply' => .storyReply,
    'meeting_invite' => .meetingInvite,
    'voice' => .voice,
    'doodle' => .doodle,
    _ => .text,
  };

  String toJson() => switch (this) {
    .text => 'text',
    .image => 'image',
    .file => 'file',
    .system => 'system',
    .storyReply => 'story_reply',
    .meetingInvite => 'meeting_invite',
    .voice => 'voice',
    .doodle => 'doodle',
  };
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String? content;
  final MessageType type;
  final DateTime createdAt;
  final List<dynamic> attachments;
  final String? replyTo;
  final bool isForwarded;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.content,
    required this.type,
    required this.createdAt,
    this.attachments = const [],
    this.replyTo,
    this.isForwarded = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return .new(
      id: json['id'] ?? json['_id'] ?? '',
      conversationId: json['conversationId'] is Map
          ? (json['conversationId']['id'] ?? json['conversationId']['_id'])
          : (json['conversationId'] ?? ''),
      senderId: json['senderId'] is Map
          ? (json['senderId']['id'] ?? json['senderId']['_id'])
          : json['senderId'],
      content: json['content'],
      type: MessageType.fromString(json['type'] ?? 'text'),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      attachments: json['attachments'] ?? [],
      replyTo: json['replyTo'],
      isForwarded: json['isForwarded'] ?? false,
    );
  }
}
