import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MembersWidget extends StatelessWidget {
  const MembersWidget({super.key});

  static final members = [
    {
      'id': '1',
      'name': 'Alex Rivera',
      'role': 'Senior Product Designer',
      'label': 'MENTOR',
      'labelColor': Color(0xFFE0E7FF),
      'labelTextColor': Color(0xFF4338CA),
      'avatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
      'location': 'SF, CA',
      'tasks': 48,
      'status': 'online',
    },
    {
      'id': '2',
      'name': 'Rose Nguyen',
      'role': 'UX Design Student',
      'label': 'STUDENT',
      'labelColor': Color(0xFFF3F4F6),
      'labelTextColor': Color(0xFF374151),
      'avatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
      'location': 'Seattle, WA',
      'tasks': 12,
      'status': 'offline',
    },
    {
      'id': '3',
      'name': 'James Chen',
      'role': 'Interface Specialist',
      'label': 'STUDENT',
      'labelColor': Color(0xFFF3F4F6),
      'labelTextColor': Color(0xFF374151),
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
      'location': 'New York, NY',
      'tasks': 31,
      'status': 'online',
    },
    {
      'id': '4',
      'name': 'Sarah K.',
      'role': 'Creative Director',
      'label': 'MENTOR',
      'labelColor': Color(0xFFFDF2F8),
      'labelTextColor': Color(0xFFBE185D),
      'avatar': null,
      'initials': 'SK',
      'location': 'London, UK',
      'tasks': 124,
      'status': 'online',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Members',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          Text(
            '1,248 active designers in the hub',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by name, role, or skills...',
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Members List
          ...members.map(
            (member) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      member['avatar'] != null
                          ? Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    member['avatar'] as String,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFCE7F3),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                member['initials'] as String? ?? '',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF9D174D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: member['status'] == 'online'
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFD1D5DB),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                member['name'] as String,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: const Color(0xFF111827),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: member['labelColor'] as Color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                member['label'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: member['labelTextColor'] as Color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          member['role'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '📍 ${member['location']}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '👥 ${member['tasks']}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Show More
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            alignment: Alignment.center,
            child: Text(
              'Show More Members',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
