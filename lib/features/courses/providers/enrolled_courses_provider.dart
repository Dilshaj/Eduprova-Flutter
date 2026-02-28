import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enrolled_course_model.dart';
import '../repositories/course_repository.dart';
import 'dart:developer';

class EnrolledCoursesState {
  final bool isLoading;
  final List<EnrolledCourse> courses;
  final String? error;

  EnrolledCoursesState({
    this.isLoading = false,
    this.courses = const [],
    this.error,
  });

  EnrolledCoursesState copyWith({
    bool? isLoading,
    List<EnrolledCourse>? courses,
    String? error,
  }) {
    return EnrolledCoursesState(
      isLoading: isLoading ?? this.isLoading,
      courses: courses ?? this.courses,
      error: error ?? this.error,
    );
  }
}

class EnrolledCoursesNotifier extends Notifier<EnrolledCoursesState> {
  final _repository = CourseRepository.instance;

  @override
  EnrolledCoursesState build() {
    Future.microtask(() => fetchEnrolledCourses());
    return EnrolledCoursesState();
  }

  Future<void> fetchEnrolledCourses() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _repository.getOrders(),
        _repository.getProgress(),
      ]);

      final orders = results[0] as List<OrderModel>;
      final progressList = results[1] as List<ProgressModel>;

      final progressMap = {for (var p in progressList) p.courseId: p};

      final List<EnrolledCourse> enrolledCourses = [];

      for (var order in orders) {
        if (order.status.toLowerCase() != 'paid') continue;

        for (var item in order.items) {
          final course = item.course;
          if (course == null) continue;

          final progressData = progressMap[course.id];
          final completedLecStrs =
              progressData?.completedLectures.toSet() ?? {};

          // Calculate total modules and completed modules, matching web frontend logic
          final eligibleModules = course.curriculum.where((section) {
            if (section.lectures.isEmpty) return false;
            // Skip if all lectures in section are free previews
            return !section.lectures.every((l) => l.freePreview);
          }).toList();

          final totalModules = eligibleModules.length;
          final completedModules = eligibleModules.where((section) {
            return section.lectures.every(
              (lecture) => completedLecStrs.contains(lecture.id),
            );
          }).length;

          final progressPercent = totalModules > 0
              ? ((completedModules / totalModules) * 100).round()
              : 0;

          String status = 'Fresh';
          if (progressPercent == 100) {
            status = 'Completed';
          } else if (progressPercent > 0) {
            status = 'Ongoing';
          }

          // Find first uncompleted lesson for status text
          String? nextLesson;
          try {
            for (var section in eligibleModules) {
              for (var lecture in section.lectures) {
                if (!completedLecStrs.contains(lecture.id)) {
                  nextLesson = lecture.title;
                  break;
                }
              }
              if (nextLesson != null) break;
            }
          } catch (e) {
            log('Error finding next lesson: $e');
          }

          enrolledCourses.add(
            EnrolledCourse(
              id: course.id,
              title: course.title,
              description: course.description,
              instructor: course.instructor?.fullName ?? 'Unknown Instructor',
              progress: progressPercent,
              totalModules: totalModules,
              completedModules: completedModules,
              image: course.thumbnail ?? '',
              status: status,
              nextLesson: nextLesson,
            ),
          );
        }
      }

      // De-duplicate by course ID and sort by progress descending
      final Map<String, EnrolledCourse> uniqueCourses = {};
      for (var ec in enrolledCourses) {
        if (!uniqueCourses.containsKey(ec.id) ||
            ec.progress > uniqueCourses[ec.id]!.progress) {
          uniqueCourses[ec.id] = ec;
        }
      }

      final sortedCourses = uniqueCourses.values.toList()
        ..sort((a, b) => b.progress.compareTo(a.progress));

      state = state.copyWith(isLoading: false, courses: sortedCourses);
    } catch (e, stack) {
      log('Error fetching enrolled courses: $e', stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load your courses. Please try again.',
      );
    }
  }
}

final enrolledCoursesProvider =
    NotifierProvider<EnrolledCoursesNotifier, EnrolledCoursesState>(
      EnrolledCoursesNotifier.new,
    );
