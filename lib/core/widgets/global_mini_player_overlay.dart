import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:eduprova/routes.dart';

import '../services/global_mini_player_service.dart';
import 'app_video_player.dart';

class GlobalMiniPlayerOverlay extends StatelessWidget {
  const GlobalMiniPlayerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GlobalMiniPlayerSession?>(
      valueListenable: GlobalMiniPlayerService.instance.session,
      builder: (context, session, child) {
        if (session == null) return const SizedBox.shrink();
        return _GlobalMiniPlayer(session: session);
      },
    );
  }
}

class _GlobalMiniPlayer extends StatefulWidget {
  final GlobalMiniPlayerSession session;

  const _GlobalMiniPlayer({required this.session});

  @override
  State<_GlobalMiniPlayer> createState() => _GlobalMiniPlayerState();
}

class _GlobalMiniPlayerState extends State<_GlobalMiniPlayer> {
  Player? _mediaPlayer;
  VideoController? _mediaController;
  vp.VideoPlayerController? _videoController;
  bool _ownsMediaPlayer = true;
  bool _ownsVideoController = true;
  bool _disposedPlayback = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.session.engine == AppVideoEngine.mediaKit) {
      final transferred = widget.session.mediaPlayer;
      final player = transferred ?? Player();
      _ownsMediaPlayer = transferred == null;
      final controller = VideoController(player);
      _mediaPlayer = player;
      _mediaController = controller;
      if (transferred == null) {
        await player.open(Media(widget.session.mediaUrl), play: false);
        await player.seek(widget.session.position);
        await player.setVolume(widget.session.volume * 100);
        if (widget.session.shouldPlay) {
          await player.play();
        }
      }
      if (mounted) setState(() {});
      return;
    }

    final transferredController = widget.session.videoPlayerController;
    final controller =
        transferredController ??
        vp.VideoPlayerController.networkUrl(Uri.parse(widget.session.mediaUrl));
    _ownsVideoController = transferredController == null;
    _videoController = controller;
    if (transferredController == null) {
      await controller.initialize();
      await controller.seekTo(widget.session.position);
      await controller.setVolume(widget.session.volume);
      if (widget.session.shouldPlay) {
        await controller.play();
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _disposePlayback(force: false);
    super.dispose();
  }

  Future<void> _closeMiniPlayerCompletely() async {
    await _disposePlayback(force: true);
    GlobalMiniPlayerService.instance.close();
  }

  Future<void> _disposePlayback({required bool force}) async {
    if (_disposedPlayback) return;
    _disposedPlayback = true;
    if (force || _ownsVideoController) {
      await _videoController?.pause();
      await _videoController?.dispose();
      _videoController = null;
    }
    if (force || _ownsMediaPlayer) {
      await _mediaPlayer?.pause();
      await _mediaPlayer?.dispose();
      _mediaPlayer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.of(context).padding;
    final width = (size.width * 0.42).clamp(168.0, 220.0);

    return Positioned(
      right: 12,
      bottom: padding.bottom + 12,
      width: width,
      child: Material(
        color: Colors.transparent,
        elevation: 8,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                Container(color: Colors.black),
                if (widget.session.engine == AppVideoEngine.mediaKit)
                  if (_mediaController != null)
                    Video(
                      controller: _mediaController!,
                      fit: BoxFit.cover,
                      controls: NoVideoControls,
                    ),
                if (widget.session.engine == AppVideoEngine.videoPlayer)
                  if (_videoController != null &&
                      _videoController!.value.isInitialized)
                    vp.VideoPlayer(_videoController!),
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final route = widget.session.restoreRoute;
                        if (route != null && route.isNotEmpty) {
                          final resumeMs = _currentPosition().inMilliseconds;
                          final autoplay = _isPlaying() ? '1' : '0';
                          final uri = Uri.parse(route);
                          final nextUri = uri.replace(
                            queryParameters: {
                              ...uri.queryParameters,
                              'resumeMs': '$resumeMs',
                              'autoplay': autoplay,
                              'fromMini': '1',
                            },
                          );
                          final navContext = rootNavigatorKey.currentContext;
                          final router = navContext != null
                              ? GoRouter.maybeOf(navContext)
                              : GoRouter.maybeOf(context);
                          if (router != null) {
                            GlobalMiniPlayerService.instance.hideForHandoff();
                            router.push(nextUri.toString());
                          }
                        }
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: _closeMiniPlayerCompletely,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Duration _currentPosition() {
    if (widget.session.engine == AppVideoEngine.mediaKit) {
      return _mediaPlayer?.state.position ?? widget.session.position;
    }
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      return controller.value.position;
    }
    return widget.session.position;
  }

  bool _isPlaying() {
    if (widget.session.engine == AppVideoEngine.mediaKit) {
      return _mediaPlayer?.state.playing ?? widget.session.shouldPlay;
    }
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      return controller.value.isPlaying;
    }
    return widget.session.shouldPlay;
  }
}
