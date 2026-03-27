import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hugeicons/hugeicons.dart';

class VideoPreviewWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPreviewWidget({super.key, required this.videoUrl});

  @override
  State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  late VideoPlayerController _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize()
          .then((_) {
            if (mounted) setState(() {});
          })
          .catchError((_) {
            if (mounted) {
              setState(() {
                _isError = true;
              });
            }
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;

    if (_isError) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedAlert01,
                color: theme.colorScheme.error,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load video',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_controller.value.isInitialized) {
      return SizedBox(
        height: 200,
        child: Shimmer.fromColors(
          baseColor: themeExt.cardColor,
          highlightColor: theme.dividerColor,
          child: Container(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_controller.value.isPlaying)
            Container(
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedPlay,
                color: Colors.white,
                size: 32,
              ),
            ),
        ],
      ),
    );
  }
}
