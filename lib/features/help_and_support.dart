import 'package:eduprova/features/courses/widgets/skeleton_loader.dart';
import 'package:eduprova/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class FAQItem {
  final String id;
  final String question;
  final String answer;
  final String category;

  FAQItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });
}

class SupportOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;

  SupportOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  bool isLoading = true;
  String searchQuery = '';
  String? expandedFAQ;
  String activeCategory = 'All';

  final List<String> categories = [
    'All',
    'Courses',
    'Payments',
    'Account',
    'Certificates',
  ];

  final List<FAQItem> faqData = [
    FAQItem(
      id: '1',
      question: 'How do I enroll in a course?',
      answer:
          'Browse our course catalog, select a course you like, and click "Enroll Now" or "Add to Cart". You can pay using any of our supported payment methods including UPI, cards, and net banking.',
      category: 'Courses',
    ),
    FAQItem(
      id: '2',
      question: 'Can I get a refund after purchasing?',
      answer:
          'Yes! We offer a 7-day refund policy. If you\'re not satisfied with the course, you can request a refund within 7 days of purchase. Refunds are processed within 5-7 business days.',
      category: 'Payments',
    ),
    FAQItem(
      id: '3',
      question: 'How do I download course materials?',
      answer:
          'Navigate to the course content page, go to the "Resources" tab, and tap the download icon next to any available material. Downloaded files are saved to your device.',
      category: 'Courses',
    ),
    FAQItem(
      id: '4',
      question: 'How do I reset my password?',
      answer:
          'Go to Settings > Account > Change Password. Enter your current password, then your new password twice to confirm. You\'ll receive a confirmation email once updated.',
      category: 'Account',
    ),
    FAQItem(
      id: '5',
      question: 'Can I access courses offline?',
      answer:
          'Yes! Premium courses can be downloaded for offline viewing. Look for the download icon on the video player. Downloaded content is available for 30 days without internet.',
      category: 'Courses',
    ),
    FAQItem(
      id: '6',
      question: 'How do certificates work?',
      answer:
          'Upon completing all modules and passing the final assessment with 70% or above, you\'ll receive a verified digital certificate. Certificates can be shared directly to LinkedIn.',
      category: 'Certificates',
    ),
  ];

  final List<SupportOption> supportOptions = [
    SupportOption(
      id: '1',
      title: 'Live Chat',
      subtitle: 'Chat with our support team',
      icon: Icons.chat_bubble_outline,
      color: Colors.blue,
      bgColor: Colors.blue.withValues(alpha: 0.1),
    ),
    SupportOption(
      id: '2',
      title: 'Email Support',
      subtitle: 'support@eduprova.com',
      icon: Icons.mail_outline,
      color: Colors.purple,
      bgColor: Colors.purple.withValues(alpha: 0.1),
    ),
    SupportOption(
      id: '3',
      title: 'Call Us',
      subtitle: '+91 98765 43210',
      icon: Icons.call_outlined,
      color: Colors.green,
      bgColor: Colors.green.withValues(alpha: 0.1),
    ),
    SupportOption(
      id: '4',
      title: 'Community Forum',
      subtitle: 'Ask the community',
      icon: Icons.people_outline,
      color: Colors.orange,
      bgColor: Colors.orange.withValues(alpha: 0.1),
    ),
  ];

  final List<Map<String, dynamic>> quickLinks = [
    {
      'id': '1',
      'title': 'Getting Started Guide',
      'icon': Icons.rocket_launch_outlined,
    },
    {'id': '2', 'title': 'Video Tutorials', 'icon': Icons.play_circle_outline},
    {'id': '3', 'title': 'Privacy Policy', 'icon': Icons.shield_outlined},
    {
      'id': '4',
      'title': 'Terms of Service',
      'icon': Icons.description_outlined,
    },
    {'id': '5', 'title': 'Report a Bug', 'icon': Icons.bug_report_outlined},
  ];

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> handleSupportPress(SupportOption option) async {
    if (option.title == 'Email Support') {
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'support@eduprova.com',
      );
      launchUrl(emailLaunchUri);
    } else if (option.title == 'Call Us') {
      final Uri phoneLaunchUri = Uri(scheme: 'tel', path: '+919876543210');
      launchUrl(phoneLaunchUri);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(option.title),
          content: Text('${option.subtitle} — Feature coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeExt = theme.extension<AppDesignExtension>()!;

    if (isLoading) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: themeExt.scaffoldBackgroundColor,
          body: const SafeArea(child: HelpSupportSkeleton()),
        ),
      );
    }

    final filteredFAQs = faqData.where((faq) {
      final matchesSearch =
          faq.question.toLowerCase().contains(searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          activeCategory == 'All' || faq.category == activeCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: theme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: themeExt.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: themeExt.borderColor,
                            width: 1.5,
                          ),
                          color: themeExt.cardColor,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      'Help & Support',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 38), // Placeholder
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Banner
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ).copyWith(bottom: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(24).copyWith(bottom: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.headset_mic_outlined,
                                  size: 28,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'How can we help?',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Search our knowledge base or browse FAQs below',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.85),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Search Bar
                            Container(
                              height: 46,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    size: 20,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (text) =>
                                          setState(() => searchQuery = text),
                                      controller:
                                          TextEditingController(
                                              text: searchQuery,
                                            )
                                            ..selection =
                                                TextSelection.fromPosition(
                                                  TextPosition(
                                                    offset: searchQuery.length,
                                                  ),
                                                ),
                                      decoration: InputDecoration(
                                        hintText: 'Search for help...',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.6,
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (searchQuery.isNotEmpty)
                                    InkWell(
                                      onTap: () =>
                                          setState(() => searchQuery = ''),
                                      child: Icon(
                                        Icons.cancel,
                                        size: 20,
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Contact Support Options
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ).copyWith(bottom: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contact Us',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 14),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.4,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: supportOptions.length,
                              itemBuilder: (context, index) {
                                final option = supportOptions[index];
                                return InkWell(
                                  onTap: () => handleSupportPress(option),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: themeExt.cardColor,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: themeExt.borderColor,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: themeExt.shadowColor,
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: option.bgColor,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            option.icon,
                                            size: 22,
                                            color: option.color,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          option.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          option.subtitle,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: themeExt.secondaryText,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // FAQ Section
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ).copyWith(bottom: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Frequently Asked Questions',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Category Chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: categories.map((cat) {
                                  final isActive = activeCategory == cat;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: InkWell(
                                      onTap: () =>
                                          setState(() => activeCategory = cat),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? colorScheme.primary
                                              : themeExt.cardColor,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: isActive
                                              ? null
                                              : Border.all(
                                                  color: themeExt.borderColor,
                                                ),
                                        ),
                                        child: Text(
                                          cat,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isActive
                                                ? Colors.white
                                                : themeExt.secondaryText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            // FAQ Items
                            if (filteredFAQs.isEmpty)
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 30,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: 48,
                                      color: themeExt.borderColor,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No results found',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: themeExt.secondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Try a different search term',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: themeExt.borderColor,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ...filteredFAQs.map((faq) {
                                final isExpanded = expandedFAQ == faq.id;
                                return InkWell(
                                  onTap: () => setState(
                                    () => expandedFAQ = isExpanded
                                        ? null
                                        : faq.id,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: themeExt.cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isExpanded
                                            ? colorScheme.primary
                                            : themeExt.borderColor,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                faq.question,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: colorScheme.onSurface,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: isExpanded
                                                    ? colorScheme.primary
                                                    : themeExt.cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: isExpanded
                                                    ? null
                                                    : Border.all(
                                                        color: themeExt
                                                            .borderColor,
                                                      ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Icon(
                                                isExpanded
                                                    ? Icons.remove
                                                    : Icons.add,
                                                size: 16,
                                                color: isExpanded
                                                    ? Colors.white
                                                    : themeExt.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (isExpanded)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 12,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                top: 12,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  top: BorderSide(
                                                    color: themeExt.borderColor,
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    faq.answer,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: themeExt
                                                          .secondaryText,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: themeExt.cardColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        color: themeExt
                                                            .borderColor,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .bookmark_outline,
                                                          size: 12,
                                                          color: themeExt
                                                              .secondaryText,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          faq.category,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: themeExt
                                                                .secondaryText,
                                                          ),
                                                        ),
                                                      ],
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
                              }),
                          ],
                        ),
                      ),

                      // Quick Links
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ).copyWith(bottom: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Links',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              decoration: BoxDecoration(
                                color: themeExt.cardColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: themeExt.borderColor),
                              ),
                              child: Column(
                                children: quickLinks.asMap().entries.map((
                                  entry,
                                ) {
                                  final idx = entry.key;
                                  final link = entry.value;
                                  return InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text(link['title']),
                                          content: const Text(
                                            'This section will open soon!',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: Text(
                                                'OK',
                                                style: TextStyle(
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        border: idx < quickLinks.length - 1
                                            ? Border(
                                                bottom: BorderSide(
                                                  color: themeExt.borderColor,
                                                ),
                                              )
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              link['icon'],
                                              size: 18,
                                              color: const Color(0xFF6B7280),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Text(
                                              link['title'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            size: 18,
                                            color: themeExt.borderColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Still Need Help? CTA
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ).copyWith(bottom: 20),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: themeExt.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: themeExt.borderColor),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.chat_outlined,
                                  size: 28,
                                  color: Color(0xFF0066FF),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Still need help?',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Our support team is available 24/7 to assist you with any questions or issues.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: themeExt.secondaryText,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Support'),
                                      content: const Text(
                                        'Connecting you to a support agent...',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text(
                                            'OK',
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF0066FF),
                                        Color(0xFFE056FD),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Start a Conversation',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // App Version
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Eduprova v2.1.0',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: themeExt.borderColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
