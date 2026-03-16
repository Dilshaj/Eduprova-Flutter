import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/enrolled_course_model.dart';
import 'dart:developer';

class ProgressRepository {
  final Dio _dio = ApiClient.instance;

  Future<ProgressModel?> getProgress(String courseId) async {
    try {
      final response = await _dio.get('/progress/$courseId');
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
        '/progress/$courseId/complete/$lectureId',
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
      final response = await _dio.patch(
        '/progress/$courseId/video-time/$lectureId',
        data: {'watchTime': watchTime},
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

  Future<ProgressModel?> markExamCompleted(
    String courseId,
    String moduleId,
  ) async {
    try {
      final response = await _dio.post('/progress/$courseId/exam/$moduleId');
      if (response.data != null) {
        return ProgressModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      log(
        'Error marking exam completed for module $moduleId in course $courseId: $e',
      );
      return null;
    }
  }

  Future<ProgressModel?> submitFinalExam(
    String courseId,
    num score,
    bool passed,
  ) async {
    try {
      final response = await _dio.post(
        '/progress/$courseId/final-exam',
        data: {'score': score, 'passed': passed},
      );
      if (response.data != null) {
        return ProgressModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      log('Error submitting final exam for course $courseId: $e');
      return null;
    }
  }
}
