import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course_detail_model.dart';
import '../repositories/course_repository.dart';
import 'dart:developer';

/// Provides public course details — used by [CourseDetailScreen].
final courseDetailProvider = FutureProvider.family<CourseDetailModel, String>((
  ref,
  id,
) async {
  try {
    return await CourseRepository.instance.getCourseDetails(id);
  } catch (e) {
    log('Fetch Course Detail Exception: $e');
    rethrow;
  }
});

/// Provides authenticated learning content — used by [CourseLearningScreen].
/// Calls GET /courses/{id}/learn; only works when user owns the course.
final courseLearnProvider = FutureProvider.family<CourseDetailModel, String>((
  ref,
  id,
) async {
  try {
    return await CourseRepository.instance.getCourseLearn(id);
  } catch (e) {
    log('Fetch Course Learn Exception: $e');
    rethrow;
  }
});
