import 'package:eduprova/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduprova/core/utils/image_cache_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'post_provider.dart';

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
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    final author = map['authorId'] as Map<String, dynamic>?;
    final media = (map['media'] as List?)?.firstOrNull as Map<String, dynamic>?;

    return .new(
      id: map['_id'] ?? '',
      name: author != null
          ? '${author['firstName'] ?? ''} ${author['lastName'] ?? ''}'.trim()
          : 'Anonymous',
      designation: author?['designation'] ?? 'Student',
      timeAgo: _formatTimeAgo(map['createdAt']),
      content: map['caption'],
      imageUrl: media?['url'],
      authorAvatar: author?['avatar'] ?? 'assets/avatars/1.png',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      isSaved: map['isSaved'] ?? false,
      mediaType: media?['type'],
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
  ConsumerState<ConsumerStatefulWidget> createState() => _PostState();
}

class _PostState extends ConsumerState<Post> {
  @override
  Widget build(BuildContext context) {
    const double padding = 12;
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: themeExt.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const .all(padding),
                child: Row(
                  crossAxisAlignment: .start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: widget.post.authorAvatar.startsWith('http')
                          ? CachedNetworkImageProvider(
                              widget.post.authorAvatar,
                              cacheManager: CacheManagers.avatarCacheManager,
                            )
                          : AssetImage(widget.post.authorAvatar) as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            widget.post.name,
                            style: const .new(
                              fontWeight: .w600,
                              fontSize: 17,
                            ),
                          ),
                          if (widget.post.designation != null ||
                              widget.post.timeAgo != null)
                            Text(
                              '${widget.post.designation ?? ''} • ${widget.post.timeAgo ?? ''}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_vert),
                  ],
                ),
              ),
              if (widget.post.content != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const .symmetric(horizontal: padding),
                  child: Text(
                    widget.post.content!,
                    style: const .new(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
                if (widget.post.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: .infinity,
                    height: 200,
                    child: ClipRRect(
                      child: CachedNetworkImage(
                        imageUrl: widget.post.imageUrl!,
                        cacheManager: CacheManagers.postCacheManager,
                        fit: .cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                ],
              const SizedBox(height: 16),
              Padding(
                padding: const .symmetric(horizontal: padding),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => ref.read(postsProvider.notifier).toggleLike(widget.post.id),
                      child: _buildActionItem(
                        widget.post.isLiked
                            ? HugeIcons.strokeRoundedFavourite
                            : HugeIcons.strokeRoundedFavourite,
                        'Likes',
                        color: widget.post.isLiked ? Colors.red : null,
                      ),
                    ),
                    const SizedBox(width: 24),
                    _buildActionItem(
                      HugeIcons.strokeRoundedComment02,
                      'Comments',
                    ),
                    const SizedBox(width: 24),
                    _buildActionItem(HugeIcons.strokeRoundedRepeat, 'Repost'),
                    const SizedBox(width: 24),
                    _buildActionItem(
                      HugeIcons.strokeRoundedLinkForward,
                      'Share',
                    ),
                    const Spacer(),
                    Text(
                      '${widget.post.likeCount} Likes',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(List<List<dynamic>> icon, String label, {Color? color}) {
    return Column(
      mainAxisSize: .min,
      children: [
        HugeIcon(icon: icon, size: 22, color: color),
        const SizedBox(height: 4),
        Text(label, style: .new(fontSize: 10, color: color)),
      ],
    );
  }
}
