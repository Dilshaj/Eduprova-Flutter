import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduprova/core/utils/image_cache_manager.dart';
import 'package:eduprova/features/home/posts/comment_model.dart';
import 'package:eduprova/features/home/posts/comment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CommentSheet extends ConsumerStatefulWidget {
  final String postId;
  final int initialCount;

  const CommentSheet({
    super.key,
    required this.postId,
    required this.initialCount,
  });

  @override
  ConsumerState<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends ConsumerState<CommentSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasTxt = _controller.text.trim().isNotEmpty;
      if (hasTxt != _hasText) setState(() => _hasText = hasTxt);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _focusNode.unfocus();
    await ref.read(allCommentsProvider.notifier).addComment(widget.postId, text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final comments = ref.watch(commentsProvider(widget.postId));
    final bg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final surface = isDark ? const Color(0xFF111827) : const Color(0xFFF3F7FF);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ───────────────────────────────────────────────────
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${comments.comments.length + widget.initialCount}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Comment List ──────────────────────────────────────────────────
          Flexible(
            child: comments.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3B82F6),
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : comments.comments.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(LucideIcons.messageCircle,
                                size: 40,
                                color: isDark
                                    ? Colors.grey[600]
                                    : Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text(
                              'Be the first to comment!',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: comments.comments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (context, i) {
                          return _CommentTile(
                            comment: comments.comments[i],
                            postId: widget.postId,
                            isDark: isDark,
                          );
                        },
                      ),
          ),

          // ── Input area ────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: bg,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.grey.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: const AssetImage('assets/avatars/1.png'),
                  backgroundColor: isDark
                      ? const Color(0xFF374151)
                      : const Color(0xFFF3F4F6),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[200]
                                  : const Color(0xFF1F2937),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Write a comment…',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[400],
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            maxLines: 4,
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _submit(),
                          ),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _hasText ? 1 : 0,
                          child: GestureDetector(
                            onTap: _submit,
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF3B82F6),
                                    Color(0xFFA855F7)
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.send,
                                size: 16,
                                color: Colors.white,
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
          ),
        ],
      ),
    );
  }
}

// ─── Single Comment Tile ──────────────────────────────────────────────────────

class _CommentTile extends ConsumerWidget {
  final CommentModel comment;
  final String postId;
  final bool isDark;

  const _CommentTile({
    required this.comment,
    required this.postId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundImage: comment.authorAvatar.startsWith('http')
                ? CachedNetworkImageProvider(
                    comment.authorAvatar,
                    cacheManager: CacheManagers.avatarCacheManager,
                  )
                : AssetImage(comment.authorAvatar) as ImageProvider,
            backgroundColor:
                isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
          ),
          const SizedBox(width: 10),

          // Bubble
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF111827)
                        : const Color(0xFFF3F7FF),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.authorName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.text,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: isDark
                              ? Colors.grey[300]
                              : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      CommentModel.formatTimeAgo(comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => ref
                          .read(allCommentsProvider.notifier)
                          .toggleLike(postId, comment.id),
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 13,
                            color: comment.isLiked
                                ? const Color(0xFFEF4444)
                                : (isDark ? Colors.grey[500] : Colors.grey[400]),
                          ),
                          if (comment.likeCount > 0) ...[
                            const SizedBox(width: 3),
                            Text(
                              '${comment.likeCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color: comment.isLiked
                                    ? const Color(0xFFEF4444)
                                    : (isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[400]),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
