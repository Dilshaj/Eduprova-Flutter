import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduprova/core/utils/image_cache_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:eduprova/features/home/posts/widgets/post_action_bar.dart';

class PostModel {
  final String id;
  final String name;
  final String? designation;
  final String? timeAgo;
  final String? content;
  final String? imageUrl;
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
    final media = (map['media'] as List?)?.firstOrNull as Map<String, dynamic>?;

    return PostModel(
      id: map['_id'] ?? '',
      name: author != null
          ? '${author['firstName'] ?? ''} ${author['lastName'] ?? ''}'.trim()
          : 'Anonymous',
      designation: author?['designation'] ?? 'Student',
      timeAgo: _formatTimeAgo(map['createdAt']),
      content: map['caption'],
      imageUrl:
          (media != null && media['type'] != 'video' && media['type'] != 'pdf')
          ? media['url']
          : null,
      videoUrl: (media != null && media['type'] == 'video')
          ? media['url']
          : null,
      pdfUrl:
          map['pdfUrl'] ??
          ((media != null && media['type'] == 'pdf') ? media['url'] : null),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const double borderRadius = 28.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                   CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        widget.post.authorAvatar.startsWith('http')
                        ? CachedNetworkImageProvider(
                            widget.post.authorAvatar,
                            cacheManager: CacheManagers.avatarCacheManager,
                          )
                        : AssetImage(widget.post.authorAvatar)
                            as ImageProvider,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: isDark ? Colors.white : const Color(0xFF1F2937),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.post.designation ?? 'Product Designer'} • ${widget.post.timeAgo ?? '3h ago'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : const Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(LucideIcons.layoutGrid, size: 24, color: isDark ? Colors.grey[500] : const Color(0xFF4B5563)),
                ],
              ),
            ),

            // ── Content Text ──────────────────────────────────────────────
            if (widget.post.content != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  widget.post.content!,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: isDark ? Colors.grey[200] : const Color(0xFF374151),
                    fontFamily: 'Inter',
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],

            // ── Main Image ────────────────────────────────────────────────
            if (widget.post.imageUrl != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: widget.post.imageUrl!,
                    cacheManager: CacheManagers.postCacheManager,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImageLoading(240, isDark),
                    errorWidget: (context, url, error) => Container(
                       height: 200,
                       color: isDark ? Colors.grey[800] : Colors.grey[100],
                       child: const Icon(LucideIcons.imageOff),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ── Action Bar ───────────────────────────────────────────────
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
    );
  }

  Widget _buildImageLoading(double height, bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[200]!,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
