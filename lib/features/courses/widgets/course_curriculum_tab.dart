import 'package:flutter/material.dart';
import 'package:eduprova/features/courses/models/course_detail_model.dart';
import 'package:eduprova/theme.dart';

class CourseCurriculumTab extends StatefulWidget {
  final CourseDetailModel course;

  const CourseCurriculumTab({super.key, required this.course});

  @override
  State<CourseCurriculumTab> createState() => _CourseCurriculumTabState();
}

class _CourseCurriculumTabState extends State<CourseCurriculumTab> {
  // Store expanded state for each chapter
  final Set<String> _expandedChapters = {};

  AppDesignExtension get themeExt =>
      Theme.of(context).extension<AppDesignExtension>()!;
  ColorScheme get colorScheme => Theme.of(context).colorScheme;

  String _formatDuration(num minutes) {
    if (minutes < 60) return '${minutes.toInt()}m';
    int hours = minutes ~/ 60;
    int remainingMins = (minutes % 60).toInt();
    return remainingMins > 0 ? '${hours}h ${remainingMins}m' : '${hours}h';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.course.curriculum.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text("Curriculum not available yet."),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.course.curriculum.map((chapter) {
            final isExpanded = _expandedChapters.contains(chapter.id);
            final lectureCount = chapter.lectures.length;
            final durationText = chapter.duration ?? '';

            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedChapters.remove(chapter.id);
                      } else {
                        _expandedChapters.add(chapter.id);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: themeExt.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: themeExt.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: themeExt.shadowColor,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chapter.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$lectureCount Lessons ${durationText.isNotEmpty ? "• $durationText" : ""}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: themeExt.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 20,
                          color: themeExt.secondaryText,
                        ),
                      ],
                    ),
                  ),
                ),

                // Expanded Content
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ).copyWith(bottom: 12),
                    child: Column(
                      children: chapter.lectures.map((lecture) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12, left: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  lecture.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: themeExt.secondaryText,
                                  ),
                                ),
                              ),
                              if (lecture.freePreview)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Preview',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Text(
                                _formatDuration(lecture.duration),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: themeExt.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            );
          }),

          // Bonus or info block
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: themeExt.purpleAccentColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: themeExt.purpleAccentTextColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Includes Quizzes & Hands-on Exercises',
                  style: TextStyle(
                    color: themeExt.purpleAccentTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
