import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/utils/image_cache_manager.dart';
import '../../../core/widgets/app_loaders.dart';
import '../../../core/widgets/app_video_player.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../models/course_detail_model.dart';
import '../providers/course_detail_provider.dart';

class CourseLearningScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseLearningScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseLearningScreen> createState() =>
      _CourseLearningScreenState();
}

class _CourseLearningScreenState extends ConsumerState<CourseLearningScreen> {
  LectureModel? _currentLecture;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));

    return courseAsync.when(
      loading: () =>
          const ShimmerCourseDetail(), // Reuse or create a new shimmer
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
      data: (course) {
        // Auto-select first lecture on load
        if (!_initialized) {
          _initialized = true;
          if (course.curriculum.isNotEmpty &&
              course.curriculum.first.lectures.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _currentLecture = course.curriculum.first.lectures.first;
                });
              }
            });
          }
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          appBar: AppBar(
            title: Text(course.title, style: const TextStyle(fontSize: 16)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          body: Column(
            children: [
              // Dynamic Video Player Section
              Container(
                width: double.infinity,
                color: Colors.black,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildVideoPlayer(course),
                ),
              ),

              // Curriculum List Below Video
              Expanded(child: _buildCurriculumList(isDark, course)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer(CourseDetailModel course) {
    if (_currentLecture == null) {
      return const Center(
        child: Text(
          'Select a lecture to play',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // Play lecture if it has a video source
    if (_currentLecture!.muxPlaybackId != null ||
        _currentLecture!.video != null ||
        _currentLecture!.videoSource?.playbackId != null) {
      // Pass a unique key to force AppVideoPlayer rebuild when lecture changes
      return AppVideoPlayer(
        key: ValueKey(_currentLecture!.id),
        muxPlaybackId:
            _currentLecture!.muxPlaybackId ??
            _currentLecture!.videoSource?.playbackId,
        url: _currentLecture!.video,
        autoPlay: true,
      );
    }

    // Fallback if lecture has no video but course has a promo
    if (course.muxPlaybackId != null ||
        course.video != null ||
        course.videoSource?.playbackId != null) {
      return AppVideoPlayer(
        key: ValueKey('promo_${course.id}'),
        muxPlaybackId: course.muxPlaybackId ?? course.videoSource?.playbackId,
        url: course.video,
        autoPlay: true,
      );
    }

    // Ultimate fallback if no videos exist
    return _buildImage(
      course.thumbnail,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildCurriculumList(bool isDark, CourseDetailModel course) {
    if (course.curriculum.isEmpty) {
      return const Center(child: Text("No curriculum available."));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24, top: 8, left: 16, right: 16),
      itemCount: course.curriculum.length,
      itemBuilder: (context, index) {
        final chapter = course.curriculum[index];
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: index == 0,
            title: Text(
              chapter.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${chapter.lectures.length} lectures'),
            children: chapter.lectures.map((lecture) {
              final isPlaying = _currentLecture?.id == lecture.id;

              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                tileColor: isPlaying
                    ? (isDark
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.blue.shade50)
                    : null,
                leading: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_outline,
                  color: isPlaying ? Colors.blue : Colors.grey,
                ),
                title: Text(
                  lecture.title,
                  style: TextStyle(
                    fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                    color: isPlaying
                        ? Colors.blue
                        : (isDark ? Colors.white : Colors.black),
                  ),
                ),
                subtitle: Text('${(lecture.duration / 60).floor()} mins'),
                onTap: () {
                  setState(() {
                    _currentLecture = lecture;
                  });
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildImage(
    String? url, {
    double? width,
    double? height,
    Widget? placeholder,
  }) {
    if (url == null || url.isEmpty) {
      return placeholder ?? const Icon(Icons.image, color: Colors.grey);
    }

    if (url.startsWith('data:')) {
      try {
        final base64String = url.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              placeholder ?? const Icon(Icons.broken_image, color: Colors.grey),
        );
      } catch (e) {
        return placeholder ??
            const Icon(Icons.broken_image, color: Colors.grey);
      }
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      cacheManager: CacheManagers.avatarCacheManager,
      placeholder: (context, url) => placeholder ?? const ShimmerImageLoader(),
      errorWidget: (context, url, error) =>
          placeholder ?? const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}
