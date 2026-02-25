import 'package:eduprova/features/courses/screens/course_card2.dart';
import 'package:flutter/material.dart';
import 'package:eduprova/features/courses/models/course_model.dart';
import 'package:go_router/go_router.dart';
import 'course_card.dart';

class HorizontalCourseRow extends StatelessWidget {
  final String title;
  final List<CourseModel> courses;
  final String? categoryId;

  const HorizontalCourseRow({
    super.key,
    required this.title,
    required this.courses,
    this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final displayCourses = courses.take(6).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 8),
        child: Row(
          children: [
            ...displayCourses.map((course) {
              return CourseCard(course: course);
            }),
            InkWell(
              onTap: () {
                // TODO: Update route if needed
                context.push('/coursesSeeAll');
              },
              child: Container(
                width: 100,
                height: 270,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF0066FF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'See all',
                      style: TextStyle(
                        color: Color(0xFF0066FF),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
