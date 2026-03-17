import 'package:flutter/material.dart';

String mapCategoryToType(String? category) {
  if (category == null) return 'scratch';
  final cat = category.toLowerCase();
  if (cat.contains('study')) return 'study';
  if (cat.contains('art') || cat.contains('design')) return 'design';
  if (cat.contains('coding')) return 'dev';
  if (cat.contains('career')) return 'study';
  if (cat.contains('networking')) return 'study';
  return 'scratch';
}

IconData getIconForCategory(String? category) {
  switch (category) {
    case 'Study Groups':
      return Icons.menu_book;
    case 'Career Growth':
      return Icons.trending_up;
    case 'Networking':
      return Icons.people;
    case 'Project Collab':
      return Icons.extension;
    case 'Art & Design':
      return Icons.palette;
    case 'Coding Hub':
      return Icons.code;
    case 'Social & Fun':
      return Icons.celebration;
    case 'Mentorship':
      return Icons.school;
    default:
      return Icons.hub;
  }
}

final List<Map<String, dynamic>> initialCommunities = [
  {
    'id': '1',
    'name': 'Design Hub',
    'members': '48 members',
    'type': 'design',
    'icon': Icons.palette,
    'channels': [
      {'id': 'c1', 'name': 'Announcements', 'type': 'broadcast'},
      {'id': 'c2', 'name': 'General', 'type': 'discussion'},
      {'id': 'c3', 'name': 'Resources', 'type': 'discussion'},
      {'id': 'c4', 'name': 'Projects', 'type': 'discussion'},
    ],
  },
  {
    'id': '2',
    'name': 'Dev Community',
    'members': '120 members',
    'type': 'dev',
    'icon': Icons.code,
    'channels': [
      {'id': 'c5', 'name': 'Announcements', 'type': 'broadcast'},
      {'id': 'c6', 'name': 'General', 'type': 'discussion'},
      {'id': 'c7', 'name': 'Backend', 'type': 'discussion'},
      {'id': 'c8', 'name': 'Frontend', 'type': 'discussion'},
    ],
  },
  {
    'id': '3',
    'name': 'Study Group',
    'members': '34 members',
    'type': 'study',
    'icon': Icons.menu_book,
    'channels': [
      {'id': 'c9', 'name': 'Announcements', 'type': 'broadcast'},
      {'id': 'c10', 'name': 'General', 'type': 'discussion'},
      {'id': 'c11', 'name': 'Notes', 'type': 'discussion'},
    ],
  },
];
