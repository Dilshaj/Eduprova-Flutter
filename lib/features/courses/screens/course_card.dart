import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduprova/core/utils/image_cache_manager.dart';
import 'package:eduprova/core/widgets/app_loaders.dart';
import 'package:eduprova/features/courses/core/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final bool isDark;

  const CourseCard({super.key, required this.course, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/course/${course.id}');
      },
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF232323) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumb
            Container(
              height: 140,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: Color(0xFF333333),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildThumbnail(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course.instructor?.fullName ?? 'Unknown Instructor',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        course.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${course.studentCount} students)',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black45,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹${course.discountedPrice ?? course.originalPrice}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF4A8BFF),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (course.discountedPrice != null)
                        Text(
                          '₹${course.originalPrice}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (course.thumbnail == null || course.thumbnail!.isEmpty) {
      return const Center(
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedImage01,
          color: Colors.white54,
          size: 40,
        ),
      );
    }
    if (course.thumbnail == 'l') {
      return const ShimmerImageLoader();
    }

    return CachedNetworkImage(
      imageUrl: course.thumbnail!,
      fit: BoxFit.cover,
      cacheManager: CacheManagers.courseThumbnailCacheManager,
      errorWidget: (context, url, error) {
        debugPrint(
          'Error loading cached network thumbnail: ${course.thumbnail}',
        );
        return _buildErrorPlaceholder();
      },
      placeholder: (context, url) => const ShimmerImageLoader(),
    );
  }

  Widget _buildErrorPlaceholder() {
    return const Center(
      child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
    );
  }
}
