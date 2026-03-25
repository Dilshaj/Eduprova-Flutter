import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:eduprova/features/home/posts/post_provider.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:eduprova/features/home/posts/widgets/comment_sheet.dart';
import 'package:eduprova/features/home/posts/widgets/share_sheet.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

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
    _likeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _likeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 50),
    ]).animate(_likeController);
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
    final design = context.design;
    final colorScheme = context.colorScheme;
    final color = design.secondaryText.withValues(alpha: 0.6);
    final activeColor = colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildActionItem(
            'Likes',
            LucideIcons.messageSquare,
            isActive: widget.isLiked,
            onTap: _handleLike,
            color: widget.isLiked ? activeColor : color,
            isAnimated: true,
          ),
          const SizedBox(width: 24),
          _buildActionItem(
            'Comments',
            LucideIcons.monitor,
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
            LucideIcons.redo2,
            onTap: _showShare,
            color: color,
          ),
          const Spacer(),
          Text(
            '${widget.likeCount > 1000 ? (widget.likeCount / 1000).toStringAsFixed(0) : widget.likeCount}${widget.likeCount > 1000 ? 'k' : ''} Likes',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.5),
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
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
    return InkWell(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAnimated)
            ScaleTransition(
              scale: _likeScale,
              child: Icon(icon, size: 26, color: color),
            )
          else
            Icon(icon, size: 26, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: color,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    ).animate(target: isActive ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 200.ms);
  }
}
