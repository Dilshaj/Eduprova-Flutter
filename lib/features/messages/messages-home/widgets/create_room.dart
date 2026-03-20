import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateRoomScreen extends StatelessWidget {
  const CreateRoomScreen({super.key});

  static const link = 'meet.pro.edu/room/x92-kLp';
  static const participants = [
    'https://i.pravatar.cc/100?u=1',
    'https://i.pravatar.cc/100?u=2',
    'https://i.pravatar.cc/100?u=3',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.chevron_left,
                      size: 28,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Create Room',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // Video Icon Circle
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF9FAFB),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.videocam_outlined,
                            size: 56,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Room is ready',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Invite your participants and start\nyour professional session.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Participants
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PARTICIPANTS',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF9CA3AF),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ...participants.map(
                                    (url) => Container(
                                      width: 44,
                                      height: 44,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        image: DecorationImage(
                                          image: NetworkImage(url),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                      color: Colors.white,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.add,
                                      size: 20,
                                      color: Color(0xFF555555),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Manage',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111111),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Link Box
                    Container(
                      height: 52,
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              link,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF374151),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Clipboard.setData(
                              const ClipboardData(text: link),
                            ),
                            child: Container(
                              height: 40,
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.copy_outlined,
                                    size: 16,
                                    color: Color(0xFF111111),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Copy',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF111111),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Share/Chat buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.share_outlined,
                                  size: 20,
                                  color: Color(0xFF111111),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Share via',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111111),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.chat_bubble_outline,
                                  size: 20,
                                  color: Color(0xFF111111),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Chat',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111111),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Expanded(child: SizedBox()),

                    // Join Room button
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0066FF).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              'Join Room',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 100,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
