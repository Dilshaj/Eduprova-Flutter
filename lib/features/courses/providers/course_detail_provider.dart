import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/course_detail_model.dart';
import '../repositories/course_repository.dart';
import 'dart:developer';

final courseDetailProvider = FutureProvider.family<CourseDetailModel, String>((
  ref,
  id,
) async {
  final authState = ref.watch(authProvider);
  final isAuth = authState.user != null;

  try {
    return await CourseRepository.instance.getCourseDetails(
      id,
      isAuthenticated: isAuth,
    );
  } on DioException catch (e) {
    log('Fetch Course Detail Error: type=${e.type}, message=${e.message}');
    throw Exception(
      e.response?.data?['message'] ?? 'Failed to load course details',
    );
  } catch (e) {
    log('Fetch Course Detail Exception: $e');
    throw Exception(e.toString());
  }
});
