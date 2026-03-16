import 'course_detail_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final num amount;
  final String currency;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      items:
          (json['items'] as List?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'INR',
      status: json['status'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}

class OrderItemModel {
  final String id;
  final CourseDetailModel? course;
  final num price;
  final String title;

  OrderItemModel({
    required this.id,
    this.course,
    required this.price,
    required this.title,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['_id'] ?? '',
      course: json['courseId'] != null
          ? CourseDetailModel.fromJson(json['courseId'])
          : null,
      price: json['price'] ?? 0,
      title: json['title'] ?? '',
    );
  }
}

class ProgressModel {
  final String id;
  final String userId;
  final String courseId;
  final List<String> completedLectures;
  final num percentComplete;
  final String? lastAccessedLectureId;
  final Map<String, num> videoWatchTimes;
  final List<String> completedExams;
  final bool isFinalExamPassed;
  final num? finalExamScore;

  ProgressModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.completedLectures,
    required this.percentComplete,
    this.lastAccessedLectureId,
    this.videoWatchTimes = const {},
    this.completedExams = const [],
    this.isFinalExamPassed = false,
    this.finalExamScore,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      courseId: json['courseId'] ?? '',
      completedLectures: List<String>.from(
        (json['completedLectures'] as List?)?.map((l) => l.toString()) ?? [],
      ),
      percentComplete: json['percentComplete'] ?? 0,
      lastAccessedLectureId: json['lastAccessedLectureId'],
      videoWatchTimes:
          (json['videoWatchTimes'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as num),
          ) ??
          const {},
      completedExams: List<String>.from(
        (json['completedExams'] as List?)?.map((e) => e.toString()) ?? [],
      ),
      isFinalExamPassed: json['isFinalExamPassed'] ?? false,
      finalExamScore: json['finalExamScore'],
    );
  }
}

class EnrolledCourse {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final int progress;
  final int totalModules;
  final int completedModules;
  final String image;
  final String status; // 'Fresh', 'Ongoing', 'Completed'
  final String? nextLesson;

  EnrolledCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.progress,
    required this.totalModules,
    required this.completedModules,
    required this.image,
    required this.status,
    this.nextLesson,
  });
}
