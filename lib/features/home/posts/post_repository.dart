import 'package:eduprova/core/network/api_client.dart';
import 'package:eduprova/features/home/posts/post.dart';

class PostRepository {
  Future<List<PostModel>> getFeed({String? filter, int page = 1, int limit = 10}) async {
    try {
      final response = await ApiClient.instance.get(
        '/posts/feed',
        queryParameters: {
          'filter': filter,
          'page': page,
          'limit': limit,
        },
      );

      final dynamic rawData = response.data;
      List<dynamic> listData;
      
      if (rawData is List) {
        listData = rawData;
      } else if (rawData is Map && rawData.containsKey('posts')) {
        listData = rawData['posts'] as List;
      } else if (rawData is Map && rawData.containsKey('data')) {
        // Handle case where it might be wrapped in { "data": [...] }
        final dataField = rawData['data'];
        if (dataField is List) {
          listData = dataField;
        } else if (dataField is Map && dataField.containsKey('posts')) {
          listData = dataField['posts'] as List;
        } else {
          listData = [];
        }
      } else {
        listData = [];
      }

      return [for (var item in listData) PostModel.fromMap(item as Map<String, dynamic>)];
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

  Future<bool> toggleFollow(String authorId) async {
    try {
      final response = await ApiClient.instance.post('/user/follow/$authorId');
      return (response.data as Map<String, dynamic>)['isFollowing'] ?? false;
    } catch (e) {
      rethrow;
    }
  }
}
