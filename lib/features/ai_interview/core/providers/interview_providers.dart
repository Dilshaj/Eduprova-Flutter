import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/interview_session_model.dart';
import '../models/interview_analytics_model.dart';
import '../repositories/interview_repository.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final interviewRepositoryProvider = Provider<InterviewRepository>(
  (ref) => InterviewRepository(),
);

// ── History ───────────────────────────────────────────────────────────────────

final interviewHistoryProvider =
    AsyncNotifierProvider<InterviewHistoryNotifier, List<InterviewSession>>(
      InterviewHistoryNotifier.new,
    );

class InterviewHistoryNotifier extends AsyncNotifier<List<InterviewSession>> {
  @override
  Future<List<InterviewSession>> build() {
    return ref.read(interviewRepositoryProvider).getHistory();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(interviewRepositoryProvider).getHistory(),
    );
  }
}

// ── Analytics ─────────────────────────────────────────────────────────────────

final interviewAnalyticsProvider =
    AsyncNotifierProvider<InterviewAnalyticsNotifier, InterviewAnalytics>(
      InterviewAnalyticsNotifier.new,
    );

class InterviewAnalyticsNotifier extends AsyncNotifier<InterviewAnalytics> {
  @override
  Future<InterviewAnalytics> build() {
    return ref.read(interviewRepositoryProvider).getAnalytics();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(interviewRepositoryProvider).getAnalytics(),
    );
  }
}
