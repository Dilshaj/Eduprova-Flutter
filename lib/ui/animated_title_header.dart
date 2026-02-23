import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimatedTitleHeader extends ConsumerStatefulWidget {
  final List<String> titles;
  final String initialTitle;
  final ValueChanged<String>? onTitleChanged;

  const AnimatedTitleHeader({
    super.key,
    required this.titles,
    required this.initialTitle,
    this.onTitleChanged,
  });

  @override
  ConsumerState<AnimatedTitleHeader> createState() =>
      _AnimatedTitleHeaderState();
}

class _AnimatedTitleHeaderState extends ConsumerState<AnimatedTitleHeader>
    with SingleTickerProviderStateMixin {
  late String _currentTitle;
  bool _isExpanded = false;

  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _titleFadeAnimation;
  late final Animation<Offset> _titleSlideAnimation;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.initialTitle;
    _controller = AnimationController(
      vsync: this,
      duration: const .new(milliseconds: 250),
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _titleFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        // curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
        curve: Curves.easeInOut,
      ),
    );
    _titleSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const .new(-0.2, 0.0)).animate(
          CurvedAnimation(
            parent: _controller,
            // curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _selectTitle(String title) {
    setState(() {
      _currentTitle = title;
    });
    _toggleExpand();
    widget.onTitleChanged?.call(title);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 60,
      padding: const .symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: .centerLeft,
              children: [
                // Title (slides and fades out to the left)
                SlideTransition(
                  position: _titleSlideAnimation,
                  child: FadeTransition(
                    opacity: _titleFadeAnimation,
                    child: IgnorePointer(
                      ignoring: _isExpanded,
                      child: Text(
                        _currentTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: .bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),

                // Horizontal list of staggered chips
                if (_isExpanded || !_controller.isDismissed)
                  SingleChildScrollView(
                    scrollDirection: .horizontal,
                    child: Row(
                      children: [
                        for (var (i, title) in widget.titles.indexed)
                          _StaggeredChip(
                            controller: _controller,
                            index: i,
                            total: widget.titles.length,
                            child: Padding(
                              padding: const .only(right: 8.0),
                              child: ActionChip(
                                label: Text(
                                  title,
                                  style: TextStyle(
                                    color: title == _currentTitle
                                        ? theme.colorScheme.primary
                                        : null,
                                    fontWeight: title == _currentTitle
                                        ? .bold
                                        : .normal,
                                  ),
                                ),
                                padding: .zero,
                                visualDensity: .compact,
                                onPressed: () => _selectTitle(title),
                                backgroundColor: title == _currentTitle
                                    ? theme.colorScheme.primaryContainer
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Toggle Button
          IconButton(
            onPressed: _toggleExpand,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: RotationTransition(
              turns: _rotationAnimation,
              child: const Icon(Icons.keyboard_arrow_down),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaggeredChip extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final int total;
  final Widget child;

  const _StaggeredChip({
    required this.controller,
    required this.index,
    required this.total,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = 0.2 + (index * 0.1).clamp(0.0, 0.4);
    final end = (start + 0.4).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: controller,
      // curve: .new(start, end, curve: Curves.easeOutBack),
      curve: Interval(start, end, curve: Curves.easeIn),
      // curve: Curves.easeInOut,
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0.5, start),
          end: Offset.zero,
        ).animate(animation),
        child: ScaleTransition(scale: animation, child: child),
      ),
    );
  }
}
