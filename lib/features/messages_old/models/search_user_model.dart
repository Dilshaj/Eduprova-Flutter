class SearchUserModel {
  final String id;
  final String name;
  final String email;
  final String username;
  final String role;
  final String? avatar;

  const SearchUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    this.avatar,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) {
    return SearchUserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      role: json['role']?.toString() ?? 'STUDENT',
      avatar: json['avatar']?.toString(),
    );
  }

  String get displayName {
    if (name.trim().isNotEmpty) return name.trim();
    if (username.trim().isNotEmpty) return username.trim();
    if (email.trim().isNotEmpty) return email.trim();
    return 'Unknown User';
  }
}
