import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduprova/core/utils/image_cache_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:eduprova/features/home/posts/widgets/post_action_bar.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:eduprova/features/home/posts/widgets/pdf_preview_widget.dart';
import 'package:eduprova/features/home/posts/widgets/video_preview_widget.dart';
import 'post_provider.dart';

class LikedByUser {
  final String firstName;
  final String? avatar;

  LikedByUser({required this.firstName, this.avatar});

  factory LikedByUser.fromMap(Map<String, dynamic> map) {
    return LikedByUser(
      firstName: map['firstName'] ?? 'User',
      avatar: map['avatar'],
    );
  }
}

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
  final List<LikedByUser>? likedBy;
  final bool isFollowingAuthor;
  final bool isOwnPost;
  final String? audioUrl;
  final String? locationName;
  final List<String>? hashtags;
  final List<String>? pdfThumbnails;
  final String? audioTitle;

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
    this.likedBy,
    this.isFollowingAuthor = false,
    this.isOwnPost = false,
    this.audioUrl,
    this.locationName,
    this.hashtags,
    this.pdfThumbnails,
    this.audioTitle,
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
    List<LikedByUser>? likedBy,
    bool? isFollowingAuthor,
    bool? isOwnPost,
    String? audioUrl,
    String? locationName,
    List<String>? hashtags,
    List<String>? pdfThumbnails,
    String? audioTitle,
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
      likedBy: likedBy ?? this.likedBy,
      isFollowingAuthor: isFollowingAuthor ?? this.isFollowingAuthor,
      isOwnPost: isOwnPost ?? this.isOwnPost,
      audioUrl: audioUrl ?? this.audioUrl,
      locationName: locationName ?? this.locationName,
      hashtags: hashtags ?? this.hashtags,
      pdfThumbnails: pdfThumbnails ?? this.pdfThumbnails,
      audioTitle: audioTitle ?? this.audioTitle,
    );
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    final authorRaw = map['authorId'];
    final Map<String, dynamic>? author = authorRaw is Map<String, dynamic>
        ? authorRaw
        : null;
    final mediaRaw = map['media'];
    final List<dynamic> allMedia = mediaRaw is List ? mediaRaw : [];

    final List<String> imageUrls = [];
    String? videoUrl;
    String? pdfUrl;

    for (var m in allMedia) {
      if (m is Map<String, dynamic>) {
        final type = m['type'];
        final url = m['url']?.toString();
        if (url != null) {
          if (type == 'video' || type == 'video/mp4') {
            videoUrl = url;
          } else if (type == 'pdf' || type == 'application/pdf') {
            pdfUrl = url;
          } else {
            imageUrls.add(url);
          }
        }
      }
    }

    final likedByData = map['likedBy'] as List?;
    final likedBy = likedByData
        ?.map((l) => l is Map<String, dynamic> ? LikedByUser.fromMap(l) : null)
        .whereType<LikedByUser>()
        .toList();

    return PostModel(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      name: author != null
          ? '${author['firstName'] ?? ''} ${author['lastName'] ?? ''}'.trim()
          : (map['authorName'] ?? 'Anonymous'),
      designation: author?['designation'] ?? 'Student',
      timeAgo: _formatTimeAgo(map['createdAt']?.toString()),
      content: map['caption'] ?? map['content'] ?? '',
      imageUrl: imageUrls.isNotEmpty
          ? imageUrls.first
          : (map['imageUrl']?.toString()),
      images: imageUrls.length > 1 ? imageUrls : null,
      videoUrl: videoUrl ?? map['videoUrl']?.toString(),
      pdfUrl: pdfUrl ?? map['pdfUrl']?.toString(),
      authorAvatar:
          author?['avatar'] ?? map['authorAvatar'] ?? 'assets/avatars/1.png',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      isSaved: map['isSaved'] ?? false,
      mediaType:
          map['fileType']?.toString() ??
          (allMedia.isNotEmpty ? allMedia.first['type']?.toString() : null),
      likedBy: likedBy,
      isFollowingAuthor: map['isFollowingAuthor'] ?? false,
      isOwnPost: map['isOwnPost'] ?? false,
      pdfThumbnails: (map['pdfThumbnails'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      audioUrl: map['audio']?['url']?.toString(),
      audioTitle: map['audio']?['title']?.toString(),
      locationName: map['location']?['name']?.toString(),
      hashtags: (map['hashtags'] as List?)?.map((e) => e.toString()).toList(),
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

  static String sanitizeCaption(String? text) {
    if (text == null) return '';

    String processed = text;

    // Handle Ordered Lists (<ol><li>...</li></ol>) - Use a cleaner single-newline approach
    if (processed.contains('<ol>')) {
      int counter = 1;
      processed = processed.replaceAllMapped(RegExp(r'<li>(.*?)</li>'), (
        match,
      ) {
        return '${counter++}. ${match.group(1)}\n';
      });
      processed = processed.replaceAll(RegExp(r'<ol[^>]*>|</ol>'), '');
    }

    // Handle Block Tags and remaining list items without double-spacing
    processed = processed
        .replaceAll(RegExp(r'</p>|</div>|<br\s*/?>'), '\n')
        .replaceAll(
          RegExp(r'<li>'),
          '',
        ) // <li> handled by mapped replacement or stripped
        .replaceAll(RegExp(r'<ul>|</ul>'), '');

    // Strip remaining tags
    processed = processed.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');

    // Normalize newlines (no more than one consecutive newline)
    processed = processed.replaceAll(RegExp(r'\n{2,}'), '\n');

    // Trim extra newlines
    return processed.trim();
  }
}

class _PostState extends ConsumerState<Post> {
  bool _isExpanded = false;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isAudioLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.post.audioUrl != null) {
      _initAudio();
    }
  }

  Future<void> _initAudio() async {
    setState(() => _isAudioLoading = true);
    _audioPlayer = AudioPlayer();
    try {
      await _audioPlayer!.setLoopMode(LoopMode.one);
      await _audioPlayer!.setUrl(widget.post.audioUrl!);
      _audioPlayer!.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            _isAudioLoading =
                state.processingState == ProcessingState.loading ||
                state.processingState == ProcessingState.buffering;
          });
        }
      });
    } catch (e) {
      debugPrint('Error loading audio: $e');
    } finally {
      if (mounted) setState(() => _isAudioLoading = false);
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _toggleAudio() {
    if (_audioPlayer == null) return;
    if (_audioPlayer!.playing) {
      _audioPlayer!.pause();
    } else {
      _audioPlayer!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1F2937).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.zero,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: widget.post.authorAvatar.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: widget.post.authorAvatar,
                                cacheManager: CacheManagers.avatarCacheManager,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                widget.post.authorAvatar,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.name,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          _HeaderMetaCycle(
                            post: widget.post,
                            isPlaying: _isPlaying,
                            onToggle: _toggleAudio,
                          ),
                        ],
                      ),
                    ),
                    if (!widget.post.isOwnPost) ...[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(postsProvider.notifier)
                                .toggleFollow(widget.post.id);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: widget.post.isFollowingAuthor
                                  ? null
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFF3B82F6),
                                        Color(0xFF2563EB),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              color: widget.post.isFollowingAuthor
                                  ? (isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : const Color(0xFFF3F4F6))
                                  : null,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: !widget.post.isFollowingAuthor
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF3B82F6,
                                        ).withValues(alpha: 0.45),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                        spreadRadius: -2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.post.isFollowingAuthor
                                      ? LucideIcons.userMinus
                                      : LucideIcons.userPlus,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.post.isFollowingAuthor
                                      ? 'Unfollow'
                                      : 'Follow',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 12),
                    IconButton(
                      icon: SizedBox(
                        width: 14,
                        height: 14,
                        child: CustomPaint(
                          painter: LayoutGridPainter(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Caption
              if (widget.post.content != null &&
                  widget.post.content!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      () {
                        final sanitizedContent = Post.sanitizeCaption(
                          widget.post.content,
                        );
                        final allLines = sanitizedContent
                            .split('\n')
                            .map((l) => l.trim())
                            .where((l) => l.isNotEmpty)
                            .toList();
                        final hasManyLines = allLines.length > 2;

                        final String displayContent;
                        if (_isExpanded || !hasManyLines) {
                          displayContent = sanitizedContent;
                        } else {
                          displayContent = '${allLines[0]}\n${allLines[1]}...';
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: hasManyLines
                                  ? () => setState(
                                      () => _isExpanded = !_isExpanded,
                                    )
                                  : null,
                              child: Text(
                                displayContent,
                                style: GoogleFonts.inter(
                                  fontSize:
                                      (widget.post.imageUrl == null &&
                                          widget.post.videoUrl == null)
                                      ? 16
                                      : 15,
                                  height: 1.35,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : const Color(0xFF374151),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                            if (hasManyLines)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: InkWell(
                                  onTap: () => setState(
                                    () => _isExpanded = !_isExpanded,
                                  ),
                                  child: Text(
                                    _isExpanded ? 'show less' : 'Read more',
                                    style: GoogleFonts.inter(
                                      color: _isExpanded
                                          ? (isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B))
                                          : const Color(0xFF3B82F6),
                                      fontWeight: _isExpanded
                                          ? FontWeight.w700
                                          : FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }(),
                      if (widget.post.hashtags != null &&
                          widget.post.hashtags!.isNotEmpty &&
                          (!Post.sanitizeCaption(
                                widget.post.content,
                              ).contains('#') ||
                              _isExpanded))
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Wrap(
                            spacing: 8,
                            children: widget.post.hashtags!
                                .map(
                                  (tag) => Text(
                                    '#$tag',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF2563EB),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Media
              // Media Section with Floating Audio Control
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  if (widget.post.videoUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                        child: VideoPreviewWidget(
                          videoUrl: widget.post.videoUrl!,
                        ),
                      ),
                    )
                  else if (widget.post.pdfUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                        child: PdfPreviewWidget(pdfUrl: widget.post.pdfUrl!),
                      ),
                    )
                  else if (widget.post.images != null &&
                      widget.post.images!.length > 1)
                    _buildImageGrid(widget.post.images!, isDark)
                  else if (widget.post.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.post.imageUrl!,
                          cacheManager: CacheManagers.postCacheManager,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              _buildImageLoading(260, isDark),
                          errorWidget: (context, url, error) =>
                              _buildImageError(),
                        ),
                      ),
                    ),

                  // Floating Audio Control
                  if (widget.post.audioUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0, bottom: 12.0),
                      child: GestureDetector(
                        onTap: _toggleAudio,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color:
                                (_isPlaying
                                        ? const Color(0xFF3B82F6)
                                        : Colors.black.withValues(alpha: 0.4))
                                    .withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Center(
                                child: _isAudioLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        _isPlaying
                                            ? LucideIcons.volume2
                                            : LucideIcons.volumeX,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Social Proof
              if (widget.post.likedBy != null &&
                  widget.post.likedBy!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.black.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        _StackedAvatars(likedBy: widget.post.likedBy!),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey[400]
                                    : const Color(0xFF64748B),
                              ),
                              children: [
                                const TextSpan(text: 'Liked by '),
                                TextSpan(
                                  text: widget.post.likedBy![0].firstName,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                if (widget.post.likeCount > 1) ...[
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: '${widget.post.likeCount - 1} others',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.9)
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Interaction Bar
              PostActionBar(
                postId: widget.post.id,
                content: widget.post.content ?? '',
                likeCount: widget.post.likeCount,
                commentCount: widget.post.commentCount,
                isLiked: widget.post.isLiked,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<String> images, bool isDark) {
    // Determine height based on image count and aspect ratio
    const double gridHeight = 320.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        height: gridHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left main image
            Expanded(flex: 2, child: _buildNetworkImage(images[0], isDark)),

            const SizedBox(width: 2), // Thin premium divider
            // Right column for 2 images
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildNetworkImage(
                      images.length > 1 ? images[1] : images[0],
                      isDark,
                    ),
                  ),
                  const SizedBox(height: 2), // Thin premium divider
                  Expanded(
                    child: images.length > 2
                        ? _buildNetworkImage(images[2], isDark)
                        : (images.length > 3
                              ? _buildNetworkImage(images[3], isDark)
                              : Container(
                                  color: isDark
                                      ? const Color(0xFF1F2937)
                                      : const Color(0xFFF1F5F9),
                                )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String url, bool isDark) {
    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: CacheManagers.postCacheManager,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          Container(color: context.design.skeletonBase),
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

class _HeaderMetaCycle extends StatefulWidget {
  final PostModel post;
  final bool isPlaying;
  final VoidCallback? onToggle;
  const _HeaderMetaCycle({
    required this.post,
    this.isPlaying = false,
    this.onToggle,
  });

  @override
  State<_HeaderMetaCycle> createState() => _HeaderMetaCycleState();
}

class _HeaderMetaCycleState extends State<_HeaderMetaCycle> {
  int _index = 0;

  @override
  void initState() {
    super.initState();

    if (widget.post.audioUrl != null || widget.post.locationName != null) {
      Stream.periodic(const Duration(seconds: 4)).listen((_) {
        if (mounted) {
          setState(() {
            _index++;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [
      Text(
        '${widget.post.designation ?? 'Member'} • ${widget.post.timeAgo ?? 'now'}',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: const Color(0xFF94A3B8),
          fontWeight: FontWeight.w600,
        ),
      ),
      if (widget.post.audioUrl != null)
        GestureDetector(
          onTap: widget.onToggle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 4),
              Icon(
                widget.isPlaying ? LucideIcons.volume2 : LucideIcons.volumeX,
                size: 10,
                color: widget.isPlaying
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF94A3B8),
              ),
              if (widget.isPlaying) ...[
                const SizedBox(width: 4),
                Text(
                  'PLAYING',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF3B82F6),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
        ),
      if (widget.post.locationName != null)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.mapPin, size: 10, color: Color(0xFF3B82F6)),
            const SizedBox(width: 4),
            Text(
              widget.post.locationName!,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF3B82F6),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
    ];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(_index),
        child: items[_index % items.length],
      ),
    );
  }
}

class _StackedAvatars extends StatelessWidget {
  final List<LikedByUser> likedBy;
  const _StackedAvatars({required this.likedBy});

  @override
  Widget build(BuildContext context) {
    final showCount = likedBy.length > 3 ? 3 : likedBy.length;
    return SizedBox(
      height: 24,
      width: (showCount * 14.0) + 10,
      child: Stack(
        children: List.generate(
          showCount,
          (index) => Positioned(
            left: index * 14.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 10,
                backgroundImage: CachedNetworkImageProvider(
                  likedBy[index].avatar ??
                      'https://api.dicebear.com/7.x/initials/svg?seed=${likedBy[index].firstName}',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LayoutGridPainter extends CustomPainter {
  final Color color;
  LayoutGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Left Column (Rectangle 1)
    canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.4, h), paint);

    // Top Right (Rectangle 2)
    canvas.drawRect(Rect.fromLTWH(w * 0.55, 0, w * 0.45, h * 0.55), paint);

    // Bottom Right (Rectangle 3)
    canvas.drawRect(Rect.fromLTWH(w * 0.55, h * 0.7, w * 0.45, h * 0.3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
