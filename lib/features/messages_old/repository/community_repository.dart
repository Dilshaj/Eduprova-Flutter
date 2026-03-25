import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/community_model.dart';
import '../models/conversation_model.dart';

class CommunityRepository {
  CommunityRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  final Dio _dio;

  Future<List<CommunityModel>> fetchCommunities({
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _dio.get(
      '/communities',
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data;
    final communities = data is Map<String, dynamic>
        ? (data['communities'] as List? ?? const [])
        : (data as List? ?? const []);

    return communities
        .whereType<Map>()
        .map((item) => CommunityModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<CommunityModel> fetchCommunity(String communityId) async {
    final response = await _dio.get('/communities/$communityId');
    return CommunityModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<CommunityModel> createCommunity({
    required String name,
    String? description,
  }) async {
    final response = await _dio.post(
      '/communities',
      data: {
        'name': name.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      },
    );
    return CommunityModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<ConversationModel> createCommunityGroup({
    required String communityId,
    required String name,
  }) async {
    final response = await _dio.post(
      '/communities/$communityId/groups',
      data: {'name': name.trim()},
    );
    return ConversationModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<ConversationModel> updateConversation(
    String conversationId, {
    String? name,
    String? avatar,
    String? description,
  }) async {
    final response = await _dio.patch(
      '/conversations/$conversationId',
      data: {'name': ?name, 'avatar': ?avatar, 'description': ?description},
    );
    return ConversationModel.fromJson(Map<String, dynamic>.from(response.data));
  }
}
