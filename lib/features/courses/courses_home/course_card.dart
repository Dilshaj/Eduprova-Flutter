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
  bool isExpanded = false;

  void handlePress() {
    debugPrint("course details page: ${widget.course.title}");
    context.push('/course/${widget.course.id}');
  }

  // Helper to determine tag
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
    if (widget.course.discountedPrice == null ||
        widget.course.originalPrice == 0) {
      return 0;
    }
    final discount =
        widget.course.originalPrice - widget.course.discountedPrice!;
    return ((discount / widget.course.originalPrice) * 100).toInt();
  }

  Map<String, Color> getTagColor(String? type, AppDesignExtension themeExt) {
    switch (type) {
      case 'bestseller':
        return {
          'bg': themeExt.bestsellerBadgeColor,
          'text': themeExt.bestsellerBadgeTextColor,
        };
      case 'hot':
        return {
          'bg': themeExt.hotBadgeColor,
          'text': themeExt.hotBadgeTextColor,
        };
      case 'highestRated':
        return {
          'bg': themeExt.highestRatedBadgeColor,
          'text': themeExt.highestRatedBadgeTextColor,
        };
      default:
        return {
          'bg': themeExt.bestsellerBadgeColor,
          'text': themeExt.bestsellerBadgeTextColor,
        };
    }
  }

  Widget _buildImage(double width, double height) {
    if (widget.course.thumbnail == null || widget.course.thumbnail!.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }
    return CachedNetworkImage(
      imageUrl: widget.course.thumbnail!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      cacheManager: CacheManagers.courseThumbnailCacheManager,
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey[300],
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
    final currentPrice =
        widget.course.discountedPrice ?? widget.course.originalPrice;

    if (widget.layout == 'vertical') {
      return InkWell(
        onTap: handlePress,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: themeExt.cardColor,
            border: Border(bottom: BorderSide(color: themeExt.borderColor)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: _buildImage(70, 70),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.course.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.course.instructor?.fullName ??
                          'Unknown Instructor',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeExt.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          widget.course.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: themeExt.warningColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.star,
                          size: 12,
                          color: themeExt.warningColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${widget.course.studentCount})',
                          style: TextStyle(
                            fontSize: 11,
                            color: themeExt.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '₹${currentPrice.toInt()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (widget.course.discountedPrice != null)
                          Text(
                            '₹${widget.course.originalPrice.toInt()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: themeExt.secondaryText,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(right: 16, bottom: 4),
      child: InkWell(
        onTap: handlePress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 230,
          height: 320,
          decoration: BoxDecoration(
            color: themeExt.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeExt.borderColor),
            boxShadow: [
              BoxShadow(
                color: themeExt.shadowColor,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SizedBox(
                height: 130,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildImage(double.infinity, 130)),
                    if (tagText != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: tagColors['bg'],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tagText.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: tagColors['text'],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.course.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              height: 1.2,
                            ),
                            maxLines: isExpanded ? null : 2,
                            overflow: isExpanded ? null : TextOverflow.ellipsis,
                          ),
                          if (widget.course.title.length > 35) ...[
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                              child: Text(
                                isExpanded ? 'Read Less ▲' : 'Read More ▼',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: themeExt.readMoreColor,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          if (!isExpanded) ...[
                            Text(
                              widget.course.instructor?.fullName ??
                                  'Unknown Instructor',
                              style: TextStyle(
                                fontSize: 12,
                                color: themeExt.secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  widget.course.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: themeExt.warningColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: themeExt.warningColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${widget.course.studentCount})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: themeExt.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: themeExt.secondaryText,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.course.duration ?? '0h',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: themeExt.secondaryText,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Text(
                                    '•',
                                    style: TextStyle(
                                      color: themeExt.secondaryText,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.person_outline,
                                  size: 12,
                                  color: themeExt.secondaryText,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.course.level,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: themeExt.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      if (!isExpanded)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '₹${currentPrice.toInt()}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (widget.course.discountedPrice != null)
                                  Text(
                                    '₹${widget.course.originalPrice.toInt()}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: themeExt.secondaryText,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                            if (getDiscountPercentage() > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: themeExt.discountBackgroundColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${getDiscountPercentage()}% off',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: themeExt.discountTextColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      if (isExpanded)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.course.instructor?.fullName ??
                                    'Unknown Instructor',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: themeExt.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '(Full title visible above)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: themeExt.secondaryText,
                                ),
                              ),
                            ],
                          ),
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
