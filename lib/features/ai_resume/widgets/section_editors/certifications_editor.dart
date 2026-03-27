import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../providers/resume_provider.dart';
import '../../models/resume_data.dart';
import 'certification_item_editor.dart';
import 'section_list_editor.dart';

class CertificationsEditor extends ConsumerWidget {
  const CertificationsEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certifications = ref
        .watch(resumeProvider)
        .sections
        .certifications
        .items;

    return SectionListEditor<CertificationItem>(
      title: 'Certifications',
      sectionKey: 'certifications',
      items: certifications,
      idGetter: (item) => item.id,
      emptyStateIcon: LucideIcons.award,
      emptyStateTitle: 'No certifications added yet',
      emptyStateButtonText: 'Add Certification',
      onAdd: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CertificationItemEditor(),
          ),
        );
      },
      onEdit: (item) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CertificationItemEditor(item: item),
          ),
        );
      },
      titleBuilder: (context, item) =>
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitleBuilder: (context, item) => Column(
        crossAxisAlignment: .start,
        children: [
          if (item.issuer.isNotEmpty)
            Text(item.issuer, style: const TextStyle(fontSize: 12)),
          if (item.date.isNotEmpty)
            Text(item.date, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
