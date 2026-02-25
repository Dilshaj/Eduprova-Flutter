import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course_model.dart';
import '../repositories/course_repository.dart';
import 'dart:developer';

class CoursesState {
  final bool isLoading;
  final List<CourseModel> courses;
  final String? error;

  CoursesState({this.isLoading = false, this.courses = const [], this.error});

  CoursesState copyWith({
    bool? isLoading,
    List<CourseModel>? courses,
    String? error,
    bool clearError = false,
  }) {
    return CoursesState(
      isLoading: isLoading ?? this.isLoading,
      courses: courses ?? this.courses,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CoursesNotifier extends Notifier<CoursesState> {
  final _repository = CourseRepository.instance;

  @override
  CoursesState build() {
    // Initial fetch
    Future.microtask(() => fetchCourses());
    return .new();
  }

  Future<void> fetchCourses({String? category}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final courses = await _repository.getCourses(category: category);
      state = state.copyWith(isLoading: false, courses: courses);
    } on DioException catch (e) {
      log('Fetch Courses Error: ${e.response?.data}');
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['message'] ?? 'Failed to load courses',
      );
    } catch (e) {
      log('Fetch Courses Exception: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final coursesProvider = NotifierProvider<CoursesNotifier, CoursesState>(
  CoursesNotifier.new,
);
