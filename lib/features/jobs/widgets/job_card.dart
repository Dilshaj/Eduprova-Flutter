import 'package:eduprova/features/jobs/models/job_model.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class JobCard extends ConsumerWidget {
  final Job job;
  final VoidCallback? onTap;
  final Function(String)? onToggleSave;
  final bool showApplicantsBadge;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onToggleSave,
    this.showApplicantsBadge = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeExt = context.design;

    return GestureDetector(
      onTap: () => context.push('/jobs/detail/${job.id}'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: themeExt.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.blue.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.indigo.shade100),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildCompanyIcon(job.icon, job.company),
                ),
                const SizedBox(width: 16),
                
                // Job Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              job.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            job.company,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                      if (job.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _stripHtml(job.description!),
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Colors.blueGrey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip(
                            HugeIcons.strokeRoundedBriefcase01,
                            job.type,
                          ),
                          _buildChip(
                            HugeIcons.strokeRoundedTag01,
                            job.salary,
                          ),
                          _buildChip(
                            HugeIcons.strokeRoundedLocation01,
                            job.location,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Applicants or "Be the first"
                if (showApplicantsBadge) _buildApplicantsSection(context),
                
                // Actions
                Row(
                  children: [
                    _buildIconButton(
                      context,
                      job.isSaved 
                        ? HugeIcons.strokeRoundedBookmark02
                        : HugeIcons.strokeRoundedBookmark02, 
                      job.isSaved ? Colors.blue : Colors.blueGrey.shade600,
                      job.isSaved ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
                      () => onToggleSave?.call(job.id),
                      isSolid: job.isSaved,
                    ),
                    const SizedBox(width: 8),
                    if (job.hasApplied)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.teal.shade100),
                        ),
                        child: Row(
                          children: [
                             Icon(Icons.check_circle, color: Colors.teal.shade500, size: 16),
                             const SizedBox(width: 6),
                             const Text(
                               "Applied",
                               style: TextStyle(
                                 fontSize: 13,
                                 fontWeight: FontWeight.bold,
                                 color: Color(0xFF15803D), // emerald-700
                               ),
                             ),
                          ],
                        ),
                      )
                    else
                      Container(
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0066FF).withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/jobs/detail/${job.id}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          icon: const Text(
                            "Apply Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          label: const HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowRight01,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyIcon(String icon, String company) {
    if (icon.startsWith('http') || icon.startsWith('data:')) {
      return Image.network(
        icon,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildPlaceholderIcon(company),
      );
    }
    // Assume local asset for now if not URL
    return _buildPlaceholderIcon(company);
  }

  Widget _buildPlaceholderIcon(String company) {
    return Center(
      child: Text(
        company.length >= 2 ? company.substring(0, 2).toUpperCase() : 'JB',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildChip(List<List<dynamic>> icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, size: 12, color: const Color(0xFF475569)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantsSection(BuildContext context) {
    if (job.applicantsCount > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.blue.shade100.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            // Avatar Stack
            SizedBox(
              width: 50,
              height: 32,
              child: Stack(
                children: [
                  for (int i = 0; i < math.min(job.applicantsCount, 3); i++)
                    Positioned(
                      left: i * 16.0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          color: _getFallbackColor(i),
                        ),
                        child: const Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedUser,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  if (job.applicantsCount > 3)
                    Positioned(
                      left: 3 * 12.0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueGrey.shade100.withValues(alpha: 0.8),
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            "+${job.applicantsCount - 3}",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.blueGrey.shade500,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "${job.applicantsCount}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Active",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.blue.shade600.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                Text(
                  "APPLICANTS",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.blueGrey.shade400,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: HugeIcon(icon: HugeIcons.strokeRoundedSparkles, color: Colors.indigo.shade500, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Be the first",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.indigo.shade600,
                ),
              ),
              Text(
                "to land this role",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.indigo.shade300,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Color _getFallbackColor(int index) {
    final colors = [
      Colors.blue.shade400,
      Colors.teal.shade400,
      Colors.deepPurple.shade400,
      Colors.red.shade400,
    ];
    return colors[index % colors.length];
  }

  Widget _buildIconButton(
    BuildContext context,
    List<List<dynamic>> icon,
    Color color,
    Color bgColor,
    VoidCallback onTap, {
    bool isSolid = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSolid ? color.withValues(alpha: 0.2) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Center(
          child: HugeIcon(
            icon: icon,
            size: 18,
            color: color,
            // isSolid: isSolid, // Assuming hugeicons has this or handle via icon name
          ),
        ),
      ),
    );
  }

  String _stripHtml(String html) {
    // Simple regex to strip HTML tags for preview
    return html.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
  }
}
