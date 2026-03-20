import 'dart:convert';
import 'dart:math' as math;
import 'package:eduprova/features/courses/core/models/course_detail_model.dart';
import 'package:eduprova/features/courses/core/models/course_model.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:eduprova/core/widgets/app_loaders.dart';
import 'package:eduprova/core/widgets/app_video_player.dart';
import 'package:eduprova/core/widgets/shimmer_loading.dart';
import 'package:eduprova/ui/gradient_btn.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduprova/core/utils/image_cache_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/app_routes.dart';
import '../core/providers/course_detail_provider.dart';
import '../cart/cart_provider.dart';
import '../wishlist/wishlist_provider.dart';

import 'tabs/course_about_tab.dart';
import 'tabs/course_curriculum_tab.dart';
import 'tabs/course_instructor_tab.dart';
import 'tabs/course_reviews_tab.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ScrollController _scrollController;
  bool _showVideo = false;
  bool _showStickyFooter = false;
  final GlobalKey _buyNowInlineKey = GlobalKey();

  bool get _inCart => ref
      .watch(cartProvider)
      .items
      .any((item) => item.courseId == widget.courseId);

  bool get _inWishlist =>
      ref.watch(wishlistProvider).ids.contains(widget.courseId);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController()..addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateStickyFooterVisibility();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    _updateStickyFooterVisibility();
  }

  void _updateStickyFooterVisibility() {
    final ctx = _buyNowInlineKey.currentContext;
    if (ctx == null || !mounted) return;
    final renderBox = ctx.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return;

    final top = renderBox.localToGlobal(Offset.zero).dy;
    final bottom = top + renderBox.size.height;
    final media = MediaQuery.of(context);
    final viewportTop = media.padding.top + kToolbarHeight;
    final viewportBottom = media.size.height - media.padding.bottom;
    final isVisible = bottom > viewportTop && top < viewportBottom;
    final shouldShow = !isVisible;

    if (shouldShow != _showStickyFooter) {
      setState(() {
        _showStickyFooter = shouldShow;
      });
    }
  }

  AppDesignExtension get themeExt =>
      Theme.of(context).extension<AppDesignExtension>()!;
  ColorScheme get colorScheme => Theme.of(context).colorScheme;

  Widget _buildImage(
    String? url, {
    double? width,
    double? height,
    Widget? placeholder,
  }) {
    if (url == null || url.isEmpty) {
      return placeholder ?? const Icon(Icons.image, color: Colors.grey);
    }

    if (url.startsWith('data:')) {
      try {
        final base64String = url.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              placeholder ?? const Icon(Icons.broken_image, color: Colors.grey),
        );
      } catch (e) {
        return placeholder ??
            const Icon(Icons.broken_image, color: Colors.grey);
      }
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      cacheManager: CacheManagers.courseThumbnailCacheManager,
      placeholder: (context, url) => placeholder ?? const ShimmerImageLoader(),
      errorWidget: (context, url, error) =>
          placeholder ?? const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  Widget _wrapInScrollable(Widget child) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(top: 48),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));

    return courseAsync.when(
      loading: () => const ShimmerCourseDetail(),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
      data: (course) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: _buildAppBar(),
            body: Stack(
              children: [
                // AppBackground(),
                _buildBody(course),
              ],
            ),
            bottomNavigationBar: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                );
              },
              child: _showStickyFooter
                  ? KeyedSubtree(
                      key: const ValueKey('sticky_footer_visible'),
                      child: _buildFooter(context, course),
                    )
                  : const SizedBox(key: ValueKey('sticky_footer_hidden')),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: math.max(0, kToolbarHeight - 6),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            // Icons.share_outlined,
            LucideIcons.share2,
            // color: Colors.white,
            size: 22,
          ),
        ),
        IconButton(
          onPressed: () {
            ref.read(wishlistProvider.notifier).toggleWishlist(widget.courseId);
          },
          icon: Icon(
            _inWishlist ? Icons.favorite : Icons.favorite_border,
            color: _inWishlist ? colorScheme.error : null,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, CourseModel course) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        border: Border(top: BorderSide(color: themeExt.borderColor)),
        boxShadow: [
          BoxShadow(
            color: themeExt.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: course.isOwner
          ? InkWell(
              onTap: () {
                context.push(AppRoutes.courseLearning(course.id));
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: themeExt.buyNowGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Continue Learning',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_inCart) {
                        ref
                            .read(cartProvider.notifier)
                            .removeFromCart(course.id);
                      } else {
                        ref
                            .read(cartProvider.notifier)
                            .addToCart(
                              course.id,
                              price:
                                  course.discountedPrice ??
                                  course.originalPrice,
                              title: course.title,
                            );
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: themeExt.cardColor,
                        border: Border.all(color: themeExt.borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _inCart ? 'In Cart' : 'Add to Cart',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  // child: InkWell(
                  //   onTap: () {},
                  //   borderRadius: BorderRadius.circular(8),
                  //   child: Container(
                  //     height: 48,
                  //     decoration: BoxDecoration(
                  //       gradient: themeExt.buyNowGradient,
                  //       borderRadius: BorderRadius.circular(8),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: themeExt.buyNowGradient.colors.first
                  //               .withValues(alpha: 0.3),
                  //           blurRadius: 8,
                  //           offset: const Offset(0, 4),
                  //         ),
                  //       ],
                  //     ),
                  //     alignment: Alignment.center,
                  //     child: const Text(
                  //       'Buy Now',
                  //       style: TextStyle(
                  //         fontSize: 15,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  child: GradientBtn(
                    onTap: () {},
                    height: 48,
                    title: 'Buy Now',
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBody(CourseDetailModel course) {
    final themeExt = context.design;
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // Image Header
          SliverToBoxAdapter(child: _buildHeader(course)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BADGES
                  Row(
                    children: [
                      if (course.rating >= 4.5) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: themeExt.bestsellerBadgeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'BESTSELLER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: themeExt.bestsellerBadgeTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: themeExt.beginnerBadgeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          course.level.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: themeExt.beginnerBadgeTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // TITLE
                  Text(
                    course.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      text: 'Created by ',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeExt.secondaryText,
                      ),
                      children: [
                        TextSpan(
                          text: course.instructor?.fullName ?? "Unknown",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // RATINGS
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFFFB800),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        course.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${course.numReviews} ratings)',
                        style: TextStyle(
                          fontSize: 13,
                          color: themeExt.secondaryText,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: themeExt.secondaryText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        course.duration ??
                            '${course.curriculum.length} lessons',
                        style: TextStyle(
                          fontSize: 13,
                          color: themeExt.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // PRICE & ENROLL
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${course.discountedPrice ?? course.originalPrice}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (course.discountedPrice != null &&
                          course.discountedPrice != course.originalPrice)
                        Text(
                          '₹${course.originalPrice}',
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            color: themeExt.secondaryText,
                          ),
                        ),
                    ],
                  ),
                  if (course.discountedPrice != null &&
                      course.discountedPrice != course.originalPrice) ...[
                    const SizedBox(height: 4),
                    Text(
                      '⚡ LIMITED TIME OFFER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: themeExt.saleColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  GradientBtn(
                    onTap: () {
                      if (course.isOwner) {
                        context.push(AppRoutes.courseLearning(course.id));
                      }
                    },
                    height: 48,
                    title: course.isOwner ? 'Continue Learning' : 'Buy Now',
                  ),
                  if (!course.isOwner) const SizedBox(height: 12),
                  if (!course.isOwner)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (_inCart) {
                                ref
                                    .read(cartProvider.notifier)
                                    .removeFromCart(course.id);
                              } else {
                                ref
                                    .read(cartProvider.notifier)
                                    .addToCart(
                                      course.id,
                                      price:
                                          course.discountedPrice ??
                                          course.originalPrice,
                                      title: course.title,
                                    );
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: _inCart
                                    ? themeExt.successBackgroundColor
                                    : themeExt.cardColor,
                                border: Border.all(
                                  color: _inCart
                                      ? themeExt.successColor
                                      : themeExt.borderColor,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _inCart ? 'In Cart' : 'Add to cart',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: _inCart
                                      ? themeExt.successColor
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(wishlistProvider.notifier)
                                  .toggleWishlist(course.id);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: _inWishlist
                                    ? themeExt.errorBackgroundColor
                                    : themeExt.cardColor,
                                border: Border.all(
                                  color: _inWishlist
                                      ? colorScheme.error
                                      : themeExt.borderColor,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _inWishlist ? 'Wishlisted' : 'Add to wishlist',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: _inWishlist
                                      ? colorScheme.error
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // TABS
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                Container(
                  decoration: BoxDecoration(
                    color: themeExt.scaffoldBackgroundColor,
                    border: Border(
                      bottom: BorderSide(color: themeExt.borderColor),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    labelPadding: EdgeInsets.zero,
                    indicatorColor: colorScheme.primary,
                    indicatorWeight: 3,
                    dividerHeight: 0,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: themeExt.secondaryText,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'About'),
                      Tab(text: 'Curriculum'),
                      Tab(text: 'Instructor'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _wrapInScrollable(CourseAboutTab(course: course)),
          _wrapInScrollable(CourseCurriculumTab(course: course)),
          _wrapInScrollable(CourseInstructorTab(course: course)),
          _wrapInScrollable(CourseReviewsTab(course: course)),
        ],
      ),
    );
  }

  Widget _buildHeader(CourseDetailModel course) {
    return Stack(
      children: [
        SizedBox(
          height: 250,
          width: double.infinity,
          child:
              _showVideo &&
                  (course.muxPlaybackId != null ||
                      course.video != null ||
                      course.videoSource?.playbackId != null)
              ? AppVideoPlayer(
                  muxPlaybackId:
                      course.muxPlaybackId ?? course.videoSource?.playbackId,
                  url: course.video,
                  autoPlay: true,
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(
                      course.thumbnail,
                      width: double.infinity,
                      height: 250,
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (course.muxPlaybackId != null ||
                        course.video != null ||
                        course.videoSource?.playbackId != null)
                      Center(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _showVideo = true;
                            });
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      255,
                                      170,
                                      167,
                                      167,
                                    ),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Preview Course',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
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
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final Widget _tabBar;

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
