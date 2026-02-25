import 'package:flutter/material.dart';

class CoursesHomeSkeleton extends StatelessWidget {
  const CoursesHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class HelpSupportSkeleton extends StatelessWidget {
  const HelpSupportSkeleton({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class BillingPaymentsSkeleton extends StatelessWidget {
  const BillingPaymentsSkeleton({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class CourseDetailsSkeleton extends StatelessWidget {
  const CourseDetailsSkeleton({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class ProfileSettingsSkeleton extends StatelessWidget {
  const ProfileSettingsSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}
