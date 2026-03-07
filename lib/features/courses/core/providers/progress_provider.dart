import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enrolled_course_model.dart';
import '../repositories/progress_repository.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

class ProgressState {
  final bool isLoading;
  final ProgressModel? data;

  ProgressState({this.isLoading = false, this.data});

  ProgressState copyWith({bool? isLoading, ProgressModel? data}) {
    return ProgressState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
    );
  }
}

final allCourseProgressProvider =
    NotifierProvider<AllCourseProgressNotifier, Map<String, ProgressState>>(
      AllCourseProgressNotifier.new,
    );

final courseProgressProvider = Provider.family<ProgressState, String>((
  ref,
  courseId,
) {
  final map = ref.watch(allCourseProgressProvider);
  if (!map.containsKey(courseId)) {
    // Fire off async initialization once
    Future.microtask(
      () => ref.read(allCourseProgressProvider.notifier).refresh(courseId),
    );
    return ProgressState(isLoading: true);
  }
  return map[courseId]!;
});

class AllCourseProgressNotifier extends Notifier<Map<String, ProgressState>> {
  late ProgressRepository _repository;

  @override
  Map<String, ProgressState> build() {
    _repository = ref.read(progressRepositoryProvider);
    return {};
  }

  Future<void> refresh(String courseId) async {
    state = {
      ...state,
      courseId:
          state[courseId]?.copyWith(isLoading: true) ??
          ProgressState(isLoading: true),
    };
    final data = await _repository.getProgress(courseId);
    state = {...state, courseId: ProgressState(isLoading: false, data: data)};
  }

  Future<void> markLectureCompleted(String courseId, String lectureId) async {
    final currentState = state[courseId];
    if (currentState == null || currentState.data == null) return;

    final currentProgress = currentState.data!;

    // Optimistic update
    if (!currentProgress.completedLectures.contains(lectureId)) {
      final updatedLectures = [...currentProgress.completedLectures, lectureId];
      state = {
        ...state,
        courseId: currentState.copyWith(
          data: ProgressModel(
            id: currentProgress.id,
            userId: currentProgress.userId,
            courseId: currentProgress.courseId,
            completedLectures: updatedLectures,
            percentComplete: currentProgress.percentComplete,
            lastAccessedLectureId: lectureId,
            videoWatchTimes: currentProgress.videoWatchTimes,
          ),
        ),
      };
    }

    // Call backend
    final updatedProgress = await _repository.updateProgress(
      courseId,
      lectureId,
    );
    if (updatedProgress != null) {
      state = {
        ...state,
        courseId: currentState.copyWith(data: updatedProgress),
      };
    }
  }

  Future<void> updateWatchTime(
    String courseId,
    String lectureId,
    num watchTime,
  ) async {
    final currentState = state[courseId];
    if (currentState == null || currentState.data == null) return;

    final currentProgress = currentState.data!;

    // Optimistic update
    final newWatchTimes = Map<String, num>.from(
      currentProgress.videoWatchTimes,
    );
    newWatchTimes[lectureId] = watchTime;

    state = {
      ...state,
      courseId: currentState.copyWith(
        data: ProgressModel(
          id: currentProgress.id,
          userId: currentProgress.userId,
          courseId: currentProgress.courseId,
          completedLectures: currentProgress.completedLectures,
          percentComplete: currentProgress.percentComplete,
          lastAccessedLectureId: lectureId,
          videoWatchTimes: newWatchTimes,
        ),
      ),
    };

    // Call backend
    final updatedProgress = await _repository.updateWatchTime(
      courseId,
      lectureId,
      watchTime,
    );
    if (updatedProgress != null) {
      state = {
        ...state,
        courseId: currentState.copyWith(data: updatedProgress),
      };
    }
  }
}
