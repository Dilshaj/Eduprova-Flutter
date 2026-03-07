import 'package:flutter/material.dart';
import 'dart:async';

class CategoryTabs extends StatefulWidget {
  const CategoryTabs({super.key});

  @override
  State<CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs> {
  String activeCategory = 'IT & Software';
  bool showSubCategories = true;
  Timer? _timer;

  final Map<String, List<String>> subCategoriesMap = {
    'Development': [
      'Web Development',
      'Data Science',
      'Mobile Development',
      'Programming Languages',
      'Game Development',
    ],
    'Business': [
      'Entrepreneurship',
      'Communication',
      'Management',
      'Sales',
      'Strategy',
    ],
    'Finance & Accounting': [
      'Accounting',
      'Cryptocurrency',
      'Finance',
      'Investing',
      'Taxes',
    ],
    'IT & Software': [
      'IT Certifications',
      'Network & Security',
      'Hardware',
      'Operating Systems & Servers',
      'Other IT & Software',
    ],
    'Office Productivity': ['Microsoft', 'Apple', 'Google', 'SAP', 'Oracle'],
    'Personal Development': [
      'Transformation',
      'Productivity',
      'Leadership',
      'Career Development',
      'Happiness',
    ],
    'Design': [
      'Graphic Design',
      'Web Design',
      'UX/UI Design',
      '3D & Animation',
      'Fashion',
    ],
    'Marketing': [
      'Digital Marketing',
      'SEO',
      'Social Media Marketing',
      'Branding',
      'Analytics',
    ],
    'Health & Fitness': [
      'Fitness',
      'Yoga',
      'Mental Health',
      'Dieting',
      'Nutrition',
    ],
    'Music': [
      'Instruments',
      'Music Production',
      'Vocal',
      'Music Theory',
      'Techniques',
    ],
  };

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      showSubCategories = true;
    });
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          showSubCategories = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant CategoryTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subCategories = subCategoriesMap[activeCategory] ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: subCategories.map((category) {
                final isActive = category == activeCategory;
                return InkWell(
                  onTap: () {
                    setState(() {
                      activeCategory = category;
                    });
                    _startTimer();
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 32, bottom: 4),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isActive
                            ? const Color(0xFF0066FF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (subCategories.isNotEmpty && showSubCategories)
            Container(
              width: double.infinity,
              color: const Color(0xFF0066FF),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: subCategories.map((sub) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: InkWell(
                        onTap: () {},
                        child: Text(
                          sub,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
