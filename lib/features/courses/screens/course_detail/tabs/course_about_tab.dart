import 'package:flutter/material.dart';
import 'package:eduprova/features/courses/models/course_detail_model.dart';
import 'package:eduprova/theme.dart';

class CourseAboutTab extends StatelessWidget {
  final CourseDetailModel course;

  const CourseAboutTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            course.description.isNotEmpty
                ? course.description
                : 'No description available for this course.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: themeExt.secondaryText,
            ),
          ),
          const SizedBox(height: 24),

          if (course.learningPoints.isNotEmpty) ...[
            Text(
              'What you\'ll learn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...course.learningPoints.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: themeExt.successColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: themeExt.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],

          if (course.requirements.isNotEmpty) ...[
            Text(
              'Requirements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...course.requirements.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 8, color: themeExt.secondaryText),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: themeExt.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],

          Text(
            'This course includes:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...[
            {
              'icon': Icons.play_circle_outline,
              'text': '${course.duration ?? "On-demand"} video',
            },
            {'icon': Icons.language, 'text': 'Language: ${course.language}'},
            {'icon': Icons.bar_chart, 'text': 'Level: ${course.level}'},
            {'icon': Icons.phone_android, 'text': 'Access on mobile and web'},
            {
              'icon': Icons.workspace_premium_outlined,
              'text': 'Certificate of completion',
            },
          ].map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 18,
                    color: themeExt.iconColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item['text'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeExt.secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
