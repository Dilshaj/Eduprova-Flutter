import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class AiRepository {
  static final AiRepository instance = AiRepository._internal();
  AiRepository._internal();

  final Dio _dio = ApiClient.instance;

  Future<String> askAi({
    required String query,
    required String courseId,
    String? lectureId,
  }) async {
    try {
      final response = await _dio.post(
        '/ai/ask-doubt',
        data: {
          'question': query,
          'courseId': courseId,
          'lectureId': lectureId ?? '',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Based on backend service, it might return the answer directly or in a field
        return response.data['answer'] ??
            response.data['reply'] ??
            response.data['message'] ??
            'AI response received.';
      }
      return 'Failed to get answer from AI.';
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return e.response?.data['message'] ?? 'Failed to get answer from AI.';
      }
      return 'Error connecting to AI service.';
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }
}
