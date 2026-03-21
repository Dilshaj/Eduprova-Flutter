import 'package:flutter/material.dart';

String mapCategoryToType(String? category) {
  if (category == null) return 'general';
  final cat = category.toLowerCase();
  if (cat.contains('study')) return 'study';
  if (cat.contains('design') || cat.contains('art')) return 'design';
  if (cat.contains('coding') || cat.contains('dev')) return 'dev';
  return 'general';
}

IconData getIconForCategory(String? category) {
  switch (mapCategoryToType(category)) {
    case 'study':
      return Icons.menu_book;
    case 'design':
      return Icons.palette;
    case 'dev':
      return Icons.code;
    default:
      return Icons.groups_outlined;
  }
}

final List<Map<String, dynamic>> initialCommunities = const [];
