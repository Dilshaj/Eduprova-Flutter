class CommentModel {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String text;
  final DateTime createdAt;
  final int likeCount;
  bool isLiked;

  CommentModel({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.text,
    required this.createdAt,
    this.likeCount = 0,
    this.isLiked = false,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    final author = map['authorId'] as Map<String, dynamic>?;
    return CommentModel(
      id: map['_id'] ?? '',
      authorName: author != null
          ? '${author['firstName'] ?? ''} ${author['lastName'] ?? ''}'.trim()
          : 'Anonymous',
      authorAvatar: author?['avatar'] ?? 'assets/avatars/1.png',
      text: map['text'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      likeCount: map['likeCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
    );
  }

  static String formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}
