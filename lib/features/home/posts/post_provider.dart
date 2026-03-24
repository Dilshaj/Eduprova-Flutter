import 'package:eduprova/features/home/posts/post.dart';
import 'package:eduprova/features/home/posts/post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) => PostRepository());

final postsProvider = NotifierProvider<PostsNotifier, AsyncValue<List<PostModel>>>(PostsNotifier.new);

class PostsNotifier extends Notifier<AsyncValue<List<PostModel>>> {
  @override
  AsyncValue<List<PostModel>> build() {
    _fetchPosts();
    return const AsyncValue.loading();
  }

  Future<void> _fetchPosts() async {
    state = const AsyncValue.loading();
    try {
      final posts = await ref.read(postRepositoryProvider).getFeed();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    await _fetchPosts();
  }

  Future<void> toggleLike(String postId) async {
    try {
      final liked = await ref.read(postRepositoryProvider).toggleLike(postId);
      
      state.whenData((posts) {
        state = AsyncValue.data([
          for (var post in posts)
            if (post.id == postId)
              post.copyWith(
                likeCount: liked ? post.likeCount + 1 : post.likeCount - 1,
                isLiked: liked,
              )
            else
              post
        ]);
      });
    } catch (e) {
      // Handle error quietly or show toast
    }
  }
}
