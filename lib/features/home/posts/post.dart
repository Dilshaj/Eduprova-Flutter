import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduprova/core/utils/image_cache_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:eduprova/features/home/posts/widgets/post_action_bar.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class PostModel {
  final String id;
  final String name;
  final String? designation;
  final String? timeAgo;
  final String? content;
  final String? imageUrl;
  final List<String>? images;
  final String authorAvatar;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isSaved;
  final String? mediaType;
  final String? videoUrl;
  final String? pdfUrl;

  PostModel({
    required this.id,
    required this.name,
    this.designation,
    this.timeAgo,
    this.content,
    this.imageUrl,
    this.images,
    required this.authorAvatar,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.mediaType,
    this.videoUrl,
    this.pdfUrl,
  });

  PostModel copyWith({
    String? id,
    String? name,
    String? designation,
    String? timeAgo,
    String? content,
    String? imageUrl,
    List<String>? images,
    String? authorAvatar,
    DateTime? createdAt,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    bool? isSaved,
    String? mediaType,
    String? videoUrl,
    String? pdfUrl,
  }) {
    return PostModel(
      id: id ?? this.id,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      timeAgo: timeAgo ?? this.timeAgo,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      mediaType: mediaType ?? this.mediaType,
      videoUrl: videoUrl ?? this.videoUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
    );
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    final author = map['authorId'] as Map<String, dynamic>?;
    final allMedia = (map['media'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    
    final imageUrls = allMedia
        .where((m) => m['type'] != 'video' && m['type'] != 'pdf')
        .map((m) => m['url'] as String)
        .toList();

    final media = allMedia.firstOrNull;

    return PostModel(
      id: map['_id'] ?? '',
      name: author != null
          ? '${author['firstName'] ?? ''} ${author['lastName'] ?? ''}'.trim()
          : 'Anonymous',
      designation: author?['designation'] ?? 'Student',
      timeAgo: _formatTimeAgo(map['createdAt']),
      content: map['caption'],
      imageUrl: imageUrls.firstOrNull,
      images: imageUrls.length > 1 ? imageUrls : null,
      videoUrl: allMedia.firstWhere((m) => m['type'] == 'video', orElse: () => {})['url'],
      pdfUrl:
          map['pdfUrl'] ??
          allMedia.firstWhere((m) => m['type'] == 'pdf', orElse: () => {})['url'],
      authorAvatar: author?['avatar'] ?? 'assets/avatars/1.png',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      isSaved: map['isSaved'] ?? false,
      mediaType: map['fileType'] ?? media?['type'],
    );
  }

  static String _formatTimeAgo(String? dateStr) {
    if (dateStr == null) return 'now';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return 'now';

    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }
}

class Post extends ConsumerStatefulWidget {
  final PostModel post;

  const Post({super.key, required this.post});

  @override
  ConsumerState<Post> createState() => _PostState();
}

class _PostState extends ConsumerState<Post> {
  @override
  Widget build(BuildContext context) {
    final design = context.design;
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: design.cardColor,
          borderRadius: BorderRadius.circular(28.0),
          border: Border.all(
            color: isDark 
              ? Colors.white.withValues(alpha: 0.05) 
              : Colors.black.withValues(alpha: 0.01),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: design.skeletonBase,
                      backgroundImage: widget.post.authorAvatar.startsWith('http')
                          ? CachedNetworkImageProvider(
                              widget.post.authorAvatar,
                              cacheManager: CacheManagers.avatarCacheManager,
                            )
                          : AssetImage(widget.post.authorAvatar)
                              as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.name,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.post.designation ?? ''} • ${widget.post.timeAgo ?? ''}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: design.secondaryText.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.columns2,
                    size: 24,
                    color: design.secondaryText.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),

            // Text Content
            if (widget.post.content != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  widget.post.content!,
                  style: GoogleFonts.inter(
                    fontSize: 16.5,
                    height: 1.5,
                    color: colorScheme.onSurface.withValues(alpha: 0.9),
                    letterSpacing: -0.1,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            
            const SizedBox(height: 16),

            // Image Content
            if (widget.post.images != null && widget.post.images!.length > 1)
              _buildImageGrid(widget.post.images!, isDark)
            else if (widget.post.imageUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: CachedNetworkImage(
                    imageUrl: widget.post.imageUrl!,
                    cacheManager: CacheManagers.postCacheManager,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImageLoading(260, isDark),
                    errorWidget: (context, url, error) => _buildImageError(),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Interaction Bar
            PostActionBar(
              postId: widget.post.id,
              content: widget.post.content ?? '',
              likeCount: widget.post.likeCount,
              commentCount: widget.post.commentCount,
              isLiked: widget.post.isLiked,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, curve: Curves.easeOutCubic);
  }

  Widget _buildImageGrid(List<String> images, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 300,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: _buildNetworkImage(images[0], isDark),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _buildNetworkImage(images[1], isDark)),
                    const SizedBox(height: 4),
                    Expanded(
                      child: images.length > 2
                          ? _buildNetworkImage(images[2], isDark)
                          : Container(color: context.design.skeletonBase),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: images.length > 3
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildNetworkImage(images[3], isDark),
                                if (images.length > 4)
                                  Container(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    child: Center(
                                      child: Text(
                                        '+${images.length - 3}',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : Container(color: context.design.skeletonBase),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String url, bool isDark) {
    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: CacheManagers.postCacheManager,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: context.design.skeletonBase),
      errorWidget: (context, url, error) => _buildImageError(),
    );
  }

  Widget _buildImageError() {
    return Container(
      height: 200,
      color: context.design.skeletonBase,
      child: const Center(
        child: Icon(LucideIcons.imageOff, color: Colors.grey, size: 32),
      ),
    );
  }

  Widget _buildImageLoading(double height, bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2D2D2D) : Colors.grey[200]!,
      highlightColor: isDark ? const Color(0xFF3D3D3D) : Colors.grey[100]!,
      child: Container(
        height: height,
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }
}
