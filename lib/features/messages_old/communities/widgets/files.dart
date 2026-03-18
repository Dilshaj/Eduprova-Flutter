import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilesWidget extends StatelessWidget {
  const FilesWidget({super.key});

  static final recentFiles = [
    {
      'id': '1',
      'name': 'campus_event_j...',
      'size': '2.4 MB',
      'author': 'Alex Chen',
      'type': 'image',
      'color': Color(0xFFFEF3C7),
    },
    {
      'id': '2',
      'name': 'tutorial_v1.mp4',
      'size': '45.8 MB',
      'author': 'Rose N.',
      'type': 'video',
      'color': Color(0xFFF1F5F9),
    },
  ];

  static final documents = [
    {
      'id': '1',
      'name': 'Project_Brief_2024.docx',
      'type': 'DOCX',
      'size': '1.2 MB',
      'date': 'Oct 12, 2024',
      'color': Color(0xFFE0F2FE),
      'iconColor': Color(0xFF0284C7),
    },
    {
      'id': '2',
      'name': 'Exam_Guidelines.pdf',
      'type': 'PDF',
      'size': '3.4 MB',
      'date': 'Oct 10, 2024',
      'color': Color(0xFFFEE2E2),
      'iconColor': Color(0xFFDC2626),
    },
    {
      'id': '3',
      'name': 'Budget_Tracker.xlsx',
      'type': 'XLSX',
      'size': '450 KB',
      'date': 'Oct 05, 2024',
      'color': Color(0xFFDCFCE7),
      'iconColor': Color(0xFF16A34A),
    },
    {
      'id': '4',
      'name': 'Final_Presentation.pptx',
      'type': 'PPTX',
      'size': '8.2 MB',
      'date': 'Sep 28, 2024',
      'color': Color(0xFFFFEDD5),
      'iconColor': Color(0xFFEA580C),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      hintText: 'Search files, documents...',
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Files
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Files',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                'View All',
                style: GoogleFonts.inter(
                  color: const Color(0xFF0066FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentFiles.length,
              itemBuilder: (context, index) {
                final file = recentFiles[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 128,
                        width: 160,
                        decoration: BoxDecoration(
                          color: file['color'] as Color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: file['type'] == 'video'
                            ? Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.play_circle_outlined,
                                  size: 24,
                                  color: Color(0xFF64748B),
                                ),
                              )
                            : const Icon(
                                Icons.image_outlined,
                                size: 40,
                                color: Color(0xFF94A3B8),
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        file['name'] as String,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: const Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${file['size']} • ${file['author']}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Documents
          Text(
            'Documents',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),

          ...documents.map(
            (doc) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: doc['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.insert_drive_file,
                      size: 24,
                      color: doc['iconColor'] as Color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc['name'] as String,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${doc['type']} • ${doc['size']} • ${doc['date']}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
