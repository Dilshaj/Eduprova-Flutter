import 'package:flutter/material.dart';

class VideoControls extends StatefulWidget {
  final bool isPlaying;
  final int duration; // in milliseconds
  final int currentTime; // in milliseconds
  final bool isMuted;
  final bool isLoading;
  final VoidCallback onPlayPause;
  final ValueChanged<int> onSeek;
  final VoidCallback onSeekStart;
  final ValueChanged<int> onSeekComplete;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onSettingsPress;
  final VoidCallback onBackPress;
  final VoidCallback onHideControls;

  const VideoControls({
    super.key,
    required this.isPlaying,
    required this.duration,
    required this.currentTime,
    required this.isMuted,
    required this.isLoading,
    required this.onPlayPause,
    required this.onSeek,
    required this.onSeekStart,
    required this.onSeekComplete,
    required this.onToggleMute,
    required this.onToggleFullscreen,
    required this.onSettingsPress,
    required this.onBackPress,
    required this.onHideControls,
  });

  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  int scrubTime = 0;
  bool isScrubbingState = false;

  void handleScrubUpdate(int time) {
    setState(() {
      scrubTime = time;
    });
    widget.onSeek(time);
  }

  void handleScrubStart() {
    setState(() {
      isScrubbingState = true;
    });
    widget.onSeekStart();
  }

  void handleScrubEnd(int time) {
    setState(() {
      isScrubbingState = false;
    });
    widget.onSeekComplete(time);
  }

  String _formatTime(int millis) {
    if (millis < 0) return "0:00";
    final totalSeconds = millis ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 100,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),

        // Back Button
        Positioned(
          top: 20,
          left: 20,
          child: SafeArea(
            bottom: false,
            left: false,
            right: false,
            child: InkWell(
              onTap: widget.onBackPress,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),

        // Center Play/Pause Button
        Center(
          child: widget.isLoading
              ? const CircularProgressIndicator(color: Color(0xFF0066FF))
              : GestureDetector(
                  onTap: widget.onPlayPause,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
        ),

        // Bottom Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Time
                        Text(
                          '${_formatTime(isScrubbingState ? scrubTime : widget.currentTime)} / ${_formatTime(widget.duration)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // Right: Controls
                        Row(
                          children: [
                            IconButton(
                              onPressed: widget.onToggleMute,
                              icon: Icon(
                                widget.isMuted
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                color: Colors.white,
                                size: 22,
                              ),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: widget.onSettingsPress,
                              icon: const Icon(
                                Icons.settings_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: widget.onToggleFullscreen,
                              icon: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 22,
                              ),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Custom Scrubber
                  ScrubBar(
                    duration: widget.duration,
                    currentTime: widget.currentTime,
                    isScrubbingState: isScrubbingState,
                    onUpdate: handleScrubUpdate,
                    onStart: handleScrubStart,
                    onEnd: handleScrubEnd,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ScrubBar extends StatefulWidget {
  final int duration;
  final int currentTime;
  final bool isScrubbingState;
  final ValueChanged<int> onUpdate;
  final VoidCallback onStart;
  final ValueChanged<int> onEnd;

  const ScrubBar({
    super.key,
    required this.duration,
    required this.currentTime,
    required this.isScrubbingState,
    required this.onUpdate,
    required this.onStart,
    required this.onEnd,
  });

  @override
  State<ScrubBar> createState() => _ScrubBarState();
}

class _ScrubBarState extends State<ScrubBar> {
  double _width = 0;
  double _progress = 0;
  double _startProgress = 0;

  @override
  void didUpdateWidget(covariant ScrubBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isScrubbingState && widget.duration > 0) {
      _progress = (widget.currentTime / widget.duration).clamp(0.0, 1.0);
    }
  }

  void _handlePanStart(DragStartDetails details) {
    _startProgress = _progress;
    widget.onStart();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_width > 0) {
      double newProgress = _startProgress + (details.localPosition.dx / _width);
      setState(() {
        _progress = newProgress.clamp(0.0, 1.0);
      });
      int time = (_progress * widget.duration).toInt();
      widget.onUpdate(time);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    int finalTime = (_progress * widget.duration).toInt();
    widget.onEnd(finalTime);
  }

  String _formatTime(int millis) {
    if (millis < 0) return "0:00";
    final totalSeconds = millis ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth - 32; // 16 margin on each side
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 40,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            onTapDown: (details) {
              if (_width > 0) {
                widget.onStart();
                double newProgress = details.localPosition.dx / _width;
                setState(() {
                  _progress = newProgress.clamp(0.0, 1.0);
                });
                int time = (_progress * widget.duration).toInt();
                widget.onUpdate(time);
                widget.onEnd(time);
              }
            },
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Track Background
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Progress Fill
                Container(
                  height: 4,
                  width: _width * _progress,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Thumb
                Positioned(
                  left: (_width * _progress) - 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0066FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Bubble
                if (widget.isScrubbingState)
                  Positioned(
                    left: (_width * _progress) - 25,
                    bottom: 24,
                    child: Container(
                      width: 50,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _formatTime((_progress * widget.duration).toInt()),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
