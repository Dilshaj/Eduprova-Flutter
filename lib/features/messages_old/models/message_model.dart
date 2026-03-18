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
    final ids = <String>[];

    final singleUser = json['userId'];
    if (singleUser != null) {
      if (singleUser is String) {
        ids.add(singleUser);
      } else if (singleUser is Map) {
        final id =
            singleUser['_id']?.toString() ?? singleUser['id']?.toString();
        if (id != null && id.isNotEmpty) {
          ids.add(id);
        }
      }
    }

    final users = json['users'] ?? json['userIds'];
    if (users is List) {
      for (final u in users) {
        if (u is String) {
          ids.add(u);
        } else if (u is Map) {
          final id = u['_id']?.toString() ?? u['id']?.toString();
          if (id != null && id.isNotEmpty) {
            ids.add(id);
          }
        }
      }
    }

    return MessageReaction(emoji: json['emoji'] ?? '', userIds: ids);
  }
}

class MessageAttachment {
  final String type;
  final String url;
  final String? thumbnailUrl;
  final String? mimeType;
  final String? fileName;
  final int? fileSize;

  const MessageAttachment({
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.mimeType,
    this.fileName,
    this.fileSize,
  });

  factory MessageAttachment.fromJson(dynamic json) {
    if (json is String) {
      return MessageAttachment(type: 'image', url: json);
    }
    if (json is Map) {
      return MessageAttachment(
        type: json['type']?.toString() ?? 'image',
        url: json['url']?.toString() ?? '',
        thumbnailUrl: json['thumbnailUrl']?.toString(),
        mimeType: json['mimeType']?.toString(),
        fileName: json['fileName']?.toString(),
        fileSize: json['fileSize'] as int?,
      );
    }
    return const MessageAttachment(type: 'image', url: '');
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'url': url,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    if (mimeType != null) 'mimeType': mimeType,
    if (fileName != null) 'fileName': fileName,
    if (fileSize != null) 'fileSize': fileSize,
  };
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final UserModel? sender; // populated sender object
  final String? content;
  final MessageType type;
  final DateTime createdAt;
  final List<MessageAttachment> attachments;
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

  static String? _replySenderName(Map<String, dynamic> replyMessage) {
    final sender = replyMessage['senderId'];
    if (sender is Map<String, dynamic>) {
      final fullName = [
        sender['firstName']?.toString(),
        sender['lastName']?.toString(),
      ].where((part) => part != null && part.trim().isNotEmpty).join(' ');

      if (fullName.isNotEmpty) {
        return fullName;
      }

      final fallback =
          sender['name']?.toString() ??
          sender['username']?.toString() ??
          sender['email']?.toString();
      if (fallback != null && fallback.isNotEmpty) {
        return fallback;
      }
    }

    return replyMessage['senderName']?.toString();
  }

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
        ? {
            ...Map<String, dynamic>.from(replyRaw),
            'senderName': _replySenderName(Map<String, dynamic>.from(replyRaw)),
          }
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
      attachments:
          (json['attachments'] as List?)
              ?.map(MessageAttachment.fromJson)
              .toList() ??
          const [],
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
