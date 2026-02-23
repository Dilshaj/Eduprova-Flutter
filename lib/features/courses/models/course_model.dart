class CourseModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String level;
  final String language;
  final String description;
  final num originalPrice;
  final num? discountedPrice;
  final String? thumbnail;
  final num rating;
  final int numReviews;
  final int studentCount;
  final String? duration;
  final InstructorModel? instructor;

  CourseModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.level,
    required this.language,
    required this.description,
    required this.originalPrice,
    this.discountedPrice,
    this.thumbnail,
    required this.rating,
    required this.numReviews,
    required this.studentCount,
    this.duration,
    this.instructor,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      category: json['category'] ?? '',
      level: json['level'] ?? '',
      language: json['language'] ?? '',
      description: json['description'] ?? '',
      originalPrice: json['originalPrice'] ?? 0,
      discountedPrice: json['discountedPrice'],
      thumbnail: json['thumbnail'],
      rating: json['rating'] ?? 0,
      numReviews: json['numReviews'] ?? 0,
      studentCount: json['studentCount'] ?? 0,
      duration: json['duration'],
      instructor: json['instructor'] != null
          ? InstructorModel.fromJson(json['instructor'])
          : null,
    );
  }
}

class InstructorModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? avatar;
  final String? bio;

  InstructorModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.bio,
  });

  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      avatar: json['avatar'],
      bio: json['bio'],
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
