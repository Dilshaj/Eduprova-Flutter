import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  String searchQuery = '';
  List<String> selectedMembers = [];

  static final users = [
    {
      'id': '1',
      'name': 'Alice Johnson',
      'title': 'Product Designer',
      'avatar': 'https://i.pravatar.cc/100?u=alice',
    },
    {
      'id': '2',
      'name': 'Bob Chen',
      'title': 'Frontend Developer',
      'avatar': 'https://i.pravatar.cc/100?u=bob',
    },
    {
      'id': '3',
      'name': 'Carol Smith',
      'title': 'UX Researcher',
      'avatar': 'https://i.pravatar.cc/100?u=carol',
    },
    {
      'id': '4',
      'name': 'David Lee',
      'title': 'Backend Engineer',
      'avatar': 'https://i.pravatar.cc/100?u=david',
    },
    {
      'id': '5',
      'name': 'Emma Davis',
      'title': 'Project Manager',
      'avatar': 'https://i.pravatar.cc/100?u=emma',
    },
  ];

  void toggleMember(String id) {
    setState(() {
      if (selectedMembers.contains(id)) {
        selectedMembers.remove(id);
      } else {
        selectedMembers.add(id);
      }
    });
  }

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

  List<Map<String, dynamic>> get selectedUsers {
    return users
        .cast<Map<String, dynamic>>()
        .where((u) => selectedMembers.contains(u['id']))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chevron_left,
                              size: 24,
                              color: Color(0xFF0066FF),
                            ),
                            Text(
                              'Back',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: const Color(0xFF0066FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'New Group',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 60),
                    ],
                  ),
                ),

                // Search bar
                Container(
                  height: 48,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        size: 20,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => searchQuery = v),
                          decoration: InputDecoration(
                            hintText: 'Add members',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF9CA3AF),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Selected chips
                if (selectedMembers.isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: selectedUsers
                          .map(
                            (user) => Container(
                              margin: const EdgeInsets.only(right: 16),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              user['avatar'] as String,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (user['name'] as String).split(' ')[0],
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: const Color(0xFF4B5563),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () =>
                                          toggleMember(user['id'] as String),
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF9CA3AF),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.close,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                // Contacts list
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONTACTS',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF9CA3AF),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...filteredContacts.map((user) {
                          final isSelected = selectedMembers.contains(
                            user['id'],
                          );
                          return GestureDetector(
                            onTap: () => toggleMember(user['id'] as String),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          user['avatar'] as String,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          user['title'] as String,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? const Color(0xFF0066FF)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF0066FF)
                                            : const Color(0xFFD1D5DB),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
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

            // Footer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color(0xFFF9FAFB),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                child: Column(
                  children: [
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                size: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 134,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
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
