import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:eduprova/features/home/posts/post_provider.dart';
import 'package:eduprova/features/home/posts/widgets/comment_sheet.dart';
import 'package:eduprova/features/home/posts/widgets/share_sheet.dart';

class PostActionBar extends ConsumerStatefulWidget {
  final String postId;
  final String content;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const PostActionBar({
    super.key,
    required this.postId,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
  });

  @override
  ConsumerState<PostActionBar> createState() => _PostActionBarState();
}

class _PostActionBarState extends ConsumerState<PostActionBar> with TickerProviderStateMixin {
  late final AnimationController _likeController;
  late final Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _likeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _likeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _handleLike() {
    if (!widget.isLiked) {
      _likeController.forward(from: 0);
    }
    ref.read(postsProvider.notifier).toggleLike(widget.postId);
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentSheet(
        postId: widget.postId,
        initialCount: widget.commentCount,
      ),
    );
  }

  void _showShare() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareSheet(postId: widget.postId, content: widget.content),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.grey[400] : const Color(0xFF6B7280);
    final activeColor = const Color(0xFF3B82F6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Actions ────────────────────────────────────────────────────────
          _buildActionItem(
            'Likes',
            LucideIcons.messageSquare, // Matching image LABEL "Likes" with CHAT icon
            isActive: widget.isLiked,
            onTap: _handleLike,
            color: widget.isLiked ? activeColor : color,
            isAnimated: true,
          ),
          const SizedBox(width: 24),
          _buildActionItem(
             'Comments',
            LucideIcons.tv, // Using TV icon as it looks like the one in the reference image (monitor-ish)
            onTap: _showComments,
            color: color,
          ),
          const SizedBox(width: 24),
          _buildActionItem(
            'Repost',
            LucideIcons.rotateCcw,
            onTap: () {},
            color: color,
          ),
          const SizedBox(width: 24),
          _buildActionItem(
            'Share',
            LucideIcons.share2,
            onTap: _showShare,
            color: color,
          ),

          const Spacer(),

          // ── Likes Count ────────────────────────────────────────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
               RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.likeCount > 1000 ? (widget.likeCount / 1000).toStringAsFixed(0) : widget.likeCount}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF4B5563),
                        fontFamily: 'Inter',
                      ),
                    ),
                    TextSpan(
                      text: widget.likeCount > 1000 ? 'k Likes' : ' Likes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.grey[500] : const Color(0xFF9CA3AF),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    String label,
    IconData icon, {
    bool isActive = false,
    VoidCallback? onTap,
    Color? color,
    bool isAnimated = false,
  }) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isAnimated)
          ScaleTransition(
            scale: _likeScale,
            child: Icon(icon, size: 24, color: color),
          )
        else
          Icon(icon, size: 24, color: color),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );

    return InkWell(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: content,
    );
  }
}
