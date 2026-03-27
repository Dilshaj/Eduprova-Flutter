import 'package:eduprova/features/home/posts/post.dart';
import 'package:eduprova/features/home/posts/post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

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
      debugPrint('Fetching posts...');
      // Temporarily forcing dummy posts to troubleshoot blank screen
      state = AsyncValue.data(_getDummyPosts());
      debugPrint('State set to data with ${_getDummyPosts().length} dummy posts');
      
      final posts = await ref.read(postRepositoryProvider).getFeed();
      if (posts.isEmpty) {
        state = AsyncValue.data(_getDummyPosts());
      } else {
        state = AsyncValue.data(posts);
      }
    } catch (e, st) {
      debugPrint('Error fetching posts: $e');
      state = AsyncError(e, st);
    }
  }

  List<PostModel> _getDummyPosts() {
    return [
      PostModel(
        id: 'dummy_1',
        name: 'Alex Rivera',
        designation: 'Senior UI/UX Designer',
        timeAgo: '2h ago',
        content: 'Just finished the new design system for EduProva! 🚀\n\nReally excited about the new glassmorphism elements and the overall accessibility improvements. What do you guys think?',
        authorAvatar: 'assets/avatars/1.png',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likeCount: 42,
        commentCount: 12,
        isLiked: true,
        imageUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=1000',
        hashtags: ['Design', 'UX', 'MobileApp'],
      ),
      PostModel(
        id: 'dummy_2',
        name: 'Sarah Chen',
        designation: 'Product Manager',
        timeAgo: '5h ago',
        content: 'Our latest feature update is live! 🌟\nCheck out the new collaborative notes and the improved course progress tracker.',
        authorAvatar: 'assets/avatars/2.png',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likeCount: 89,
        commentCount: 24,
        isLiked: false,
        imageUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=1000',
        hashtags: ['Productivity', 'Elearning', 'Update'],
      ),
      PostModel(
        id: 'dummy_3',
        name: 'Marcus Thorne',
        designation: 'Web Developer',
        timeAgo: '1d ago',
        content: 'Exploring the new PDF preview integration. Smooth as butter! 😍',
        authorAvatar: 'assets/avatars/3.png',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likeCount: 156,
        commentCount: 38,
        isLiked: false,
        pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        hashtags: ['Flutter', 'Development', 'CleanCode'],
      ),
    ];
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

  Future<void> toggleSave(String postId) async {
    try {
      final saved = await ref.read(postRepositoryProvider).toggleSave(postId);
      state.whenData((posts) {
        state = AsyncValue.data([
          for (var post in posts)
            if (post.id == postId) post.copyWith(isSaved: saved) else post
        ]);
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleFollow(String postId) async {
    // Assuming authorId can be derived or the API handles postId to follow author
    // Based on the code in post.dart, it passes post.id to toggleFollow. 
    // Usually we follow the author of the post.
    try {
      // Implementation depends on API, but let's match repository call
      final followed = await ref.read(postRepositoryProvider).toggleFollow(postId);
      state.whenData((posts) {
        state = AsyncValue.data([
          for (var post in posts)
            if (post.id == postId) post.copyWith(isFollowingAuthor: followed) else post
        ]);
      });
    } catch (e) {
      // Handle error
    }
  }
}
