import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/doubt_model.dart';
import 'dart:developer';

class DoubtsRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<DoubtModel>> getDoubts({
    required String courseId,
    String? lectureId,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final queryParams = {'courseId': courseId, 'page': page, 'limit': limit};

      if (lectureId != null) queryParams['lectureId'] = lectureId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get('/doubts', queryParameters: queryParams);

      if (response.data != null && response.data['doubts'] != null) {
        final List<dynamic> doubtsData = response.data['doubts'];
        return doubtsData.map((d) => DoubtModel.fromJson(d)).toList();
      }
      return [];
    } catch (e) {
      log('Error fetching doubts for course $courseId: $e');
      return [];
    }
  }

  Future<DoubtModel?> createDoubt({
    required String courseId,
    required String lectureId,
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    try {
      final response = await _dio.post(
        '/doubts',
        data: {
          'courseId': courseId,
          'lectureId': lectureId,
          'title': title,
          'content': content,
          if (tags.isNotEmpty) 'tags': tags,
        },
      );

      if (response.data != null) {
        return DoubtModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      log('Error creating doubt: $e');
      return null;
    }
  }

  Future<DoubtModel?> addReply({
    required String doubtId,
    required String content,
  }) async {
    try {
      final response = await _dio.post(
        '/doubts/$doubtId/replies',
        data: {'content': content},
      );

      if (response.data != null) {
        return DoubtModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      log('Error adding reply to doubt $doubtId: $e');
      return null;
    }
  }
}
