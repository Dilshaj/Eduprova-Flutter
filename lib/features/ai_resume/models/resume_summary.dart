class ResumeSummary {
  final String id;
  final String title;
  final String slug;
  final bool isPublic;
  final bool isLocked;
  final DateTime updatedAt;
  final DateTime createdAt;

  ResumeSummary({
    required this.id,
    required this.title,
    required this.slug,
    required this.isPublic,
    required this.isLocked,
    required this.updatedAt,
    required this.createdAt,
  });

  factory ResumeSummary.fromJson(Map<String, dynamic> json) {
    return ResumeSummary(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Untitled Resume',
      slug: json['slug'] ?? '',
      isPublic: json['isPublic'] ?? false,
      isLocked: json['isLocked'] ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
