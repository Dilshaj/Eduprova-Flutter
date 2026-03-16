import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/resume_repository.dart';
import '../models/resume_data.dart';
import '../models/resume_summary.dart';
import 'package:uuid/uuid.dart';

final resumeRepositoryProvider = Provider((ref) => ResumeRepository());

final resumeListProvider =
    AsyncNotifierProvider<ResumeListNotifier, List<ResumeSummary>>(
      ResumeListNotifier.new,
    );

class ResumeListNotifier extends AsyncNotifier<List<ResumeSummary>> {
  late ResumeRepository _repository;

  @override
  Future<List<ResumeSummary>> build() async {
    _repository = ref.watch(resumeRepositoryProvider);
    return _fetchResumes();
  }

  Future<List<ResumeSummary>> _fetchResumes() async {
    try {
      return await _repository.getResumes();
    } catch (e) {
      throw Exception('Failed to fetch resumes: $e');
    }
  }

  Future<void> loadResumes() async {
    state = const AsyncValue.loading();
    try {
      final resumes = await _fetchResumes();
      state = AsyncValue.data(resumes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String> createNewResume(String title) async {
    try {
      final slug = const Uuid().v4();
      final data = ResumeData.empty();
      final response = await _repository.createResume(title, slug, data);
      final newResumeId = response['_id'] as String;

      // Refresh the list
      await loadResumes();
      return newResumeId;
    } catch (e) {
      throw Exception('Failed to create resume: $e');
    }
  }

  Future<void> deleteResume(String id) async {
    try {
      await _repository.deleteResume(id);

      // update state optimistically
      if (state.hasValue) {
        state = AsyncValue.data(state.value!.where((r) => r.id != id).toList());
      }
    } catch (e) {
      // Refresh to ensure sync if delete failed
      await loadResumes();
      throw Exception('Failed to delete resume: $e');
    }
  }
}
