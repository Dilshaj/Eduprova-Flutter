import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'posts.dart';
import 'files.dart';
import 'members.dart';
import 'events.dart';
import 'edit_community.dart';

class CommunityGroupScreen extends StatefulWidget {
  final String? communityName;
  final String? subtitle;
  const CommunityGroupScreen({super.key, this.communityName, this.subtitle});

  @override
  State<CommunityGroupScreen> createState() => _CommunityGroupScreenState();
}

class _CommunityGroupScreenState extends State<CommunityGroupScreen> {
  String activeTab = 'Posts';
  final tabs = ['Posts', 'Files', 'Members', 'Events'];

  Widget renderContent() {
    switch (activeTab) {
      case 'Posts':
        return const PostsWidget();
      case 'Files':
        return const FilesWidget();
      case 'Members':
        return const MembersWidget();
      case 'Events':
        return const EventsWidget();
      default:
        return const PostsWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with background image
          SizedBox(
            height: 260,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=900&fit=crop',
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.4),
                  colorBlendMode: BlendMode.darken,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'ELITE',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.notifications_none,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEDD5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'A',
                                    style: TextStyle(
                                      color: Color(0xFF7C2D12),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      'DESIGN',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade200,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.communityName ?? 'School Group',
                                    style: GoogleFonts.inter(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    widget.subtitle ??
                                        'Innovation & Collaboration Hub',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditCommunityScreen(
                                      communityName: widget.communityName,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: Row(
              children: tabs.map((tab) {
                final isActive = activeTab == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => activeTab = tab),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isActive
                                ? const Color(0xFF4F46E5)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tab,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isActive
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Content
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: renderContent(),
            ),
          ),
        ],
      ),
    );
  }
}
