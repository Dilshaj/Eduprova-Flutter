import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:eduprova/core/navigation/app_routes.dart';
import 'package:eduprova/features/home/main_layout.dart';
import 'package:eduprova/features/home/posts/post.dart';
import 'package:eduprova/features/home/storie/view_storie/stories_row.dart';
import 'package:eduprova/theme/theme.dart';
import 'posts/post_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 0;

      if (scrolled != _isScrolled) {
        setState(() {
          _isScrolled = scrolled;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF3F7FF),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    final scaffoldBg = isDark ? const Color(0xFF111827) : const Color(0xFFF3F7FF);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // 1. App Bar - Solid background when scrolled to prevent merging
        SliverAppBar(
          backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF3F7FF),
          floating: true,
          snap: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          toolbarHeight: 70,
          flexibleSpace: FlexibleSpaceBar(
            background: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isScrolled ? 1 : 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.only(left: 8),
            child: IconButton(
              onPressed: () {
                mainScaffoldKey.currentState?.openDrawer();
              },
              icon: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 14,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white70 : const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 22,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white70 : const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          title: Hero(
            tag: 'app_logo',
            child: Image.asset(
              'assets/logo1.png',
              height: 48, // Reduced slightly for better fit
              fit: BoxFit.contain,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(LucideIcons.search, size: 24, color: isDark ? Colors.white70 : const Color(0xFF374151)),
              onPressed: () => context.push(AppRoutes.search),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: InkWell(
                      onTap: () {},
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: BorderRadius.circular(22),
                      child: Icon(
                        LucideIcons.bell,
                        size: 24,
                        color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53E3E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF111827) : Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),

        // 2. Stories Row - Solid background to prevent posts from "merging" behind them
        SliverToBoxAdapter(
          child: Container(
            color: scaffoldBg,
            padding: const EdgeInsets.only(top: 8.0, bottom: 4),
            child: const StatusRow(),
          ),
        ),

        // 3. Sticky Header - Pinned
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(
            isDark: isDark,
            backgroundColor: scaffoldBg,
          ),
        ),

        // 4. Posts List
        ref.watch(postsProvider).when(
          data: (posts) {
            if (posts.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('No posts found')),
                ),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Post(
                  key: ValueKey(posts[index].id),
                  post: posts[index],
                ),
                childCount: posts.length,
              ),
            );
          },
          loading: () => SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Skeletonizer(
                key: ValueKey('skeleton_$index'),
                enabled: true,
                child: Post(
                  post: PostModel(
                    id: 'dummy_$index',
                    name: 'User Name',
                    authorAvatar: 'assets/avatars/1.png',
                    content: 'Loading content...',
                    imageUrl: null,
                    createdAt: DateTime.now(),
                  ),
                ),
              ),
              childCount: 5,
            ),
          ),
          error: (err, st) => SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $err'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.read(postsProvider.notifier).refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isDark;
  final Color backgroundColor;

  _StickyHeaderDelegate({required this.isDark, required this.backgroundColor});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      // Ensure solid background color to block posts from showing through when pinned
      color: backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.8),
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: overlapsContent ? 10 : 0, sigmaY: overlapsContent ? 10 : 0),
          child: const _AllPostsHeader(),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 76;
  @override
  double get minExtent => 76;
  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) => 
      isDark != oldDelegate.isDark || backgroundColor != oldDelegate.backgroundColor;
}

class _AllPostsHeader extends StatefulWidget {
  const _AllPostsHeader();

  @override
  State<_AllPostsHeader> createState() => _AllPostsHeaderState();
}

class _AllPostsHeaderState extends State<_AllPostsHeader> {
  int _selectedTab = 0;
  final List<String> _tabs = ['All', 'Trending', 'Followers', 'Latest'];
  
  final Map<String, String> _tabHeadings = {
    'All': 'All Posts',
    'Trending': 'Hot & Trending',
    'Followers': 'Following Feed',
    'Latest': 'Just Posted',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeTab = _tabs[_selectedTab];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _tabHeadings[activeTab] ?? 'Community Posts',
                key: ValueKey(activeTab),
                style: TextStyle(
                  fontSize: 18, // Adjusted for mobile
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = index == _selectedTab;
                return InkWell(
                  onTap: () => setState(() => _selectedTab = index),
                  mouseCursor: SystemMouseCursors.click,
                  borderRadius: BorderRadius.circular(25),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white) 
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: isSelected && !isDark ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        )
                      ] : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _tabs[index],
                          style: TextStyle(
                            fontSize: 11, // Tighter for mobile
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected 
                                ? (isDark ? Colors.blue[400] : const Color(0xFF1E293B))
                                : (isDark ? Colors.grey[500] : const Color(0xFF64748B)),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 1),
                          Container(
                            width: 10,
                            height: 1.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(width: 8),
          
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: !isDark ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                )
              ] : null,
            ),
            child: Icon(
              LucideIcons.slidersHorizontal,
              size: 16,
              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
