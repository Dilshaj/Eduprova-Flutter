import '../../auth/models/user_model.dart';

enum ConversationType {
  direct,
  group,
  communityGroup,
  announcement;

  static ConversationType fromString(String value) => switch (value) {
    'direct' => .direct,
    'group' => .group,
    'community_group' => .communityGroup,
    'announcement' => .announcement,
    _ => .direct,
  };

  String toJson() => switch (this) {
    .direct => 'direct',
    .group => 'group',
    .communityGroup => 'community_group',
    .announcement => 'announcement',
  };
}

class ConversationMember {
  final String userId;
  final String role;
  final DateTime joinedAt;
  final int unreadCount;
  final DateTime? mutedUntil;
  final bool isPinned;
  final UserModel? user;

  ConversationMember({
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.unreadCount = 0,
    this.mutedUntil,
    this.isPinned = false,
    this.user,
  });

  factory ConversationMember.fromJson(Map<String, dynamic> json) {
    final userData = json['userId'];
    return .new(
      userId: userData is Map ? (userData['id'] ?? userData['_id']) : userData,
      role: json['role'] ?? 'member',
      joinedAt: DateTime.parse(
        json['joinedAt'] ?? DateTime.now().toIso8601String(),
      ),
      unreadCount: json['unreadCount'] ?? 0,
      mutedUntil: json['mutedUntil'] != null
          ? DateTime.parse(json['mutedUntil'])
          : null,
      isPinned: json['isPinned'] ?? false,
      user: userData is Map
          ? UserModel.fromJson(userData as Map<String, dynamic>)
          : null,
    );
  }
}

class ConversationModel {
  final String id;
  final ConversationType type;
  final String status;
  final String? name;
  final String? avatar;
  final String? description;
  final List<ConversationMember> participants;
  final dynamic lastMessage;
  final String createdBy;
  final String? communityId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConversationModel({
    required this.id,
    required this.type,
    this.status = 'active',
    this.name,
    this.avatar,
    this.description,
    required this.participants,
    this.lastMessage,
    required this.createdBy,
    this.communityId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return .new(
      id: json['id'] ?? json['_id'] ?? '',
      type: ConversationType.fromString(json['type'] ?? 'direct'),
      status: json['status']?.toString() ?? 'active',
      name: json['name'],
      avatar: json['avatar'],
      description: json['description'],
      participants: [
        for (final p in json['participants'] ?? [])
          ConversationMember.fromJson(p),
      ],
      lastMessage: json['lastMessage'],
      createdBy: json['createdBy'] is Map
          ? (json['createdBy']['id'] ?? json['createdBy']['_id'])
          : json['createdBy'],
      communityId: json['communityId'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  String getDisplayTitle(String currentUserId) {
    if (type == .direct) {
      final otherParticipant = participants.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => participants.first,
      );
      if (otherParticipant.user != null) {
        return '${otherParticipant.user!.firstName} ${otherParticipant.user!.lastName}';
      }
      return 'Direct Message';
    }
    return name ?? 'Unnamed Group';
  }

  String? getDisplayAvatar(String currentUserId) {
    if (type == .direct) {
      final otherParticipant = participants.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => participants.first,
      );
      return otherParticipant.user?.avatar ?? avatar;
    }
    return avatar;
  }
}
