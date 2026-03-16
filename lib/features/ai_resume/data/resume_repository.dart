import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/resume_data.dart';
import '../models/resume_summary.dart';

class ResumeRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<ResumeSummary>> getResumes() async {
    final response = await _dio.get('/resume');
    return (response.data as List)
        .map((json) => ResumeSummary.fromJson(json))
        .toList();
  }

  Future<Map<String, dynamic>> getResume(String id) async {
    final response = await _dio.get('/resume/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> createResume(
    String title,
    String slug,
    ResumeData data,
  ) async {
    final response = await _dio.post(
      '/resume',
      data: {'title': title, 'slug': slug, 'data': data.toJson()},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateResume(
    String id, {
    ResumeData? data,
    String? title,
    String? slug,
    bool? isPublic,
    bool? isLocked,
  }) async {
    final Map<String, dynamic> payload = {};
    if (data != null) payload['data'] = data.toJson();
    if (title != null) payload['title'] = title;
    if (slug != null) payload['slug'] = slug;
    if (isPublic != null) payload['isPublic'] = isPublic;
    if (isLocked != null) payload['isLocked'] = isLocked;

    final response = await _dio.patch('/resume/$id', data: payload);
    return response.data;
  }

  Future<void> deleteResume(String id) async {
    await _dio.delete('/resume/$id');
  }

  Future<ResumeData> importResume(File file) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _dio.post('/resume/import', data: formData);
    // The import API returns ResumeData parsed from the file
    return ResumeData.fromJson(response.data);
  }
}
