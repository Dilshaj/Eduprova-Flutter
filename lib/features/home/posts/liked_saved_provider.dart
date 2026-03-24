import 'package:eduprova/core/network/api_client.dart';
import 'package:eduprova/features/home/posts/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Repository ───────────────────────────────────────────────────────────────

class LikedSavedRepository {
  /// Fetch posts liked by the current user
  Future<List<PostModel>> getLikedPosts({int page = 1, int limit = 10}) async {
    try {
      final response = await ApiClient.instance.get(
        '/posts/liked',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data as List;
      return [
        for (var item in data) PostModel.fromMap(item as Map<String, dynamic>)
      ];
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch posts saved/bookmarked by the current user
  Future<List<PostModel>> getSavedPosts({int page = 1, int limit = 10}) async {
    try {
      final response = await ApiClient.instance.get(
        '/posts/saved',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data as List;
      return [
        for (var item in data) PostModel.fromMap(item as Map<String, dynamic>)
      ];
    } catch (e) {
      rethrow;
    }
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final likedSavedRepositoryProvider =
    Provider<LikedSavedRepository>((ref) => LikedSavedRepository());

/// AsyncNotifier for liked posts — supports refresh via ref.invalidate(likedPostsProvider)
final likedPostsProvider =
    AsyncNotifierProvider<LikedPostsNotifier, List<PostModel>>(
  LikedPostsNotifier.new,
);

class LikedPostsNotifier extends AsyncNotifier<List<PostModel>> {
  @override
  Future<List<PostModel>> build() async {
    return ref.read(likedSavedRepositoryProvider).getLikedPosts();
  }
}

/// AsyncNotifier for saved posts — supports refresh via ref.invalidate(savedPostsProvider)
final savedPostsProvider =
    AsyncNotifierProvider<SavedPostsNotifier, List<PostModel>>(
  SavedPostsNotifier.new,
);

class SavedPostsNotifier extends AsyncNotifier<List<PostModel>> {
  @override
  Future<List<PostModel>> build() async {
    return ref.read(likedSavedRepositoryProvider).getSavedPosts();
  }
}
