import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/enrolled_course_model.dart';
import 'dart:developer';

class ProgressRepository {
  final Dio _dio = ApiClient.instance;

  Future<ProgressModel?> getProgress(String courseId) async {
    try {
      final response = await _dio.get('/api/v2/progress/$courseId');
      if (response.data != null) {
        return ProgressModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      log('Error fetching progress for course $courseId: $e');
      return null;
    }
  }

  Future<ProgressModel?> updateProgress(
    String courseId,
    String lectureId,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v2/progress/$courseId/complete',
        data: {'lectureId': lectureId},
      );
      if (response.data != null) {
        return ProgressModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      log(
        'Error updating progress for lecture $lectureId in course $courseId: $e',
      );
      return null;
    }
  }

  Future<ProgressModel?> updateWatchTime(
    String courseId,
    String lectureId,
    num watchTime,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v2/progress/$courseId/watch-time',
        data: {'lessonId': lectureId, 'watchTime': watchTime},
      );
      if (response.data != null) {
        return ProgressModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      log(
        'Error updating watch time for lecture $lectureId in course $courseId: $e',
      );
      return null;
    }
  }
}
