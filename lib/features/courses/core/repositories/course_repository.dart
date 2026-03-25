import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/network/api_client.dart';
import '../models/course_model.dart';
import '../models/course_detail_model.dart';
import '../models/enrolled_course_model.dart';
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

  /// Fetches public course details from GET /courses/{id}.
  /// This is used by the Course Detail screen (everyone can see this).
  Future<CourseDetailModel> getCourseDetails(String id) async {
    try {
      final response = await _dio.get('/courses/$id');
      if (response.statusCode == 200) {
        final dynamic data =
            response.data['data'] ?? response.data['course'] ?? response.data;
        debugPrint('isOwner: ${data['isOwner']}');
        return CourseDetailModel.fromJson(data);
      }
      throw Exception('Failed to load course details');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to load course details',
      );
    }
  }

  /// Fetches authenticated learning content from GET /courses/{id}/learn.
  /// Only callable when the user owns the course (isOwner == true).
  Future<CourseDetailModel> getCourseLearn(String id) async {
    try {
      final response = await _dio.get('/courses/$id/learn');
      if (response.statusCode == 200) {
        final dynamic data =
            response.data['data'] ?? response.data['course'] ?? response.data;
        return CourseDetailModel.fromJson(data);
      }
      throw Exception('Failed to load course learning content');
    } on DioException catch (e) {
      log('getCourseLearn error for $id: $e');
      throw Exception(
        e.response?.data?['message'] ??
            'Failed to load course learning content',
      );
    }
  }

  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _dio.get('/orders');
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> ordersList =
            (data is Map<String, dynamic> && data.containsKey('orders'))
            ? data['orders'] as List<dynamic>
            : data as List<dynamic>;
        return ordersList.map((e) => OrderModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load orders');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load orders');
    }
  }

  Future<List<ProgressModel>> getProgress() async {
    try {
      final response = await _dio.get('/progress');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => ProgressModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load progress');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to load progress',
      );
    }
  }
}
