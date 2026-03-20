import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/search_user_model.dart';

class ParticipantSearchRepository {
  final Dio _client = ApiClient.instance;

  Future<List<SearchUserModel>> searchUsers(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return const [];

    final response = await _client.get(
      '/users/search',
      queryParameters: {'q': clean},
    );
    final data = response.data as List? ?? const [];
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) SearchUserModel.fromJson(item),
    ];
  }
}
