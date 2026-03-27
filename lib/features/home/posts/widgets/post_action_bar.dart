import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:eduprova/features/home/posts/post_provider.dart';
import 'package:eduprova/features/home/posts/widgets/comment_sheet.dart';
import 'package:eduprova/features/home/posts/widgets/share_sheet.dart';
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

class _PostActionBarState extends ConsumerState<PostActionBar>
    with TickerProviderStateMixin {
  late AnimationController _likeController;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _handleLike() {
    _likeController.forward(from: 0);
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
      builder: (context) =>
          ShareSheet(postId: widget.postId, content: widget.content),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Like Action
              _buildImageActionItem(
                widget.isLiked ? 'assets/eduprovaE.png' : 'assets/like.png',
                widget.likeCount,
                onTap: _handleLike,
                isActive: widget.isLiked,
                iconSize: 20,
              ),
              const SizedBox(width: 20),

              // Comment Action
              _buildImageActionItem(
                'assets/comments.png',
                widget.commentCount,
                onTap: _showComments,
                iconSize: 28,
              ),
              const SizedBox(width: 20),

              // Repost Action
              _buildImageActionItem(
                'assets/repost.png',
                0, // Backend might not provide this yet
                onTap: () {},
                iconSize: 22,
              ),
              const SizedBox(width: 20),

              // Share Action
              _buildImageActionItem(
                'assets/share.png',
                0, // Backend might not provide this yet
                onTap: _showShare,
                iconSize: 20,
              ),
            ],
          ),

          // Save Action
          IconButton(
            onPressed: () {
              ref.read(postsProvider.notifier).toggleSave(widget.postId);
            },
            icon: Icon(
              LucideIcons.bookmark,
              size: 22,
              color: isDark ? Colors.grey[400] : const Color(0xFF94A3B8),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageActionItem(
    String assetPath,
    int count, {
    bool isActive = false,
    VoidCallback? onTap,
    double iconSize = 24,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Image.asset(
                assetPath,
                width: iconSize,
                height: iconSize,
                color: (assetPath.contains('eduprovaE') || isActive)
                    ? null
                    : (isDark ? Colors.grey[400] : const Color(0xFF94A3B8)),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            count > 0 ? count.toString() : '0',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? const Color(0xFF3B82F6)
                  : (isDark ? Colors.grey[400] : const Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }
}
