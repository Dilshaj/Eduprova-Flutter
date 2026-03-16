import 'package:eduprova/core/network/api_client.dart';
import 'package:eduprova/features/home/posts/post.dart';

class PostRepository {
  Future<List<PostModel>> getFeed({String? filter, int page = 1, int limit = 10}) async {
    try {
      final response = await ApiClient.instance.get(
        '/posts/feed',
        queryParameters: {
          'filter': ?filter,
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data as List;
      return [for (var item in data) PostModel.fromMap(item as Map<String, dynamic>)];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> toggleLike(String postId) async {
    try {
      final response = await ApiClient.instance.post('/posts/like/$postId');
      return (response.data as Map<String, dynamic>)['liked'] ?? false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> toggleSave(String postId) async {
    try {
      final response = await ApiClient.instance.post('/posts/save/$postId');
      return (response.data as Map<String, dynamic>)['saved'] ?? false;
    } catch (e) {
      rethrow;
    }
  }
}
