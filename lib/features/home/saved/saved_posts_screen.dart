import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduprova/core/utils/image_cache_manager.dart';
import 'package:eduprova/features/home/posts/liked_saved_provider.dart';
import 'package:eduprova/features/home/posts/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

class SavedPostsScreen extends ConsumerStatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  ConsumerState<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends ConsumerState<SavedPostsScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _tabs = ['All', 'Trending', 'Followers', 'Latest'];
  int _selectedTab = 0;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F7FF);

    return Scaffold(
      backgroundColor: bgColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(isDark, innerBoxIsScrolled),
        ],
        body: _buildBody(isDark),
      ),
    );
  }

  Widget _buildAppBar(bool isDark, bool innerBoxIsScrolled) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF3F7FF),
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          LucideIcons.arrowLeft,
          color: isDark ? Colors.white : const Color(0xFF1F2937),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Saved',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF1F2937),
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(
            LucideIcons.search,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Text(
                'Saved Posts',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              _buildTabBar(isDark),
            ],
          ),
        ),
        Expanded(child: _buildPostsList(isDark)),
      ],
    );
  }

  Widget _buildTabBar(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isSelected = _selectedTab == i;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedTab = i);
              ref.invalidate(savedPostsProvider);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _tabs[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white54 : const Color(0xFF9CA3AF)),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPostsList(bool isDark) {
    final postsAsync = ref.watch(savedPostsProvider);

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return _buildEmptyState(isDark);
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(savedPostsProvider),
          color: const Color(0xFF8B5CF6),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 120),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: Interval(
                    (index / posts.length) * 0.5,
                    1.0,
                    curve: Curves.easeOut,
                  ),
                ),
                child: _SavedPostCard(post: posts[index]),
              );
            },
          ),
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.only(bottom: 120),
        itemCount: 4,
        itemBuilder: (_, __) => _buildShimmerCard(isDark),
      ),
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFF05252)),
            const SizedBox(height: 16),
            Text(
              'Failed to load saved posts',
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(savedPostsProvider),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child:
                const Icon(LucideIcons.bookmark, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            'No saved posts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Posts you bookmark will appear here',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF1E293B) : Colors.grey[200]!,
        highlightColor: isDark ? const Color(0xFF334155) : Colors.grey[100]!,
        child: Container(
          height: 260,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}

// ─────────── Saved Post Card ───────────

class _SavedPostCard extends StatelessWidget {
  final PostModel post;

  const _SavedPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: post.authorAvatar.startsWith('http')
                        ? CachedNetworkImageProvider(
                            post.authorAvatar,
                            cacheManager: CacheManagers.avatarCacheManager,
                          )
                        : AssetImage(post.authorAvatar) as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '${post.designation ?? 'Student'} • ${post.timeAgo ?? 'now'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.layoutGrid,
                    size: 18,
                    color:
                        isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
            if (post.content != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  post.content!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color:
                        isDark ? Colors.white70 : const Color(0xFF374151),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 10),
            if (post.imageUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl!,
                    cacheManager: CacheManagers.postCacheManager,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white, height: 200),
                    ),
                    errorWidget: (context, url, error) =>
                        const SizedBox(height: 0),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  _ActionBtn(
                      icon: LucideIcons.messageSquare,
                      label: 'Likes',
                      isDark: isDark),
                  const SizedBox(width: 18),
                  _ActionBtn(
                      icon: LucideIcons.messageCircle,
                      label: 'Comments',
                      isDark: isDark),
                  const SizedBox(width: 18),
                  _ActionBtn(
                      icon: LucideIcons.rotateCcw,
                      label: 'Repost',
                      isDark: isDark),
                  const SizedBox(width: 18),
                  _ActionBtn(
                      icon: LucideIcons.send,
                      label: 'Share',
                      isDark: isDark),
                  const Spacer(),
                  if (post.likeCount > 0)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: post.likeCount >= 1000
                                ? '${(post.likeCount / 1000).toStringAsFixed(0)}k '
                                : '${post.likeCount} ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: 'Likes',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF9CA3AF),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _ActionBtn(
      {required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white54 : const Color(0xFF9CA3AF);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 3),
        Text(label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
