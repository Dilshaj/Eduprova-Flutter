import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduprova/routes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../messages/live_call_screen.dart';
import '../providers/chat_socket_provider.dart';

class IncomingCallOverlay extends ConsumerWidget {
  const IncomingCallOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final call = ref.watch(
      chatSocketProvider.select((state) => state.incomingCall),
    );
    if (call == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Glassmorphic Background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0F172A).withOpacity(0.8),
                      const Color(0xFF1E293B).withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Avatar with Glow
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF6366F1,
                              ).withOpacity(0.3 * value),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: const Color(0xFF1E293B),
                          backgroundImage: call.callerAvatar != null
                              ? NetworkImage(call.callerAvatar!)
                              : null,
                          child: call.callerAvatar == null
                              ? Text(
                                  call.callerName.isNotEmpty
                                      ? call.callerName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Name and Subtitle
                Text(
                  call.callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitle(call.conversationType).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),

                const Spacer(),

                // Actions
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 64,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Decline Button
                      _CallActionButton(
                        onPressed: () {
                          ref
                              .read(chatSocketProvider.notifier)
                              .emitCallRejected(call);
                        },
                        icon: LucideIcons.phoneOff,
                        label: 'Decline',
                        color: const Color(0xFFEF4444),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                      ),

                      // Answer Button
                      _CallActionButton(
                        onPressed: () {
                          final notifier = ref.read(
                            chatSocketProvider.notifier,
                          );
                          notifier.emitCallAccepted(call);

                          final navigator = rootNavigatorKey.currentState;
                          if (navigator != null) {
                            notifier.clearIncomingCall();
                            navigator.push(
                              MaterialPageRoute(
                                builder: (_) => LiveCallScreen(
                                  roomName: call.roomName,
                                  initialVideo: call.conversationType != 'dm',
                                  initialAudio: true,
                                ),
                              ),
                            );
                          }
                        },
                        icon: LucideIcons.phone,
                        label: 'Answer',
                        color: const Color(0xFF22C55E),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                        ),
                        isRinging: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _subtitle(String type) => switch (type) {
    'dm' => 'Incoming direct call',
    'group' => 'Incoming group call',
    _ => 'Incoming meeting invitation',
  };
}

class _CallActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final Gradient gradient;
  final bool isRinging;

  const _CallActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
    required this.gradient,
    this.isRinging = false,
  });

  @override
  State<_CallActionButton> createState() => _CallActionButtonState();
}

class _CallActionButtonState extends State<_CallActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isRinging) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isRinging)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 80 * (1 + _controller.value * 0.5),
                    height: 80 * (1 + _controller.value * 0.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withOpacity(
                        0.3 * (1 - _controller.value),
                      ),
                    ),
                  );
                },
              ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.gradient,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  customBorder: const CircleBorder(),
                  child: Icon(widget.icon, color: Colors.white, size: 32),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
