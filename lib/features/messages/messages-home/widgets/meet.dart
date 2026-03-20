import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_link.dart';
import 'schedule_meeting.dart';
import 'join_with_id.dart';

class MeetScreen extends StatefulWidget {
  const MeetScreen({super.key});

  @override
  State<MeetScreen> createState() => _MeetScreenState();
}

class _MeetScreenState extends State<MeetScreen> {
  String activeTab = 'All';
  String searchQuery = '';
  bool isSearchActive = false;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  static final recentCalls = [
    {
      'id': '1',
      'name': 'Person 1',
      'duration': '0sec',
      'time': '10:48',
      'initials': 'P1',
      'color': const Color(0xFFDBEAFE),
      'textColor': const Color(0xFF0066FF),
      'type': 'outgoing',
      'category': 'Calls',
    },
    {
      'id': '2',
      'name': 'Person 1',
      'duration': '11sec',
      'time': '10:41',
      'initials': 'P2',
      'color': const Color(0xFFFCE7F3),
      'textColor': const Color(0xFFDB2777),
      'type': 'outgoing',
      'category': 'Calls',
    },
    {
      'id': '3',
      'name': 'Person 1',
      'duration': '0sec',
      'time': '10:40',
      'initials': 'P3',
      'color': const Color(0xFFF3F4F6),
      'textColor': const Color(0xFF4B5563),
      'type': 'outgoing',
      'category': 'Calls',
    },
    {
      'id': '4',
      'name': 'Person 7',
      'duration': '0sec',
      'time': '09:12',
      'initials': 'P7',
      'color': const Color(0xFFF3E8FF),
      'textColor': const Color(0xFF9333EA),
      'type': 'outgoing',
      'category': 'Calls',
    },
    {
      'id': '5',
      'name': 'Person 7',
      'duration': 'Missed',
      'time': 'Yesterday',
      'initials': 'P7',
      'color': const Color(0xFFFEF3C7),
      'textColor': const Color(0xFFD97706),
      'type': 'missed',
      'category': 'Calls',
    },
    {
      'id': '6',
      'name': 'Design Sync',
      'duration': 'Scheduled',
      'time': '12:00 PM',
      'initials': 'DS',
      'color': const Color(0xFFE0F2F1),
      'textColor': const Color(0xFF00695C),
      'type': 'scheduled',
      'category': 'Scheduled',
    },
    {
      'id': '7',
      'name': 'My Personal Room',
      'duration': 'Link',
      'time': 'Created',
      'initials': 'L',
      'color': const Color(0xFFE3F2FD),
      'textColor': const Color(0xFF1565C0),
      'type': 'link',
      'category': 'Links',
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredCalls {
    var calls = recentCalls.cast<Map<String, dynamic>>();
    if (activeTab != 'All') {
      calls = calls.where((c) => c['category'] == activeTab).toList();
    }
    if (searchQuery.isNotEmpty) {
      calls = calls
          .where(
            (c) => (c['name'] as String).toLowerCase().contains(
              searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }
    return calls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SizedBox(
                height: 70,
                child: isSearchActive
                    ? GestureDetector(
                        onTap: () => searchFocusNode.requestFocus(),
                        child: Container(
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
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Icon(
                                  Icons.search,
                                  size: 22,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  focusNode: searchFocusNode,
                                  autofocus: true,
                                  onChanged: (v) =>
                                      setState(() => searchQuery = v),
                                  decoration: InputDecoration(
                                    hintText: 'Search calls...',
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
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSearchActive = false;
                                    searchQuery = '';
                                    searchController.clear();
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Icon(
                                    Icons.cancel,
                                    size: 20,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.chevron_left,
                              size: 28,
                              color: Color(0xFF1F2937),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Meet',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111111),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => isSearchActive = true),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.search,
                                size: 24,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action Cards
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Row(
                        children: [
                          _ActionCard(
                            icon: Icons.link,
                            label: 'Create link',
                            iconBg: const Color(0xFFEFF6FF),
                            iconColor: const Color(0xFF0066FF),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreateLinkScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _ActionCard(
                            icon: Icons.calendar_today,
                            label: 'Schedule',
                            iconBg: const Color(0xFFFCE7F3),
                            iconColor: const Color(0xFFDB2777),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ScheduleMeetingScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _ActionCard(
                            icon: Icons.grid_view,
                            label: 'Join with ID',
                            iconBg: const Color(0xFFF3F4F6),
                            iconColor: const Color(0xFF4B5563),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const JoinWithIdScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Filter Tabs
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: ['All', 'Links', 'Scheduled', 'Calls'].map((
                          tab,
                        ) {
                          final isActive = activeTab == tab;
                          return GestureDetector(
                            onTap: () => setState(() => activeTab = tab),
                            child: Container(
                              height: 40,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: isActive
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF0066FF),
                                          Color(0xFFE056FD),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      )
                                    : null,
                                color: isActive
                                    ? null
                                    : const Color(0xFFF3F4F6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                tab,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? Colors.white
                                      : const Color(0xFF1F2937),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Calls List Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            activeTab == 'All' ? 'Recent calls' : activeTab,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111111),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'See all',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0066FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Calls List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: filteredCalls
                            .map((item) => _CallItem(item: item))
                            .toList(),
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 24, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallItem extends StatelessWidget {
  final Map<String, dynamic> item;
  const _CallItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final type = item['type'] as String;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item['color'] as Color,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: type == 'link'
                ? Icon(Icons.link, size: 20, color: item['textColor'] as Color)
                : type == 'scheduled'
                ? Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: item['textColor'] as Color,
                  )
                : Text(
                    item['initials'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: item['textColor'] as Color,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (type == 'missed')
                      const Icon(
                        Icons.call_missed,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                    if (type == 'outgoing')
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                    const SizedBox(width: 4),
                    Text(
                      type == 'missed'
                          ? 'Missed'
                          : type == 'link'
                          ? 'Permanent Link'
                          : type == 'scheduled'
                          ? 'Scheduled Call'
                          : 'Duration: ${item['duration']}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            item['time'] as String,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
