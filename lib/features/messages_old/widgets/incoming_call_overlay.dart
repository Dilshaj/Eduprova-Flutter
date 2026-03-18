import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduprova/routes.dart';

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

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFE2E8F0),
                    backgroundImage: call.callerAvatar != null
                        ? NetworkImage(call.callerAvatar!)
                        : null,
                    child: call.callerAvatar == null
                        ? Text(
                            call.callerName.isNotEmpty
                                ? call.callerName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          call.callerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _subtitle(call.conversationType),
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      ref.read(chatSocketProvider.notifier).emitCallRejected(call);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFEE2E2),
                      foregroundColor: const Color(0xFFB91C1C),
                    ),
                    icon: const Icon(Icons.call_end),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      final notifier = ref.read(chatSocketProvider.notifier);
                      notifier.emitCallAccepted(call);

                      final navigator = rootNavigatorKey.currentState;
                      if (navigator == null) {
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Unable to open the call screen right now.',
                            ),
                          ),
                        );
                        return;
                      }

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
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFDCFCE7),
                      foregroundColor: const Color(0xFF166534),
                    ),
                    icon: const Icon(Icons.call),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _subtitle(String type) => switch (type) {
    'dm' => 'Incoming direct call',
    'group' => 'Incoming group call',
    _ => 'Incoming meeting invitation',
  };
}
