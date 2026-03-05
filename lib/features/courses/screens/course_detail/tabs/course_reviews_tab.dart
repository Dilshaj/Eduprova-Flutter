import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduprova/features/courses/providers/course_review_provider.dart';
import 'package:eduprova/features/courses/models/course_detail_model.dart';
import 'package:eduprova/theme.dart';
import 'package:intl/intl.dart';

class CourseReviewsTab extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final reviewsState = ref.watch(courseReviewsProvider(course.id));

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Summary
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
                        (i) => Icon(
                          Icons.star,
                          size: 12,
                          color: i < course.rating.floor()
                              ? const Color(0xFFFFB800)
                              : themeExt.secondaryText.withValues(alpha: 0.3),
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
                Expanded(
                  child: Column(
                    children: [5, 4, 3, 2, 1].map((stars) {
                      // Placeholder distribution since backend doesn't provide it yet
                      // In a real app, we'd calculate this from the state
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 12,
                              child: Text(
                                '$stars',
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
                                  widthFactor: 0.1, // Placeholder
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
                                '0%',
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

          // Write a review section
          if (course.isOwner && !reviewsState.userHasReviewed)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: InkWell(
                onTap: () => _showWriteReviewDialog(context, ref),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Write a review',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Share your experience with this course',
                              style: TextStyle(
                                fontSize: 12,
                                color: themeExt.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (reviewsState.isLoading && reviewsState.reviews.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (reviewsState.reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.reviews_outlined,
                      size: 48,
                      color: themeExt.secondaryText.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No reviews yet',
                      style: TextStyle(color: themeExt.secondaryText),
                    ),
                  ],
                ),
              ),
            )
          else
            ...reviewsState.reviews.map((review) {
              return _buildReviewItem(
                review.user.firstName.isNotEmpty
                    ? review.user.firstName[0].toUpperCase()
                    : '?',
                review.user.fullName,
                DateFormat.yMMMd().format(review.createdAt),
                review.rating,
                review.comment,
                themeExt,
                colorScheme,
              );
            }),

          if (reviewsState.hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: TextButton(
                  onPressed: reviewsState.isLoadMore
                      ? null
                      : () => ref
                            .read(allCourseReviewsProvider.notifier)
                            .loadMore(course.id),
                  child: reviewsState.isLoadMore
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Load More Reviews'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showWriteReviewDialog(BuildContext context, WidgetRef ref) {
    int selectedRating = 5;
    final commentController = TextEditingController();
    bool isPosting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Write a Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFB800),
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() => selectedRating = index + 1);
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe your experience...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isPosting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isPosting
                  ? null
                  : () async {
                      if (commentController.text.trim().isEmpty) return;
                      setState(() => isPosting = true);
                      final success = await ref
                          .read(allCourseReviewsProvider.notifier)
                          .postReview(
                            course.id,
                            selectedRating,
                            commentController.text.trim(),
                          );
                      if (context.mounted) {
                        Navigator.pop(context);
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Failed to post review. Please try again.',
                              ),
                            ),
                          );
                        }
                      }
                    },
              child: isPosting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
