import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/course_review_repository.dart';
import '../models/review_model.dart';
import 'package:flutter/foundation.dart';

@immutable
class CourseReviewsState {
  final List<ReviewModel> reviews;
  final bool isLoading;
  final bool isLoadMore;
  final bool hasMore;
  final int page;
  final int total;
  final bool userHasReviewed;
  final String? error;

  const CourseReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.isLoadMore = false,
    this.hasMore = false,
    this.page = 1,
    this.total = 0,
    this.userHasReviewed = false,
    this.error,
  });

  CourseReviewsState copyWith({
    List<ReviewModel>? reviews,
    bool? isLoading,
    bool? isLoadMore,
    bool? hasMore,
    int? page,
    int? total,
    bool? userHasReviewed,
    String? error,
    bool clearError = false,
  }) {
    return CourseReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      isLoadMore: isLoadMore ?? this.isLoadMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      total: total ?? this.total,
      userHasReviewed: userHasReviewed ?? this.userHasReviewed,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final courseReviewRepositoryProvider = Provider<CourseReviewRepository>((ref) {
  return CourseReviewRepository();
});

final allCourseReviewsProvider =
    NotifierProvider<AllCourseReviewsNotifier, Map<String, CourseReviewsState>>(
      AllCourseReviewsNotifier.new,
    );

final courseReviewsProvider = Provider.family<CourseReviewsState, String>((
  ref,
  courseId,
) {
  final map = ref.watch(allCourseReviewsProvider);
  if (!map.containsKey(courseId)) {
    // Trigger initial fetch
    Future.microtask(
      () => ref.read(allCourseReviewsProvider.notifier).fetchReviews(courseId),
    );
    return const CourseReviewsState(isLoading: true);
  }
  return map[courseId]!;
});

class AllCourseReviewsNotifier
    extends Notifier<Map<String, CourseReviewsState>> {
  late CourseReviewRepository _repository;

  @override
  Map<String, CourseReviewsState> build() {
    _repository = ref.read(courseReviewRepositoryProvider);
    return {};
  }

  Future<void> fetchReviews(String courseId) async {
    final currentState = state[courseId] ?? const CourseReviewsState();
    state = {
      ...state,
      courseId: currentState.copyWith(isLoading: true, clearError: true),
    };

    try {
      final response = await _repository.getReviews(
        courseId,
        page: 1,
        limit: 10,
      );

      state = {
        ...state,
        courseId: CourseReviewsState(
          reviews: response.reviews,
          total: response.total,
          page: response.page,
          hasMore: response.page < response.pages,
          userHasReviewed: response.userHasReviewed,
          isLoading: false,
        ),
      };
    } catch (e) {
      state = {
        ...state,
        courseId: currentState.copyWith(isLoading: false, error: e.toString()),
      };
    }
  }

  Future<void> loadMore(String courseId) async {
    final currentState = state[courseId];
    if (currentState == null ||
        currentState.isLoading ||
        currentState.isLoadMore ||
        !currentState.hasMore) {
      return;
    }

    state = {
      ...state,
      courseId: currentState.copyWith(isLoadMore: true, clearError: true),
    };

    try {
      final nextPage = currentState.page + 1;
      final response = await _repository.getReviews(
        courseId,
        page: nextPage,
        limit: 10,
      );

      state = {
        ...state,
        courseId: currentState.copyWith(
          reviews: [...currentState.reviews, ...response.reviews],
          total: response.total,
          page: response.page,
          hasMore: response.page < response.pages,
          isLoadMore: false,
        ),
      };
    } catch (e) {
      state = {
        ...state,
        courseId: currentState.copyWith(isLoadMore: false, error: e.toString()),
      };
    }
  }

  Future<bool> postReview(String courseId, int rating, String comment) async {
    final currentState = state[courseId] ?? const CourseReviewsState();
    state = {
      ...state,
      courseId: currentState.copyWith(isLoading: true, clearError: true),
    };

    try {
      final newReview = await _repository.postReview(courseId, rating, comment);

      state = {
        ...state,
        courseId: currentState.copyWith(
          reviews: [newReview, ...currentState.reviews],
          total: currentState.total + 1,
          userHasReviewed: true,
          isLoading: false,
        ),
      };
      return true;
    } catch (e) {
      state = {
        ...state,
        courseId: currentState.copyWith(isLoading: false, error: e.toString()),
      };
      return false;
    }
  }

  Future<void> deleteReview(String courseId, String reviewId) async {
    final currentState = state[courseId];
    if (currentState == null) return;

    try {
      await _repository.deleteReview(courseId, reviewId);

      state = {
        ...state,
        courseId: currentState.copyWith(
          reviews: currentState.reviews.where((r) => r.id != reviewId).toList(),
          total: currentState.total > 0 ? currentState.total - 1 : 0,
          userHasReviewed: false,
        ),
      };
    } catch (e) {
      // Handle error if needed
    }
  }
}
