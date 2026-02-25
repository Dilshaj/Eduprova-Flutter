import 'package:flutter/material.dart';
import 'package:eduprova/features/courses/models/course_detail_model.dart';
import 'package:eduprova/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CourseInstructorTab extends StatelessWidget {
  final CourseDetailModel course;

  const CourseInstructorTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    if (course.instructor == null) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text("No instructor information available."),
      );
    }

    final instructor = course.instructor!;
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  image:
                      instructor.avatar != null && instructor.avatar!.isNotEmpty
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(instructor.avatar!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: instructor.avatar?.isEmpty ?? true
                    ? Alignment.center
                    : null,
                child: instructor.avatar?.isEmpty ?? true
                    ? Text(
                        instructor.firstName.isNotEmpty
                            ? instructor.firstName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instructor.fullName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Instructor',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (instructor.bio != null && instructor.bio!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'About the Instructor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              instructor.bio!,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: themeExt.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
