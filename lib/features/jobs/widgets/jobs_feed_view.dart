import 'package:eduprova/features/jobs/providers/job_provider.dart';
import 'package:eduprova/features/jobs/widgets/job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JobsFeedView extends ConsumerWidget {
  const JobsFeedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(filteredJobsProvider);

    if (jobs.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return JobCard(
          job: job,
          onTap: () {
            // Navigate to details
          },
          onToggleSave: (id) {
            // Handle save toggle
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.blueGrey.shade100),
            ),
            child: Icon(
              Icons.search,
              size: 48,
              color: Colors.blueGrey.shade300,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No jobs matched',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Try adjusting your search or filters to find more opportunities.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ref.read(jobFiltersProvider.notifier).reset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: Colors.blue.shade200,
            ),
            child: const Text(
              'CLEAR ALL FILTERS',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
