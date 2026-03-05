import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doubt_model.dart';
import '../repositories/doubts_repository.dart';

final doubtsRepositoryProvider = Provider<DoubtsRepository>((ref) {
  return DoubtsRepository();
});

class DoubtsState {
  final bool isLoading;
  final List<DoubtModel> doubts;
  final String? error;

  DoubtsState({this.isLoading = false, this.doubts = const [], this.error});

  DoubtsState copyWith({
    bool? isLoading,
    List<DoubtModel>? doubts,
    String? error,
  }) {
    return DoubtsState(
      isLoading: isLoading ?? this.isLoading,
      doubts: doubts ?? this.doubts,
      error: error ?? this.error,
    );
  }
}

// Map from courseId to state
final allDoubtsProvider =
    NotifierProvider<AllDoubtsNotifier, Map<String, DoubtsState>>(
      AllDoubtsNotifier.new,
    );

final doubtsProvider = Provider.family<DoubtsState, String>((ref, courseId) {
  final map = ref.watch(allDoubtsProvider);
  if (!map.containsKey(courseId)) {
    // Fire off async initialization once
    Future.microtask(
      () => ref.read(allDoubtsProvider.notifier).refresh(courseId),
    );
    return DoubtsState(isLoading: true);
  }
  return map[courseId]!;
});

class AllDoubtsNotifier extends Notifier<Map<String, DoubtsState>> {
  late DoubtsRepository _repository;

  @override
  Map<String, DoubtsState> build() {
    _repository = ref.read(doubtsRepositoryProvider);
    return {};
  }

  Future<void> refresh(
    String courseId, {
    String? lectureId,
    String? search,
  }) async {
    state = {
      ...state,
      courseId:
          state[courseId]?.copyWith(isLoading: true, error: null) ??
          DoubtsState(isLoading: true),
    };

    try {
      final doubts = await _repository.getDoubts(
        courseId: courseId,
        lectureId: lectureId,
        search: search,
      );

      state = {
        ...state,
        courseId: DoubtsState(isLoading: false, doubts: doubts),
      };
    } catch (e) {
      state = {
        ...state,
        courseId:
            state[courseId]?.copyWith(
              isLoading: false,
              error: 'Failed to fetch doubts.',
            ) ??
            DoubtsState(error: 'Failed to fetch doubts.'),
      };
    }
  }

  Future<bool> createDoubt({
    required String courseId,
    required String lectureId,
    required String title,
    required String content,
  }) async {
    final newDoubt = await _repository.createDoubt(
      courseId: courseId,
      lectureId: lectureId,
      title: title,
      content: content,
    );

    if (newDoubt != null) {
      final currentState = state[courseId] ?? DoubtsState();
      state = {
        ...state,
        courseId: currentState.copyWith(
          doubts: [newDoubt, ...currentState.doubts],
        ),
      };
      return true;
    }
    return false;
  }

  Future<bool> replyToDoubt(
    String courseId,
    String doubtId,
    String content,
  ) async {
    final currentState = state[courseId];
    if (currentState == null) return false;

    final updatedDoubt = await _repository.addReply(
      doubtId: doubtId,
      content: content,
    );

    if (updatedDoubt != null) {
      final updatedDoubts = currentState.doubts.map((d) {
        return d.id == doubtId ? updatedDoubt : d;
      }).toList();

      state = {
        ...state,
        courseId: currentState.copyWith(doubts: updatedDoubts),
      };
      return true;
    }
    return false;
  }
}
