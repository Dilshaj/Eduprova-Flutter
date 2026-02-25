import 'package:eduprova/core/navigation/app_routes.dart';
import 'package:eduprova/theme.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

class CoursesMenuModal extends StatefulWidget {
  final bool visible;
  final VoidCallback onClose;

  const CoursesMenuModal({
    super.key,
    required this.visible,
    required this.onClose,
  });

  @override
  State<CoursesMenuModal> createState() => _CoursesMenuModalState();
}

class _CoursesMenuModalState extends State<CoursesMenuModal> {
  String? selectedItem;

  final List<Map<String, dynamic>> menuItems = [
    {'id': 'MyCourses', 'label': 'My Courses', 'icon': Icons.menu_book},
    {'id': 'Wishlist', 'label': 'Wishlist', 'icon': Icons.favorite_border},
    {'id': 'Billing', 'label': 'Billing & Payments', 'icon': Icons.credit_card},
    {
      'id': 'Profile',
      'label': 'Profile Settings',
      'icon': Icons.person_outline,
    },
    {'id': 'Help', 'label': 'Help & Support', 'icon': Icons.info_outline},
  ];

  void handlePress(Map<String, dynamic> item) {
    setState(() {
      selectedItem = item['id'];
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      widget.onClose();
      if (item['id'] == 'MyCourses') {
        context.push(AppRoutes.myLearning, extra: {'tab': 'Ongoing'});
      } else if (item['id'] == 'Wishlist') {
        context.push(AppRoutes.myWishlist);
      } else if (item['id'] == 'Billing') {
        context.push(AppRoutes.billingAndPayments);
      } else if (item['id'] == 'Profile') {
        context.push(AppRoutes.profileSettings);
      } else if (item['id'] == 'Help') {
        context.push(AppRoutes.helpAndSupport);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(color: Colors.black.withValues(alpha: 0.2)),
            ),
          ),
          Positioned(
            right: 20,
            top: 60, // approximate position below the header
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping inside the menu
              child: Container(
                width: 240,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeExt.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: themeExt.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: menuItems.map((item) {
                    final isSelected = selectedItem == item['id'];
                    return InkWell(
                      onTap: () => handlePress(item),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'],
                              size: 22,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item['label'],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
