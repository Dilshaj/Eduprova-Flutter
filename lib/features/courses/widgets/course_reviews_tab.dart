import 'package:flutter/material.dart';
import 'package:eduprova/features/courses/models/course_detail_model.dart';
import 'package:eduprova/theme.dart';

class CourseReviewsTab extends StatelessWidget {
  final CourseDetailModel course;

  const CourseReviewsTab({super.key, required this.course});

  Widget _buildReviewItem(
    String initials,
    String name,
    String time,
    int rating,
    String detail,
    AppDesignExtension themeExt,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: themeExt.avatarBackgroundColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: themeExt.secondaryText,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: themeExt.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 10,
                    color: i < rating
                        ? themeExt.warningColor
                        : Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: themeExt.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: themeExt.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      course.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (_) => const Icon(
                          Icons.star,
                          size: 12,
                          color: Color(0xFFFFB800),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'COURSE RATING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: themeExt.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                // Dummy distribution until API provides review distributions
                Expanded(
                  child: Column(
                    children: [85, 12, 3, 3, 3].asMap().entries.map((entry) {
                      int idx = entry.key;
                      int val = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 12,
                              child: Text(
                                '${5 - idx}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: themeExt.secondaryText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: themeExt.progressBarBackgroundColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: val / 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: themeExt.warningColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 24,
                              child: Text(
                                '$val%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: themeExt.secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Hardcoded reviews since backend doesn't seem to pass real reviews yet
          _buildReviewItem(
            'RS',
            'Rahul Sharma',
            '2 days ago',
            5,
            'The best course on this topic! The explanation is so clear and the projects are very practical.',
            themeExt,
            colorScheme,
          ),
          _buildReviewItem(
            'SP',
            'Sneha Patel',
            '1 week ago',
            4,
            'Great content. I especially loved the coding exercises. Would have liked more advanced topics.',
            themeExt,
            colorScheme,
          ),
        ],
      ),
    );
  }
}
