import 'package:eduprova/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class PostModel {
  final String id;
  final String name;
  final String? designation;
  final String? timeAgo;
  final String? content;
  final String? imageUrl;
  final String authorAvatar;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.name,
    this.designation,
    this.timeAgo,
    required this.content,
    required this.imageUrl,
    required this.authorAvatar,
    required this.createdAt,
  });
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
                padding: const EdgeInsets.all(padding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage(widget.post.authorAvatar),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
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
                  padding: const EdgeInsets.symmetric(horizontal: padding),
                  child: Text(
                    widget.post.content!,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
              if (widget.post.imageUrl != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: ClipRRect(
                    // borderRadius: BorderRadius.vertical(
                    //   top: Radius.circular(padding),
                    // ),
                    child: Image.network(
                      widget.post.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: padding),
                child: Row(
                  children: [
                    _buildActionItem(HugeIcons.strokeRoundedFavourite, 'Likes'),
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
                      '12k Likes',
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

  Widget _buildActionItem(List<List<dynamic>> icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HugeIcon(icon: icon, size: 22),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
