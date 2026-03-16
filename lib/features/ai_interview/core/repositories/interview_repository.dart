import 'package:dio/dio.dart';
import 'package:eduprova/core/network/api_client.dart';
import '../models/interview_session_model.dart';
import '../models/interview_feedback_model.dart';
import '../models/interview_analytics_model.dart';

class InterviewRepository {
  final Dio _dio = ApiClient.instance;

  /// Create a new interview session and get questions back
  Future<({String sessionId, List<InterviewQuestion> questions})>
  createSession({
    required String type, // 'normal' or 'resume'
    required Map<String, dynamic> config,
  }) async {
    final response = await _dio.post(
      '/interview/create',
      data: {'type': type, 'config': config},
    );

    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to create interview session');
    }

    final questions = (data['questions'] as List<dynamic>)
        .map((q) => InterviewQuestion.fromJson(q as Map<String, dynamic>))
        .toList();

    return (sessionId: data['sessionId'] as String, questions: questions);
  }

  /// Get all sessions for the current user
  Future<List<InterviewSession>> getHistory() async {
    try {
      final response = await _dio.get('/interview/history');
      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Failed to fetch history');
      }

      final sessionsData = data['sessions'] as List<dynamic>? ?? [];
      return sessionsData.map((s) {
        try {
          return InterviewSession.fromJson(s as Map<String, dynamic>);
        } catch (e, stack) {
          print('Error parsing session: $e');
          print('Session data: $s');
          print(stack);
          rethrow;
        }
      }).toList();
    } catch (e, stack) {
      print('InterviewRepository.getHistory error: $e');
      print(stack);
      rethrow;
    }
  }

  /// Get analytics for the current user
  Future<InterviewAnalytics> getAnalytics() async {
    final response = await _dio.get('/interview/analytics');
    final data = response.data as Map<String, dynamic>;

    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to fetch analytics');
    }

    return InterviewAnalytics.fromJson(
      data['analytics'] as Map<String, dynamic>,
    );
  }

  /// Generate (or fetch existing) feedback for a session
  Future<InterviewFeedback> generateFeedback(String sessionId) async {
    final response = await _dio.post('/interview/feedback/$sessionId');
    final data = response.data as Map<String, dynamic>;

    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to generate feedback');
    }

    return InterviewFeedback.fromJson(data['feedback'] as Map<String, dynamic>);
  }

  /// Upload resume PDF and get parsed text back
  Future<String> uploadResume(String filePath, String fileName) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _dio.post(
      '/interview/upload-resume',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to upload resume');
    }

    return data['resumeText'] as String;
  }

  /// Get LiveKit token for a room
  Future<String> getLivekitToken({
    required String participantName,
    required String roomName,
  }) async {
    final response = await _dio.post(
      '/interview/livekit-token',
      data: {'participantName': participantName, 'roomName': roomName},
    );

    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to get LiveKit token');
    }

    return data['token'] as String;
  }

  /// Get a single session by ID
  Future<InterviewSession> getSession(String sessionId) async {
    final response = await _dio.get('/interview/session/$sessionId');
    final data = response.data as Map<String, dynamic>;

    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to get session');
    }

    return InterviewSession.fromJson(data['session'] as Map<String, dynamic>);
  }

  /// Generate TTS audio for a given text
  Future<String> getTtsAudio(String text, {String voice = 'female'}) async {
    final response = await _dio.post(
      '/interview/tts',
      data: {'text': text, 'voice': voice},
    );

    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to generate TTS');
    }

    return data['audioBase64'] as String;
  }
}
