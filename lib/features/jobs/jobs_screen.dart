import 'package:eduprova/features/jobs/providers/job_provider.dart';
import 'package:eduprova/features/jobs/widgets/job_filter_bar.dart';
import 'package:eduprova/features/jobs/widgets/jobs_feed_view.dart';
import 'package:eduprova/features/jobs/widgets/jobs_search_bar.dart';
import 'package:eduprova/features/jobs/widgets/jobs_tab_bar.dart';
import 'package:eduprova/features/jobs/widgets/my_applications_view.dart';
import 'package:eduprova/features/jobs/widgets/posted_jobs_view.dart';
import 'package:eduprova/features/jobs/widgets/saved_jobs_view.dart';
import 'package:eduprova/ui/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(jobsTabProvider);

    return Scaffold(
      body: Stack(
        children: [
          const AppBackground(),
          Column(
            children: [
              // Header Section
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/logos/eduprova-logo.png',
                            height: 44,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: JobsSearchBar(),
                          ),
                          const SizedBox(width: 8),
                          _buildPostJobButton(context),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: JobsTabBar(),
                      ),
                      const SizedBox(height: 8),
                      const JobFilterBar(),
                    ],
                  ),
                ),
              ),
              
              // Content Section
              Expanded(
                child: _buildTabContent(activeTab),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostJobButton(BuildContext context) {
    return const _ShimmerPostJobButton();
  }

  Widget _buildTabContent(JobsTab tab) {
    switch (tab) {
      case JobsTab.recommended:
        return const JobsFeedView();
      case JobsTab.applications:
        return const MyApplicationsView();
      case JobsTab.saved:
        return const SavedJobsView();
      case JobsTab.posted_jobs:
        return const PostedJobsView();
    }
  }
}

class _ShimmerPostJobButton extends StatefulWidget {
  const _ShimmerPostJobButton();

  @override
  State<_ShimmerPostJobButton> createState() => _ShimmerPostJobButtonState();
}

class _ShimmerPostJobButtonState extends State<_ShimmerPostJobButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: LinearGradient(
              colors: const [
                Color(0xFF0066FF),
                Color(0xFF7C3AED),
                Color(0xFFE056FD),
                Color(0xFF0066FF),
              ],
              begin: Alignment(
                -1.0 + 2.0 * _controller.value,
                -1.0 + 2.0 * _controller.value,
              ),
              end: Alignment(
                1.0 + 2.0 * _controller.value,
                1.0 + 2.0 * _controller.value,
              ),
              stops: const [0.0, 0.33, 0.66, 1.0],
              tileMode: TileMode.mirror,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () {
                // Add navigation logic to Post a Job
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Post a Job',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}



