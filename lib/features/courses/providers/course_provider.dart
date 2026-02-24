import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/api_client.dart';
import '../models/course_model.dart';
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

class CoursesNotifier extends StateNotifier<CoursesState> {
  CoursesNotifier() : super(CoursesState()) {
    fetchCourses();
  }

  Future<void> fetchCourses({String? category}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, dynamic>{};
      if (category != null &&
          category != 'All Courses' &&
          category != 'New Trending') {
        queryParams['category'] = category;
      }

      final response = await ApiClient.instance.get(
        '/courses',
        queryParameters: queryParams,
      );
      // await Future.delayed(const Duration(seconds: 300));

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['courses'];
        final courses = data.map((e) => CourseModel.fromJson(e)).toList();
        state = state.copyWith(isLoading: false, courses: courses);
      }
    } on DioException catch (e) {
      log(
        'Fetch Courses Error: type=${e.type}, message=${e.message}, error=${e.error}',
      );
      if (e.response != null) {
        log('Fetch Courses Response Data: ${e.response?.data}');
      }
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

final coursesProvider = StateNotifierProvider<CoursesNotifier, CoursesState>((
  ref,
) {
  return CoursesNotifier();
});
