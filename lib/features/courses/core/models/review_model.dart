import 'course_model.dart';
import 'package:flutter/foundation.dart';

@immutable
class ReviewModel {
  final String id;
  final String courseId;
  final InstructorModel
  user; // Assuming user is populated similarly to instructor
  final int rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.courseId,
    required this.user,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] ?? json['id'] ?? '',
      courseId: json['course'] ?? '',
      user: InstructorModel.fromJson(json['user'] ?? {}),
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

@immutable
class CourseReviewsResponse {
  final List<ReviewModel> reviews;
  final int total;
  final int page;
  final int limit;
  final int pages;
  final bool userHasReviewed;

  const CourseReviewsResponse({
    required this.reviews,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
    required this.userHasReviewed,
  });

  factory CourseReviewsResponse.fromJson(Map<String, dynamic> json) {
    return CourseReviewsResponse(
      reviews:
          (json['reviews'] as List?)
              ?.map((e) => ReviewModel.fromJson(e))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
      userHasReviewed: json['userHasReviewed'] ?? false,
    );
  }
}
