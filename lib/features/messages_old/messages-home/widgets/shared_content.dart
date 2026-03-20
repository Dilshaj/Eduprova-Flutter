import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SharedContentScreen extends StatefulWidget {
  const SharedContentScreen({super.key});

  @override
  State<SharedContentScreen> createState() => _SharedContentScreenState();
}

class _SharedContentScreenState extends State<SharedContentScreen> {
  String activeTab = 'Media';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  static final mediaData = List.generate(
    20,
    (i) => 'https://picsum.photos/200/200?random=${i + 100}',
  );

  static final docsData = [
    {
      'id': '1',
      'name': 'Project_Requirement.pdf',
      'size': '2.4 MB',
      'date': '2 hours ago',
      'icon': Icons.picture_as_pdf,
      'color': const Color(0xFFEF4444),
      'older': false,
    },
    {
      'id': '2',
      'name': 'Lecture_Notes_Week3.docx',
      'size': '842 KB',
      'date': 'Yesterday',
      'icon': Icons.description,
      'color': const Color(0xFF0066FF),
      'older': false,
    },
    {
      'id': '3',
      'name': 'Budget_Proposal.xlsx',
      'size': '1.2 MB',
      'date': 'Oct 24, 2023',
      'icon': Icons.table_chart,
      'color': const Color(0xFF10B981),
      'older': false,
    },
    {
      'id': '4',
      'name': 'Final_Presentation_V2.pptx',
      'size': '15.7 MB',
      'date': 'Oct 22, 2023',
      'icon': Icons.slideshow,
      'color': const Color(0xFFF97316),
      'older': false,
    },
    {
      'id': '5',
      'name': 'Research_Paper_Draft.pdf',
      'size': '4.1 MB',
      'date': 'Oct 20, 2023',
      'icon': Icons.picture_as_pdf,
      'color': const Color(0xFFEF4444),
      'older': false,
    },
    {
      'id': '6',
      'name': 'Resources_Archive.zip',
      'size': '45.2 MB',
      'date': 'Sep 15, 2023',
      'icon': Icons.folder_zip,
      'color': const Color(0xFF6B7280),
      'older': true,
    },
  ];

  static final linksData = [
    {
      'id': '1',
      'title': 'Design Inspiration - Behance',
      'url': 'https://www.behance.net/galleries/ui-ux',
      'sharedBy': 'Rose Nguyen',
      'time': '03:17 pm',
      'icon': Icons.link,
      'color': const Color(0xFFE0F2FE),
      'iconColor': const Color(0xFF0EA5E9),
    },
    {
      'id': '2',
      'title': 'Mobile Design System v2.1',
      'url': 'https://figma.com/file/...',
      'sharedBy': 'Design Team',
      'time': '05:12 pm',
      'icon': Icons.design_services,
      'color': Colors.black,
      'iconColor': Colors.white,
    },
    {
      'id': '3',
      'title': 'Modern UI Trends for 2024',
      'url': 'https://medium.com/design/...',
      'sharedBy': 'Chester Martin',
      'time': '04:03 pm',
      'icon': Icons.article,
      'color': const Color(0xFFEEF2FF),
      'iconColor': const Color(0xFF6366F1),
    },
    {
      'id': '4',
      'title': 'React Hooks Masterclass',
      'url': 'https://udemy.com/course/...',
      'sharedBy': 'Robert Brewer',
      'time': '11:03 am',
      'icon': Icons.school,
      'color': const Color(0xFFFFEDD5),
      'iconColor': const Color(0xFFF97316),
    },
    {
      'id': '5',
      'title': 'Project Requirements Document',
      'url': 'https://docs.google.com/...',
      'sharedBy': 'Alma Pierce',
      'time': '02:33 pm',
      'icon': Icons.description,
      'color': const Color(0xFFECFDF5),
      'iconColor': const Color(0xFF10B981),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final imgSize = (screenWidth - 6) / 3;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.chevron_left,
                      size: 28,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Shared Content',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      size: 24,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Row(
                children: ['Media', 'Docs', 'Links'].map((tab) {
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
                                  ? const Color(0xFF0066FF)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tab,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isActive
                                ? const Color(0xFF0066FF)
                                : const Color(0xFF6B7280),
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
              child: activeTab == 'Media'
                  ? GridView.builder(
                      padding: const EdgeInsets.all(1),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 2,
                          ),
                      itemCount: mediaData.length,
                      itemBuilder: (ctx, i) =>
                          Image.network(mediaData[i], fit: BoxFit.cover),
                    )
                  : activeTab == 'Docs'
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RECENT',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF9CA3AF),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...docsData
                              .cast<Map<String, dynamic>>()
                              .where((d) => !(d['older'] as bool))
                              .map((doc) => _DocItem(doc: doc)),
                          const SizedBox(height: 24),
                          Text(
                            'OLDER',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF9CA3AF),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...docsData
                              .cast<Map<String, dynamic>>()
                              .where((d) => d['older'] as bool)
                              .map((doc) => _DocItem(doc: doc)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Search
                        GestureDetector(
                          onTap: () => _searchFocusNode.requestFocus(),
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  size: 20,
                                  color: Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    focusNode: _searchFocusNode,
                                    onChanged: (v) =>
                                        setState(() => searchQuery = v),
                                    decoration: InputDecoration.collapsed(
                                      hintText: 'Search links...',
                                      hintStyle: GoogleFonts.inter(
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                            children: linksData
                                .cast<Map<String, dynamic>>()
                                .where(
                                  (l) => (l['title'] as String)
                                      .toLowerCase()
                                      .contains(searchQuery.toLowerCase()),
                                )
                                .map((link) => _LinkItem(link: link))
                                .toList(),
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

class _DocItem extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _DocItem({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: (doc['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              doc['icon'] as IconData,
              size: 24,
              color: doc['color'] as Color,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['name'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${doc['size']} • ${doc['date']}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkItem extends StatelessWidget {
  final Map<String, dynamic> link;
  const _LinkItem({required this.link});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: link['color'] as Color,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              link['icon'] as IconData,
              size: 20,
              color: link['iconColor'] as Color,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link['title'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  link['url'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF0066FF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 8,
                      backgroundImage: NetworkImage(
                        'https://ui-avatars.com/api/?name=${link['sharedBy']}&background=random',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Shared by ${link['sharedBy']} • ${link['time']}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
