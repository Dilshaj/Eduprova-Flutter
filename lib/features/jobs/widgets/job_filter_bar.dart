import 'package:eduprova/features/jobs/providers/job_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class JobFilterBar extends ConsumerWidget {
  const JobFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(jobsTabProvider);
    final filters = ref.watch(jobFiltersProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (activeTab == JobsTab.recommended) ...[
            _buildDropdownButton(
              context,
              icon: HugeIcons.strokeRoundedCircle,
              label: filters.salaryRange.isEmpty ? 'All Salaries' : filters.salaryRange.first,
              onTap: () {
                // Show salary picker
              },
            ),
            const SizedBox(width: 12),
            _buildDropdownButton(
              context,
              icon: HugeIcons.strokeRoundedBriefcase01,
              label: filters.industry.isEmpty ? 'All Industries' : filters.industry.first,
              onTap: () {
                // Show industry picker
              },
            ),
            const SizedBox(width: 12),
            _buildRemoteToggle(context, ref, filters.remoteOnly),
          ] else if (activeTab == JobsTab.applications) ...[
            _buildDropdownButton(
              context,
              icon: HugeIcons.strokeRoundedCircle,
              label: filters.applicationStatus,
              onTap: () {
                // Show status picker
              },
            ),
            const SizedBox(width: 12),
            _buildDropdownButton(
              context,
              icon: HugeIcons.strokeRoundedCalendar03,
              label: filters.dateRange,
              onTap: () {
                // Show date range picker
              },
            ),
          ] else if (activeTab == JobsTab.saved) ...[
            _buildSelectableChip(
              label: 'All Saved',
              isSelected: filters.savedFilter == 'All Saved',
              count: 1,
              onTap: () => ref.read(jobFiltersProvider.notifier).update(
                filters.copyWith(savedFilter: 'All Saved'),
              ),
            ),
            const SizedBox(width: 8),
            _buildSelectableChip(
              label: 'Submitted',
              isSelected: filters.savedFilter == 'Submitted',
              count: 1,
              onTap: () => ref.read(jobFiltersProvider.notifier).update(
                filters.copyWith(savedFilter: 'Submitted'),
              ),
            ),
            const SizedBox(width: 8),
            _buildSelectableChip(
              label: 'Not Submitted',
              isSelected: filters.savedFilter == 'Not Submitted',
              count: 0,
              onTap: () => ref.read(jobFiltersProvider.notifier).update(
                filters.copyWith(savedFilter: 'Not Submitted'),
              ),
            ),
          ] else if (activeTab == JobsTab.posted_jobs) ...[
            _buildSelectableChip(
              label: 'All Jobs',
              isSelected: filters.postedJobFilter == 'All Jobs',
              onTap: () => ref.read(jobFiltersProvider.notifier).update(
                filters.copyWith(postedJobFilter: 'All Jobs'),
              ),
            ),
            const SizedBox(width: 8),
            _buildSelectableChip(
              label: 'Active',
              isSelected: filters.postedJobFilter == 'Active',
              onTap: () => ref.read(jobFiltersProvider.notifier).update(
                filters.copyWith(postedJobFilter: 'Active'),
              ),
            ),
            const SizedBox(width: 8),
            _buildSelectableChip(
              label: 'Drafts',
              isSelected: filters.postedJobFilter == 'Drafts',
              onTap: () => ref.read(jobFiltersProvider.notifier).update(
                filters.copyWith(postedJobFilter: 'Drafts'),
              ),
            ),
            const SizedBox(width: 8),
            _buildSelectableChip(
              label: 'Closed',
              isSelected: filters.postedJobFilter == 'Closed',
              onTap: () => ref.read(jobFiltersProvider.notifier).update(
                filters.copyWith(postedJobFilter: 'Closed'),
              ),
            ),
          ],
          
          // Reset button for filterable tabs
          if (activeTab == JobsTab.recommended || activeTab == JobsTab.applications)
            if (filters.salaryRange.isNotEmpty || 
                filters.industry.isNotEmpty || 
                filters.remoteOnly || 
                filters.applicationStatus != 'All Statuses' ||
                filters.dateRange != 'Last 30 Days') ...[
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => ref.read(jobFiltersProvider.notifier).reset(),
                icon: const Icon(Icons.close, size: 16, color: Colors.red),
                label: const Text(
                  'Reset',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildSelectableChip({
    required String label,
    required bool isSelected,
    int? count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3067FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3067FF) : Colors.blue.shade100,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF3067FF).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownButton(
    BuildContext context, {
    required List<List<dynamic>> icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Row(
          children: [
            HugeIcon(icon: icon, color: Colors.blue.shade600, size: 14),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF475569)),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteToggle(BuildContext context, WidgetRef ref, bool isRemote) {
    return GestureDetector(
      onTap: () {
        ref.read(jobFiltersProvider.notifier).update(
          ref.read(jobFiltersProvider).copyWith(remoteOnly: !isRemote),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isRemote ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRemote ? Colors.blue.shade200 : Colors.blue.shade100,
          ),
        ),
        child: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedZap,
              color: isRemote ? Colors.blue.shade600 : Colors.blueGrey.shade400,
              size: 14,
            ),
            const SizedBox(width: 8),
            Text(
              'Remote',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isRemote ? Colors.blue.shade700 : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 20,
              width: 32,
              child: Switch(
                value: isRemote,
                onChanged: (val) {
                  ref.read(jobFiltersProvider.notifier).update(
                    ref.read(jobFiltersProvider).copyWith(remoteOnly: val),
                  );
                },
                activeColor: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
