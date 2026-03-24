import 'package:eduprova/core/network/api_client.dart';
import 'package:eduprova/features/home/posts/comment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Repository ───────────────────────────────────────────────────────────────

class CommentRepository {
  /// Fetch comments for a given post
  Future<List<CommentModel>> getComments(String postId,
      {int page = 1, int limit = 20}) async {
    try {
      final response = await ApiClient.instance.get(
        '/posts/$postId/comments',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data as List;
      return [
        for (var item in data) CommentModel.fromMap(item as Map<String, dynamic>)
      ];
    } catch (_) {
      return [];
    }
  }

  /// Add a comment to a post
  Future<CommentModel?> addComment(String postId, String text) async {
    try {
      final response = await ApiClient.instance.post(
        '/posts/$postId/comments',
        data: {'text': text},
      );
      return CommentModel.fromMap(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Toggle like on a comment
  Future<bool> toggleCommentLike(String postId, String commentId) async {
    try {
      final response = await ApiClient.instance
          .post('/posts/$postId/comments/$commentId/like');
      return (response.data as Map<String, dynamic>)['liked'] ?? false;
    } catch (_) {
      return false;
    }
  }
}

// ─── State ────────────────────────────────────────────────────────────────────

class CommentsState {
  final List<CommentModel> comments;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  CommentsState copyWith({
    List<CommentModel>? comments,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) =>
      CommentsState(
        comments: comments ?? this.comments,
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: clearError ? null : (error ?? this.error),
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

final allCommentsProvider =
    NotifierProvider<AllCommentsNotifier, Map<String, CommentsState>>(
  AllCommentsNotifier.new,
);

class AllCommentsNotifier extends Notifier<Map<String, CommentsState>> {
  late CommentRepository _repo;

  @override
  Map<String, CommentsState> build() {
    _repo = ref.read(commentRepositoryProvider);
    return {};
  }

  Future<void> load(String postId) async {
    final current = state[postId] ?? const CommentsState();
    state = {
      ...state,
      postId: current.copyWith(isLoading: true, clearError: true),
    };

    final comments = await _repo.getComments(postId);
    state = {
      ...state,
      postId: current.copyWith(comments: comments, isLoading: false),
    };
  }

  Future<void> addComment(String postId, String text) async {
    if (text.trim().isEmpty) return;
    final current = state[postId] ?? const CommentsState();

    final optimistic = CommentModel(
      id: 'optimistic_${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'You',
      authorAvatar: 'assets/avatars/1.png',
      text: text.trim(),
      createdAt: DateTime.now(),
    );

    state = {
      ...state,
      postId: current.copyWith(
        comments: [optimistic, ...current.comments],
        isSubmitting: true,
      ),
    };

    final result = await _repo.addComment(postId, text.trim());
    final postState = state[postId]!;

    if (result != null) {
      state = {
        ...state,
        postId: postState.copyWith(
          comments: [
            result,
            ...postState.comments.where((c) => c.id != optimistic.id),
          ],
          isSubmitting: false,
        ),
      };
    } else {
      state = {
        ...state,
        postId: postState.copyWith(
          comments:
              postState.comments.where((c) => c.id != optimistic.id).toList(),
          isSubmitting: false,
          error: 'Failed to post comment.',
        ),
      };
    }
  }

  Future<void> toggleLike(String postId, String commentId) async {
    final current = state[postId];
    if (current == null) return;

    state = {
      ...state,
      postId: current.copyWith(
        comments: [
          for (var c in current.comments)
            if (c.id == commentId)
              CommentModel(
                id: c.id,
                authorName: c.authorName,
                authorAvatar: c.authorAvatar,
                text: c.text,
                createdAt: c.createdAt,
                likeCount: c.isLiked ? c.likeCount - 1 : c.likeCount + 1,
                isLiked: !c.isLiked,
              )
            else
              c
        ],
      ),
    };
    await _repo.toggleCommentLike(postId, commentId);
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final commentRepositoryProvider =
    Provider<CommentRepository>((ref) => CommentRepository());

final commentsProvider = Provider.family<CommentsState, String>((ref, postId) {
  final map = ref.watch(allCommentsProvider);
  if (!map.containsKey(postId)) {
    Future.microtask(() => ref.read(allCommentsProvider.notifier).load(postId));
    return const CommentsState(isLoading: true);
  }
  return map[postId]!;
});
