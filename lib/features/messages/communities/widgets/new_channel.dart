import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewChannelScreen extends StatefulWidget {
  const NewChannelScreen({super.key});

  @override
  State<NewChannelScreen> createState() => _NewChannelScreenState();
}

class _NewChannelScreenState extends State<NewChannelScreen> {
  String privacy = 'public';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create New Channel',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Channels are where your community communicates.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Channel Name
                          Text(
                            'CHANNEL NAME',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Text(
                                    '#',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'e.g. projects',
                                      hintStyle: GoogleFonts.inter(
                                        color: const Color(0xFF94A3B8),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Description
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'DESCRIPTION',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF94A3B8),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                '(optional)',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                hintText: 'What is this channel about?',
                                hintStyle: GoogleFonts.inter(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: const Color(0xFF475569),
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Privacy Settings
                          Text(
                            'PRIVACY SETTINGS',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              // Public
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => privacy = 'public'),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: privacy == 'public'
                                          ? const Color(
                                              0xFFEFF6FF,
                                            ).withOpacity(0.5)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: privacy == 'public'
                                            ? const Color(0xFF0066FF)
                                            : const Color(0xFFF1F5F9),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFDBEAFE),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(12),
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.public,
                                                size: 20,
                                                color: Color(0xFF0066FF),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Public',
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Anyone in the hub can join',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: const Color(0xFF64748B),
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (privacy == 'public')
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Icon(
                                              Icons.check_circle,
                                              size: 16,
                                              color: const Color(0xFF0066FF),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),

                              // Private
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => privacy = 'private'),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: privacy == 'private'
                                          ? const Color(0xFFF8FAFC)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: privacy == 'private'
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFFF1F5F9),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(12),
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.lock_outlined,
                                                size: 20,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Private',
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Invite only channel access',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: const Color(0xFF64748B),
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (privacy == 'private')
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: const Icon(
                                              Icons.check_circle,
                                              size: 16,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0066FF), Color(0xFFC026D3)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0066FF).withOpacity(0.3),
                          blurRadius: 10,
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
                            'Create Channel',
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
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
