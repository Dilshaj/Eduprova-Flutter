import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class AppVideoPlayer extends StatefulWidget {
  final String? url;
  final String? muxPlaybackId;
  final bool autoPlay;

  const AppVideoPlayer({
    super.key,
    this.url,
    this.muxPlaybackId,
    this.autoPlay = true,
  });

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  late final Player player = Player();
  late final VideoController controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    String? mediaUrl = widget.url;

    if (widget.muxPlaybackId != null && widget.muxPlaybackId!.isNotEmpty) {
      mediaUrl = 'https://stream.mux.com/${widget.muxPlaybackId}.m3u8';
    }

    if (mediaUrl != null && mediaUrl.isNotEmpty) {
      player.open(Media(mediaUrl), play: widget.autoPlay);
    }
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.muxPlaybackId != widget.muxPlaybackId) {
      _initVideo();
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Video(
        controller: controller,
        fit: BoxFit.contain,
        controls: AdaptiveVideoControls,
      ),
    );
  }
}
