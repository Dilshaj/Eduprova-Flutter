import 'package:eduprova/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduprova/core/utils/image_cache_manager.dart';
import 'package:eduprova/features/courses/core/models/course_model.dart';

class CourseCard extends StatefulWidget {
  final CourseModel course;
  final String layout; // 'horizontal' or 'vertical'

  const CourseCard({
    super.key,
    required this.course,
    this.layout = 'horizontal',
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  void handlePress() {
    context.push('/course/${widget.course.id}');
  }

  String? getTagType() {
    if (widget.course.rating >= 4.8) return 'highestRated';
    if (widget.course.studentCount > 1000) return 'bestseller';
    if (widget.course.rating >= 4.5) return 'hot';
    return null;
  }

  String? getTagText() {
    final type = getTagType();
    if (type == 'highestRated') return 'Top Rated';
    if (type == 'bestseller') return 'Bestseller';
    if (type == 'hot') return 'Hot';
    return null;
  }

  int getDiscountPercentage() {
    if (widget.course.discountedPrice == null || widget.course.originalPrice == 0) {
      return 0;
    }
    final discount = widget.course.originalPrice - widget.course.discountedPrice!;
    return ((discount / widget.course.originalPrice) * 100).toInt();
  }

  Map<String, Color> getTagColor(String? type, AppDesignExtension themeExt) {
    switch (type) {
      case 'bestseller':
        return {'bg': themeExt.bestsellerBadgeColor, 'text': themeExt.bestsellerBadgeTextColor};
      case 'hot':
        return {'bg': themeExt.hotBadgeColor, 'text': themeExt.hotBadgeTextColor};
      case 'highestRated':
        return {'bg': themeExt.highestRatedBadgeColor, 'text': themeExt.highestRatedBadgeTextColor};
      default:
        return {'bg': themeExt.bestsellerBadgeColor, 'text': themeExt.bestsellerBadgeTextColor};
    }
  }

  Widget _buildImage() {
    if (widget.course.thumbnail == null || widget.course.thumbnail!.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }
    return CachedNetworkImage(
      imageUrl: widget.course.thumbnail!,
      fit: BoxFit.cover,
      cacheManager: CacheManagers.courseThumbnailCacheManager,
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final tagType = getTagType();
    final tagText = getTagText();
    final tagColors = getTagColor(tagType, themeExt);
    final currentPrice = widget.course.discountedPrice ?? widget.course.originalPrice;

    if (widget.layout == 'vertical') {
      return InkWell(
        onTap: handlePress,
        child: Container(
          padding: const .all(12),
          decoration: BoxDecoration(
            color: themeExt.cardColor,
            border: Border(bottom: BorderSide(color: themeExt.borderColor)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: .circular(6),
                child: _buildImage(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      widget.course.title,
                      style: .new(fontSize: 14, fontWeight: .bold, color: colorScheme.onSurface),
                      maxLines: 2, overflow: .ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.course.instructor?.fullName ?? 'Instructor',
                      style: .new(fontSize: 12, color: themeExt.secondaryText),
                      maxLines: 1, overflow: .ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          widget.course.rating.toStringAsFixed(1),
                          style: .new(fontSize: 12, fontWeight: .bold, color: themeExt.warningColor),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.star, size: 12, color: themeExt.warningColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('₹${currentPrice.toInt()}', style: .new(fontSize: 16, fontWeight: .bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Horizontal Card (2.3 on Mobile)
    return Container(
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      child: InkWell(
        onTap: handlePress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 190,
          height: 255, // Reduced from 290
          decoration: BoxDecoration(
            color: themeExt.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeExt.borderColor.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: themeExt.shadowColor.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const .new(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: .start,
            children: [
              // Full-width Image Section
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const .only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: _buildImage(),
                      ),
                    ),
                    if (tagText != null)
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const .symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: tagColors['bg'],
                            borderRadius: .circular(8),
                          ),
                          child: Text(
                            tagText.toUpperCase(),
                            style: .new(fontSize: 8, fontWeight: .w900, color: tagColors['text']),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10), // Added top padding for 'content gap'
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.course.title,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: colorScheme.onSurface, height: 1.2),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Subtitle
                      Text(
                        widget.course.subtitle,
                        style: TextStyle(fontSize: 10, color: themeExt.secondaryText),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      
                      const Spacer(),

                      // Price & Rating Section (Image 2 style)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.course.discountedPrice != null)
                                  Text(
                                    '₹${widget.course.originalPrice.toInt()}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: themeExt.secondaryText,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Text(
                                      '₹${currentPrice.toInt()}',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
                                    ),
                                    const SizedBox(width: 8),
                                    if (getDiscountPercentage() > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${getDiscountPercentage()}% OFF',
                                          style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32)),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Rating Badge (Yellow - Image 2 style)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9E6),
                              borderRadius: BorderRadius.circular(6),
                              // The rest of the Row content was here, but it's now part of the new structure.
                              // The closing brackets for Row and Container are handled by the new snippet.
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 10, color: Color(0xFFFFB800)),
                                const SizedBox(width: 2),
                                Text(
                                  widget.course.rating.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFFFB800)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      Divider(height: 1, color: themeExt.borderColor.withValues(alpha: 0.2)),
                      const SizedBox(height: 10),

                      // Footer Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bar_chart_rounded, size: 12, color: themeExt.secondaryText.withValues(alpha: 0.6)),
                              const SizedBox(width: 4),
                              Text(
                                widget.course.level.toUpperCase(),
                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: themeExt.secondaryText),
                              ),
                            ],
                          ),
                          Text(
                            (widget.course.duration ?? '0m').toUpperCase(),
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: themeExt.secondaryText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
