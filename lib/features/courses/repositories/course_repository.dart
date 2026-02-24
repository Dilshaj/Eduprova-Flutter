import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/course_model.dart';
import '../models/course_detail_model.dart';
import 'dart:developer';

class CourseRepository {
  static final CourseRepository instance = CourseRepository._internal();
  CourseRepository._internal();

  final Dio _dio = ApiClient.instance;

  Future<List<CourseModel>> getCourses({String? category}) async {
    final queryParams = <String, dynamic>{};
    if (category != null &&
        category != 'All Courses' &&
        category != 'New Trending') {
      queryParams['category'] = category;
    }

    final response = await _dio.get('/courses', queryParameters: queryParams);

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['courses'];
      return data.map((e) => CourseModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load courses');
  }

  Future<CourseDetailModel> getCourseDetails(
    String id, {
    bool isAuthenticated = false,
  }) async {
    CourseDetailModel course;
    try {
      final response = await _dio.get('/courses/$id');
      if (response.statusCode == 200) {
        final dynamic data =
            response.data['data'] ?? response.data['course'] ?? response.data;
        course = CourseDetailModel.fromJson(data);

        // If authenticated and backend indicates ownership, try fetching /learn content
        if (isAuthenticated && data['isOwner'] == true) {
          try {
            final learnResponse = await _dio.get('/courses/$id/learn');
            if (learnResponse.statusCode == 200) {
              final dynamic learnData =
                  learnResponse.data['data'] ??
                  learnResponse.data['course'] ??
                  learnResponse.data;
              return CourseDetailModel.fromJson(learnData);
            }
          } catch (e) {
            log('Failed to fetch /learn upgrade for owned course $id: $e');
            // Fallback to standard course data if /learn fails
          }
        }
        return course;
      }
      throw Exception('Failed to load course details');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to load course details',
      );
    }
  }
}
