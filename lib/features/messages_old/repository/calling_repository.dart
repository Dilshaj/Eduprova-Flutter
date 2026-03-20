import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/call_room_model.dart';
import '../models/meeting_model.dart';

class CallingRepository {
  final Dio _client = ApiClient.instance;

  Future<CallRoomModel> createRoom({
    required String type,
    String? conversationId,
    List<String> participantIds = const [],
  }) async {
    final response = await _client.post(
      '/livekit/create-room',
      data: {
        'type': type,
        'conversationId': conversationId,
        'participantIds': participantIds,
      },
    );
    return CallRoomModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<CallRoomModel> getToken(String roomName) async {
    final response = await _client.post(
      '/livekit/token',
      data: {'roomName': roomName},
    );
    return CallRoomModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<List<MeetingModel>> getMeetings() async {
    final response = await _client.get('/meetings');
    final data = response.data as List? ?? const [];
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) MeetingModel.fromJson(item),
    ];
  }

  Future<MeetingModel> createMeeting({
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    List<String> participantIds = const [],
  }) async {
    final response = await _client.post(
      '/meetings',
      data: {
        'title': title,
        'description': description,
        'participantIds': participantIds,
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
      },
    );
    return MeetingModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<MeetingModel> cancelMeeting(String id) async {
    final response = await _client.delete('/meetings/$id');
    return MeetingModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<MeetingModel> updateMeetingStatus(String id, String status) async {
    final response = await _client.patch(
      '/meetings/$id/status',
      data: {'status': status},
    );
    return MeetingModel.fromJson(Map<String, dynamic>.from(response.data));
  }
}
