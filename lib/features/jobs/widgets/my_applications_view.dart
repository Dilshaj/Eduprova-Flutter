import 'package:eduprova/features/jobs/providers/job_provider.dart';
import 'package:eduprova/features/jobs/widgets/job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApplicationsView extends ConsumerWidget {
  const MyApplicationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(appliedJobsProvider);

    if (jobs.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return JobCard(
          job: job,
          showApplicantsBadge: false, // Don't show applicant stack in applications view
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.teal.shade100),
            ),
            child: Icon(
              Icons.assignment_turned_in_outlined,
              size: 48,
              color: Colors.teal.shade400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No applications yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Start applying for jobs to see them here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
