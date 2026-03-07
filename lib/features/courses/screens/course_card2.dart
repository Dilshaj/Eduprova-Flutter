import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduprova/core/utils/image_cache_manager.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:flutter/material.dart';
import '../core/models/course_model.dart';

class CourseCard2 extends StatefulWidget {
  final CourseModel course;
  final String layout; // 'horizontal' or 'vertical'

  const CourseCard2({
    super.key,
    required this.course,
    this.layout = 'vertical',
  });

  @override
  State<CourseCard2> createState() => _CourseCard2State();
}

class _CourseCard2State extends State<CourseCard2> {
  bool isExpanded = false;

  void handlePress() {
    debugPrint("course details page: ${widget.course.title}");
    //TODO
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

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    // final tagColors = getTagColor(widget.course.tag?.type, themeExt);

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

                child: widget.course.thumbnail != null
                    ? CachedNetworkImage(
                        cacheManager: CacheManagers.courseThumbnailCacheManager,
                        imageUrl: widget.course.thumbnail!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/course_placeholder.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
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
                      widget.course.instructor?.fullName ?? "",
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
                          '₹${widget.course.discountedPrice}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                    Positioned.fill(
                      // child: Image.network(
                      //   widget.course.image,
                      //   fit: BoxFit.cover,
                      // ),
                      child: widget.course.thumbnail != null
                          ? Image.network(
                              widget.course.thumbnail!,
                              fit: BoxFit.cover,
                            )
                          : Container(child: const Icon(Icons.image, size: 50)),
                    ),
                    // if (widget.course.tag != null)
                    //   Positioned(
                    //     top: 8,
                    //     left: 8,
                    //     child: Container(
                    //       padding: const EdgeInsets.symmetric(
                    //         horizontal: 8,
                    //         vertical: 4,
                    //       ),
                    //       decoration: BoxDecoration(
                    //         color: tagColors['bg'],
                    //         borderRadius: BorderRadius.circular(4),
                    //       ),
                    //       child: Text(
                    //         widget.course.tag!.text.toUpperCase(),
                    //         style: TextStyle(
                    //           fontSize: 10,
                    //           fontWeight: FontWeight.bold,
                    //           color: tagColors['text'],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
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
                              widget.course.instructor?.fullName ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: themeExt.secondaryText,
                              ),
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
                                  widget.course.duration ?? '0m',
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
                                  '₹${widget.course.discountedPrice}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 6),
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: themeExt.discountBackgroundColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              // TODO: provide discount percentage
                              child: Text(
                                '${widget.course.discountedPrice}% off',
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
                                widget.course.instructor?.fullName ?? '',
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
