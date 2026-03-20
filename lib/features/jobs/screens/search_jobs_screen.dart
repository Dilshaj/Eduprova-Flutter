import 'package:eduprova/features/jobs/providers/job_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class SearchJobsScreen extends ConsumerStatefulWidget {
  const SearchJobsScreen({super.key});

  @override
  ConsumerState<SearchJobsScreen> createState() => _SearchJobsScreenState();
}

class _SearchJobsScreenState extends ConsumerState<SearchJobsScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    if (value.trim().isEmpty) return;
    
    // Update filters
    ref.read(jobFiltersProvider.notifier).update(
          ref.read(jobFiltersProvider).copyWith(keyword: value),
        );
    
    // Add to recent searches logic would go here
    
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Center(
          child: IconButton(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: Color(0xFF64748B),
              size: 24,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onSubmitted: _onSearch,
          decoration: InputDecoration(
            hintText: 'Search jobs, skills, companies...',
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      size: 20,
                      color: Color(0xFF64748B),
                    ),
                    onPressed: () {
                      _controller.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          onChanged: (val) => setState(() {}),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha:0.05) : const Color(0xFFF1F5F9),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Searches Section
            _buildSectionHeader('Recent Searches'),
            _buildRecentSearches(),
            
            const SizedBox(height: 24),
            
            // Popular Skills/Chips Section
            _buildSectionHeader('Trending Skills'),
            _buildTrendingSkills(),
            
            const SizedBox(height: 24),
            
            // Quick Categories
            _buildSectionHeader('Explore Categories'),
            _buildQuickCategories(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF94A3B8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    // Dummy Data for now
    final recent = ['Flutter Developer', 'UI/UX Designer', 'React Native'];
    
    return Column(
      children: recent.map((term) => ListTile(
        leading: const Icon(Icons.history, size: 20, color: Color(0xFF94A3B8)),
        title: Text(
          term,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.north_west, size: 16, color: Color(0xFFCBD5E1)),
        onTap: () {
          _controller.text = term;
          _onSearch(term);
        },
      )).toList(),
    );
  }

  Widget _buildTrendingSkills() {
    final skills = ['Python', 'SQL', 'Management', 'AWS', 'Design', 'Marketing'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills.map((skill) => ActionChip(
          label: Text(skill),
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          onPressed: () {
            _onSearch(skill);
          },
        )).toList(),
      ),
    );
  }

  Widget _buildQuickCategories() {
    final List<Map<String, dynamic>> categories = [
      {'icon': HugeIcons.strokeRoundedHome01, 'label': 'Remote'},
      {'icon': HugeIcons.strokeRoundedBuilding03, 'label': 'MNCs'},
      {'icon': HugeIcons.strokeRoundedFlash, 'label': 'Startups'},
      {'icon': HugeIcons.strokeRoundedMoney02, 'label': 'High Salary'},
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return InkWell(
            onTap: () {
              // Map to filters
              _onSearch(cat['label'] as String);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF8FAFC),
              ),
              child: Row(
                children: [
                  HugeIcon(
                    icon: cat['icon'] as List<List<dynamic>>,
                    color: const Color(0xFF3067FF),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat['label'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
