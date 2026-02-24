import 'package:eduprova/features/courses/models/course_model.dart';
import 'package:eduprova/features/courses/screens/course_card.dart';
import 'package:eduprova/features/courses/screens/courses_screen.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

// class ShimmerLoading extends StatelessWidget {
//   final double width;
//   final double height;
//   final double borderRadius;

//   const ShimmerLoading({
//     super.key,
//     required this.width,
//     required this.height,
//     this.borderRadius = 8.0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Skeletonizer(
//       enabled: true,
//       child: Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(borderRadius),
//         ),
//       ),
//     );
//   }
// }

final _course = [
  CourseModel(
    id: '1',
    title: 'abcdefghijk',
    subtitle: 'asdefghijklmnopqrst',
    category: 'test',
    level: 'test',
    language: 'test',
    description: 'test',
    originalPrice: 100,
    rating: 100,
    numReviews: 100,
    studentCount: 100,
    thumbnail: 'l',
  ),
  CourseModel(
    id: '2',
    title: 'abcdefghijklmnop',
    subtitle: 'asdfgh',
    category: 'testss',
    level: 'test',
    language: 'test',
    description: 'test',
    originalPrice: 100,
    rating: 100,
    numReviews: 100,
    studentCount: 100,
    thumbnail: 'l',
  ),
  CourseModel(
    id: '2',
    title: 'abcdefghijklmnop',
    subtitle: 'asdfgh',
    category: 'testss',
    level: 'test',
    language: 'test',
    description: 'test',
    originalPrice: 100,
    rating: 100,
    numReviews: 100,
    studentCount: 100,
    thumbnail: 'l',
  ),
];
final courses = List.generate(4, (index) => _course[0]);

class ShimmerCoursesScreen extends StatelessWidget {
  const ShimmerCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Skeletonizer(
        enabled: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Featured Courses', style: TextStyle(fontSize: 20)),
                Text('Most Popular', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (_, j) =>
                    CourseCard(course: courses[j], isDark: isDark),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Recommended', style: TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (_, j) =>
                    CourseCard(course: courses[j], isDark: isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerCourseDetail extends StatelessWidget {
  const ShimmerCourseDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 260,
                    color: Colors.grey.shade300,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 20,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 60,
                              height: 20,
                              color: Colors.grey.shade300,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 30,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 200,
                          height: 30,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 150,
                          height: 20,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerFullScreen extends StatelessWidget {
  const ShimmerFullScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Skeletonizer(
          enabled: true,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
