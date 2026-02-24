import 'dart:convert';
import 'package:eduprova/core/widgets/app_loaders.dart';
import 'package:eduprova/core/widgets/app_video_player.dart';
import 'package:eduprova/core/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduprova/core/utils/image_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../models/course_detail_model.dart';
import '../providers/course_detail_provider.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showVideo = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: kToolbarHeight - 8,
            scrolledUnderElevation: 0,
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : Colors.black,
            ),
            actions: [
              IconButton(
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedShare01,
                  color: Colors.grey,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedFavourite,
                  color: Colors.grey,
                ),
                onPressed: () {},
              ),
            ],
          ),
          // extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Video / Thumbnail
                        SizedBox(
                          height: 260,
                          width: double.infinity,
                          child:
                              _showVideo &&
                                  (course.muxPlaybackId != null ||
                                      course.video != null ||
                                      course.videoSource?.playbackId != null)
                              ? AppVideoPlayer(
                                  muxPlaybackId:
                                      course.muxPlaybackId ??
                                      course.videoSource?.playbackId,
                                  url: course.video,
                                  autoPlay: true,
                                )
                              : Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    _buildImage(
                                      course.thumbnail,
                                      width: double.infinity,
                                      height: 260,
                                    ),
                                    if (course.muxPlaybackId != null ||
                                        course.video != null ||
                                        course.videoSource?.playbackId != null)
                                      Container(color: Colors.black26),
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
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
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

                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildBadge('BESTSELLER', Colors.blue),
                                  const SizedBox(width: 8),
                                  _buildBadge(
                                    course.level.toUpperCase(),
                                    Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildBadge(course.category, Colors.green),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                course.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Created by ${course.instructor?.fullName ?? "Unknown"}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    course.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${course.numReviews} ratings)',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    course.duration ?? 'Unknown',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
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

                  // Sticky TabBar
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: isDark ? Colors.white : Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: const Color(0xFF4A8BFF),
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
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

                  // TabBarView Content
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAboutTab(isDark, course),
                        _buildCurriculumTab(isDark, course),
                        _buildInstructorTab(isDark, course),
                        const Center(child: Text("Reviews Content")),
                      ],
                    ),
                  ),
                ],
              ),

              // Bottom Sticky Bar Action
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: course.isOwner
                      ? Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A8BFF), Color(0xFFFF61D8)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              context.push(AppRoutes.courseLearning(course.id));
                            },
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
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                onPressed: () {},
                                child: Text(
                                  'Add to Cart',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4A8BFF),
                                      Color(0xFFFF61D8),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    'Buy Now',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAboutTab(bool isDark, CourseDetailModel course) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Course Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            course.description,
            style: TextStyle(
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          if (course.learningPoints.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'What you\'ll learn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final point in course.learningPoints)
              _buildChecks(point, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildCurriculumTab(bool isDark, CourseDetailModel course) {
    if (course.curriculum.isEmpty) {
      return const Center(child: Text("No curriculum available."));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
      itemCount: course.curriculum.length,
      itemBuilder: (context, index) {
        final chapter = course.curriculum[index];
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              chapter.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${chapter.lectures.length} lectures'),
            children: chapter.lectures.map((lecture) {
              return ListTile(
                leading: const Icon(
                  Icons.play_circle_outline,
                  color: Colors.blue,
                ),
                title: Text(lecture.title),
                subtitle: Text('${(lecture.duration / 60).floor()} mins'),
                trailing: lecture.freePreview
                    ? const Text(
                        'Preview',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : const Icon(Icons.lock, size: 16, color: Colors.grey),
                onTap: () {
                  // TODO: Later on handle changing the video player source on tap.
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildInstructorTab(bool isDark, CourseDetailModel course) {
    final instructor = course.instructor;
    if (instructor == null) {
      return const Center(child: Text("Instructor information not available"));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade200,
                child: ClipOval(
                  child: _buildImage(
                    instructor.avatar,
                    width: 80,
                    height: 80,
                    placeholder: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instructor.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Senior Instructor',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'About Instructor',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            instructor.bio ?? 'No bio available.',
            style: TextStyle(
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

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
      cacheManager: CacheManagers.avatarCacheManager,
      placeholder: (context, url) => placeholder ?? const ShimmerImageLoader(),
      errorWidget: (context, url, error) =>
          placeholder ?? const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  Widget _buildChecks(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
