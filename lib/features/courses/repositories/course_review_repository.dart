import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/review_model.dart';

class CourseReviewRepository {
  final Dio _dio;

  CourseReviewRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  Future<CourseReviewsResponse> getReviews(
    String courseId, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dio.get(
      '/courses/$courseId/reviews',
      queryParameters: {'page': page, 'limit': limit},
    );
    return CourseReviewsResponse.fromJson(response.data);
  }

  Future<ReviewModel> postReview(
    String courseId,
    int rating,
    String comment,
  ) async {
    final response = await _dio.post(
      '/courses/$courseId/reviews',
      data: {'rating': rating, 'comment': comment},
    );
    return ReviewModel.fromJson(response.data);
  }

  Future<void> deleteReview(String courseId, String reviewId) async {
    await _dio.delete('/courses/$courseId/reviews/$reviewId');
  }
}
