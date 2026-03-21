import '../../auth/models/user_model.dart';
import 'conversation_model.dart';

class CommunityModel {
  final String id;
  final String name;
  final String? description;
  final String? avatar;
  final String creatorId;
  final List<dynamic> members;
  final List<ConversationModel> groups;
  final String? announcementGroupId;
  final DateTime? createdAt;

  const CommunityModel({
    required this.id,
    required this.name,
    required this.creatorId,
    this.description,
    this.avatar,
    this.members = const [],
    this.groups = const [],
    this.announcementGroupId,
    this.createdAt,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    final membersJson = (json['members'] as List?) ?? const [];
    final groupsJson = (json['groups'] as List?) ?? const [];

    return CommunityModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      avatar: json['avatar']?.toString(),
      creatorId: json['creatorId'] is Map<String, dynamic>
          ? ((json['creatorId']['id'] ?? json['creatorId']['_id'] ?? '')
                .toString())
          : (json['creatorId'] ?? '').toString(),
      members: membersJson
          .map(
            (member) => member is Map<String, dynamic>
                ? UserModel.fromJson(member)
                : member,
          )
          .toList(),
      groups: groupsJson
          .whereType<Map>()
          .map((group) => ConversationModel.fromJson(Map<String, dynamic>.from(group)))
          .toList(),
      announcementGroupId: json['announcementGroupId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  int get memberCount => members.length;
}
