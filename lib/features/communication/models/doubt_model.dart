class DoubtModel {
  final String id;
  final String courseId;
  final String lectureId;
  final DoubtUser user;
  final String title;
  final String content;
  final List<String> tags;
  final List<DoubtReplyModel> replies;
  final int views;
  final bool isResolved;
  final DateTime createdAt;
  final DateTime updatedAt;

  DoubtModel({
    required this.id,
    required this.courseId,
    required this.lectureId,
    required this.user,
    required this.title,
    required this.content,
    required this.tags,
    required this.replies,
    required this.views,
    required this.isResolved,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DoubtModel.fromJson(Map<String, dynamic> json) {
    return DoubtModel(
      id: json['_id'] ?? '',
      courseId: json['courseId'] ?? '',
      lectureId: json['lectureId'] ?? '',
      user: DoubtUser.fromJson(json['userId'] ?? {}),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      replies:
          (json['replies'] as List?)
              ?.map((r) => DoubtReplyModel.fromJson(r))
              .toList() ??
          [],
      views: json['views'] ?? 0,
      isResolved: json['isResolved'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class DoubtUser {
  final String id;
  final String name;
  final String avatar;

  DoubtUser({required this.id, required this.name, required this.avatar});

  factory DoubtUser.fromJson(Map<String, dynamic> json) {
    return DoubtUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Member',
      avatar: json['avatar'] ?? '',
    );
  }
}

class DoubtReplyModel {
  final String id;
  final DoubtUser user;
  final String content;
  final DateTime createdAt;

  DoubtReplyModel({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
  });

  factory DoubtReplyModel.fromJson(Map<String, dynamic> json) {
    return DoubtReplyModel(
      id: json['_id'] ?? '',
      user: DoubtUser.fromJson(json['userId'] ?? {}),
      content: json['content'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
