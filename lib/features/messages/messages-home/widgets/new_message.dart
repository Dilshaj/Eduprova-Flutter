import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String searchQuery = '';

  static final users = [
    {
      'id': '1',
      'name': 'Alice Johnson',
      'title': 'Product Designer',
      'status': 'online',
      'avatar': 'https://i.pravatar.cc/100?u=alice',
      'isGroup': false,
    },
    {
      'id': '2',
      'name': 'Bob Chen',
      'title': 'Frontend Developer',
      'status': 'away',
      'avatar': 'https://i.pravatar.cc/100?u=bob',
      'isGroup': false,
    },
    {
      'id': '3',
      'name': 'Carol Smith',
      'title': 'UX Researcher',
      'status': 'busy',
      'avatar': 'https://i.pravatar.cc/100?u=carol',
      'isGroup': false,
    },
    {
      'id': '6',
      'name': 'Design Team',
      'members': 24,
      'avatar': '',
      'initials': 'DT',
      'isGroup': true,
    },
    {
      'id': '7',
      'name': 'Marketing Hub',
      'members': 10,
      'avatar': '',
      'initials': 'MH',
      'isGroup': true,
    },
  ];

  List<Map<String, dynamic>> get filteredContacts {
    return users
        .cast<Map<String, dynamic>>()
        .where(
          (u) => (u['name'] as String).toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF9FAFB),
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
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'New Message',
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

            // Search bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () => _searchFocusNode.requestFocus(),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(
                        Icons.search_outlined,
                        size: 22,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (v) => setState(() => searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search for people or groups',
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF9CA3AF),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Create Group
                    _QuickOption(
                      icon: Icons.group_add_outlined,
                      label: 'Create New Group',
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                    // New Contact
                    _QuickOption(
                      icon: Icons.person_add_outlined,
                      label: 'New Contact',
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'RECENT CONTACTS',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9CA3AF),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...filteredContacts.map((user) {
                      final isGroup = user['isGroup'] as bool;
                      final status = user['status'] as String? ?? 'online';
                      return GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  isGroup
                                      ? Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: user['id'] == '6'
                                                ? const LinearGradient(
                                                    colors: [
                                                      Color(0xFFEEEEEE),
                                                      Color(0xFFBDBDBD),
                                                    ],
                                                  )
                                                : const LinearGradient(
                                                    colors: [
                                                      Color(0xFF0066FF),
                                                      Color(0xFFE056FD),
                                                    ],
                                                  ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            user['initials'] as String,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: user['id'] == '6'
                                                  ? const Color(0xFF555555)
                                                  : Colors.white,
                                            ),
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 24,
                                          backgroundImage: NetworkImage(
                                            user['avatar'] as String,
                                          ),
                                        ),
                                  if (!isGroup)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: status == 'online'
                                              ? const Color(0xFF10B981)
                                              : status == 'away'
                                              ? const Color(0xFFF59E0B)
                                              : const Color(0xFFEF4444),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
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
                                    Text(
                                      user['name'] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF111111),
                                      ),
                                    ),
                                    Text(
                                      isGroup
                                          ? '${user['members']} Members'
                                          : (status == 'online'
                                                ? 'Available'
                                                : status == 'away'
                                                ? 'Away'
                                                : 'Busy'),
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: Color(0xFFD1D5DB),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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

class _QuickOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 24, color: const Color(0xFF6B7280)),
          ),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111111),
              ),
            ),
          ),
          const Icon(Icons.chevron_right, size: 20, color: Color(0xFFD1D5DB)),
        ],
      ),
    );
  }
}
