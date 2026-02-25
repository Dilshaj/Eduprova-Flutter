import 'package:flutter/material.dart';

class CoursesBottomTab extends StatelessWidget {
  const CoursesBottomTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(
              icon: Icons.chat_bubble_outline,
              label: 'Messages',
              isActive: false,
            ),
            _buildTabItem(
              icon: Icons.people_outline,
              label: 'Communities',
              isActive: false,
            ),
            _buildTabItem(
              icon: Icons.calendar_today_outlined,
              label: 'Calendar',
              isActive: false,
            ),
            _buildTabItem(
              icon: Icons.bar_chart_outlined,
              label: 'Activity',
              isActive: false,
            ),
            _buildTabItem(icon: Icons.school, label: 'Courses', isActive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    final color = isActive ? const Color(0xFF0066FF) : const Color(0xFF9CA3AF);
    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
