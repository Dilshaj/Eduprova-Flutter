import 'package:eduprova/features/courses/widgets/skeleton_loader.dart';
import 'package:eduprova/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class PersonalInfo {
  final String firstName;
  final String lastName;
  final String bio;
  final String email;
  final String phone;
  final String location;

  PersonalInfo({
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.email,
    required this.phone,
    required this.location,
  });

  PersonalInfo copyWith({
    String? firstName,
    String? lastName,
    String? bio,
    String? email,
    String? phone,
    String? location,
  }) {
    return PersonalInfo(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
    );
  }
}

class ProfessionalInfo {
  final String headline;
  final String availability;
  final List<String> skills;
  final List<String> languages;
  final List<String> interests;

  ProfessionalInfo({
    required this.headline,
    required this.availability,
    required this.skills,
    required this.languages,
    required this.interests,
  });

  ProfessionalInfo copyWith({
    String? headline,
    String? availability,
    List<String>? skills,
    List<String>? languages,
    List<String>? interests,
  }) {
    return ProfessionalInfo(
      headline: headline ?? this.headline,
      availability: availability ?? this.availability,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      interests: interests ?? this.interests,
    );
  }
}

class ExperienceItem {
  final String id;
  final String title;
  final String company;
  final String period;
  final bool isCurrent;

  ExperienceItem({
    required this.id,
    required this.title,
    required this.company,
    required this.period,
    required this.isCurrent,
  });
}

class EducationItem {
  final String id;
  final String degree;
  final String institution;
  final String period;

  EducationItem({
    required this.id,
    required this.degree,
    required this.institution,
    required this.period,
  });
}

class SocialLink {
  final String id;
  final String platform;
  final String url;
  final IconData icon;
  final Color color;

  SocialLink({
    required this.id,
    required this.platform,
    required this.url,
    required this.icon,
    required this.color,
  });
}

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool isLoading = true;
  String activeTab = 'About';

  AppDesignExtension get themeExt =>
      Theme.of(context).extension<AppDesignExtension>()!;
  ColorScheme get colorScheme => Theme.of(context).colorScheme;

  String profileName = 'Sanku Surya';
  String username = 'sanku_surya';
  bool isVerified = true;
  int connectionCount = 542;

  PersonalInfo personalInfo = PersonalInfo(
    firstName: 'Sanku',
    lastName: 'Surya',
    bio:
        'Passionate UI/UX Designer and Frontend Developer with a focus on building accessible, human-centered digital products. Currently exploring advanced React patterns and AI integration.',
    email: 'sanku.surya@eduprova.com',
    phone: '+91 98765 43210',
    location: 'Andhra Pradesh, India',
  );

  ProfessionalInfo professionalInfo = ProfessionalInfo(
    headline: 'UI/UX Designer @ Eduprova',
    availability: 'Open to Work',
    skills: [
      'React',
      'TypeScript',
      'UI Design',
      'Figma',
      'Tailwind CSS',
      'Node.js',
      'User Research',
    ],
    languages: ['Telugu', 'English', 'Hindi'],
    interests: ['Tech', 'Design', 'Photography', 'Gaming', 'AI', 'Travel'],
  );

  final List<ExperienceItem> experience = [
    ExperienceItem(
      id: 'exp1',
      title: 'UI/UX Designer',
      company: 'Eduprova',
      period: 'JUN 2023 - PRESENT',
      isCurrent: true,
    ),
    ExperienceItem(
      id: 'exp2',
      title: 'Frontend Intern',
      company: 'TechSolutions',
      period: 'JAN 2023 - MAY 2023',
      isCurrent: false,
    ),
  ];

  final List<EducationItem> education = [
    EducationItem(
      id: 'edu1',
      degree: 'Bachelor of Science',
      institution: 'Dadi Veeru Naidu Degree College',
      period: '2020 - 2023',
    ),
    EducationItem(
      id: 'edu2',
      degree: 'UI/UX Design Specialization',
      institution: 'Coursera (Google)',
      period: '2023',
    ),
  ];

  List<SocialLink> socialLinks = [
    SocialLink(
      id: 's1',
      platform: 'Website',
      url: 'eduprova.com/surya',
      icon: Icons.language,
      color: const Color(0xFF6366F1),
    ),
    SocialLink(
      id: 's2',
      platform: 'LinkedIn',
      url: 'linkedin.com/in/surya',
      icon: Icons.work_outline,
      color: const Color(0xFF0A66C2),
    ), // Fallback since linkedin icon usually needs fontawesome package
    SocialLink(
      id: 's3',
      platform: 'GitHub',
      url: 'github.com/surya',
      icon: Icons.code,
      color: const Color(0xFF333333),
    ), // Fallback
    SocialLink(
      id: 's4',
      platform: 'Twitter',
      url: '@surya_dev',
      icon: Icons.alternate_email,
      color: const Color(0xFF1DA1F2),
    ), // Fallback
  ];

  final List<Map<String, dynamic>> socialPlatformOptions = [
    {
      'platform': 'Website',
      'icon': Icons.language,
      'color': const Color(0xFF6366F1),
    },
    {
      'platform': 'LinkedIn',
      'icon': Icons.work_outline,
      'color': const Color(0xFF0A66C2),
    },
    {
      'platform': 'GitHub',
      'icon': Icons.code,
      'color': const Color(0xFF333333),
    },
    {
      'platform': 'Twitter',
      'icon': Icons.alternate_email,
      'color': const Color(0xFF1DA1F2),
    },
    {
      'platform': 'Dribbble',
      'icon': Icons.sports_basketball,
      'color': const Color(0xFFEA4C89),
    },
    {
      'platform': 'Instagram',
      'icon': Icons.camera_alt_outlined,
      'color': const Color(0xFFE4405F),
    },
    {
      'platform': 'YouTube',
      'icon': Icons.play_circle_outline,
      'color': const Color(0xFFFF0000),
    },
    {
      'platform': 'Medium',
      'icon': Icons.description_outlined,
      'color': const Color(0xFF000000),
    },
  ];

  PersonalInfo editPersonalData = PersonalInfo(
    firstName: '',
    lastName: '',
    bio: '',
    email: '',
    phone: '',
    location: '',
  );
  ProfessionalInfo editProfessionalData = ProfessionalInfo(
    headline: '',
    availability: '',
    skills: [],
    languages: [],
    interests: [],
  );

  String newSocialPlatform = '';
  String newSocialUrl = '';
  Map<String, dynamic>? selectedPlatformData;

  @override
  void initState() {
    super.initState();
    editPersonalData = personalInfo.copyWith();
    editProfessionalData = professionalInfo.copyWith();
    Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => isLoading = false);
    });
  }

  void handleSocialLink(SocialLink link) {
    String url = link.url;
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    launchUrl(Uri.parse(url)).catchError((e) {
      if (!mounted) return false;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text('Could not open ${link.platform}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    });
  }

  void showEditPersonalInfoModal() {
    setState(() => editPersonalData = personalInfo.copyWith());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEditPersonalModal(),
    );
  }

  void showEditProfessionalInfoModal() {
    setState(() => editProfessionalData = professionalInfo.copyWith());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEditProfessionalModal(),
    );
  }

  void showAddSocialModal() {
    setState(() {
      newSocialPlatform = '';
      newSocialUrl = '';
      selectedPlatformData = null;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddSocialModal(),
    );
  }

  Widget _buildEditPersonalModal() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(bottom: 16),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ).copyWith(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Personal Info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        size: 24,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ).copyWith(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        'First Name',
                        editPersonalData.firstName,
                        (t) => setModalState(
                          () => editPersonalData = editPersonalData.copyWith(
                            firstName: t,
                          ),
                        ),
                      ),
                      _buildTextField(
                        'Last Name',
                        editPersonalData.lastName,
                        (t) => setModalState(
                          () => editPersonalData = editPersonalData.copyWith(
                            lastName: t,
                          ),
                        ),
                      ),
                      _buildTextField(
                        'Bio',
                        editPersonalData.bio,
                        (t) => setModalState(
                          () => editPersonalData = editPersonalData.copyWith(
                            bio: t,
                          ),
                        ),
                        maxLines: 4,
                      ),
                      _buildTextField(
                        'Email',
                        editPersonalData.email,
                        (t) => setModalState(
                          () => editPersonalData = editPersonalData.copyWith(
                            email: t,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildTextField(
                        'Phone',
                        editPersonalData.phone,
                        (t) => setModalState(
                          () => editPersonalData = editPersonalData.copyWith(
                            phone: t,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField(
                        'Location',
                        editPersonalData.location,
                        (t) => setModalState(
                          () => editPersonalData = editPersonalData.copyWith(
                            location: t,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          setState(
                            () => personalInfo = editPersonalData.copyWith(),
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Personal info updated successfully.',
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          alignment: Alignment.center,
                          child: const Text(
                            'Save Changes',
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditProfessionalModal() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(bottom: 16),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ).copyWith(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Professional Info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        size: 24,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ).copyWith(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        'Headline',
                        editProfessionalData.headline,
                        (t) => setModalState(
                          () => editProfessionalData = editProfessionalData
                              .copyWith(headline: t),
                        ),
                      ),
                      _buildTextField(
                        'Availability',
                        editProfessionalData.availability,
                        (t) => setModalState(
                          () => editProfessionalData = editProfessionalData
                              .copyWith(availability: t),
                        ),
                      ),
                      _buildTextField(
                        'Skills (comma-separated)',
                        editProfessionalData.skills.join(', '),
                        (t) => setModalState(
                          () => editProfessionalData = editProfessionalData
                              .copyWith(
                                skills: t
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList(),
                              ),
                        ),
                        maxLines: 2,
                      ),
                      _buildTextField(
                        'Languages (comma-separated)',
                        editProfessionalData.languages.join(', '),
                        (t) => setModalState(
                          () => editProfessionalData = editProfessionalData
                              .copyWith(
                                languages: t
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList(),
                              ),
                        ),
                      ),
                      _buildTextField(
                        'Interests (comma-separated)',
                        editProfessionalData.interests.join(', '),
                        (t) => setModalState(
                          () => editProfessionalData = editProfessionalData
                              .copyWith(
                                interests: t
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList(),
                              ),
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          setState(
                            () => professionalInfo = editProfessionalData
                                .copyWith(),
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Professional info updated successfully.',
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          alignment: Alignment.center,
                          child: const Text(
                            'Save Changes',
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddSocialModal() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(bottom: 16),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ).copyWith(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Social Connection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        size: 24,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ).copyWith(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Platform',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeExt.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: socialPlatformOptions.map((opt) {
                          bool isSelected =
                              newSocialPlatform == opt['platform'];
                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                newSocialPlatform = opt['platform'];
                                selectedPlatformData = opt;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary.withValues(alpha: 0.1)
                                    : themeExt.cardColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : themeExt.borderColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    opt['icon'],
                                    size: 18,
                                    color: isSelected
                                        ? const Color(0xFF0066FF)
                                        : opt['color'],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    opt['platform'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFF0066FF)
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        newSocialPlatform.isNotEmpty
                            ? '$newSocialPlatform URL / Username'
                            : 'URL / Username',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        onChanged: (text) =>
                            setModalState(() => newSocialUrl = text),
                        controller: TextEditingController(text: newSocialUrl)
                          ..selection = TextSelection.fromPosition(
                            TextPosition(offset: newSocialUrl.length),
                          ),
                        decoration: InputDecoration(
                          hintText: newSocialPlatform == 'Twitter'
                              ? '@username'
                              : newSocialPlatform == 'LinkedIn'
                              ? 'linkedin.com/in/username'
                              : 'https://',
                          hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 24),

                      InkWell(
                        onTap: () {
                          if (newSocialPlatform.isEmpty ||
                              newSocialUrl.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select a platform and enter a URL or username.',
                                ),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            socialLinks.add(
                              SocialLink(
                                id: 's${DateTime.now().millisecondsSinceEpoch}',
                                platform: newSocialPlatform,
                                url: newSocialUrl.trim(),
                                icon: selectedPlatformData!['icon'],
                                color: selectedPlatformData!['color'],
                              ),
                            );
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$newSocialPlatform has been added to your social connections.',
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Opacity(
                          opacity:
                              (newSocialPlatform.isEmpty ||
                                  newSocialUrl.trim().isEmpty)
                              ? 0.5
                              : 1.0,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            child: const Text(
                              'Add Connection',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    Function(String) onChanged, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: themeExt.secondaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          onChanged: onChanged,
          controller: TextEditingController(text: value)
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: value.length),
            ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: themeExt.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: themeExt.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: themeExt.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
          style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: themeExt.scaffoldBackgroundColor,
          body: const SafeArea(child: ProfileSettingsSkeleton()),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
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
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: themeExt.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: themeExt.borderColor,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: colorScheme.onSurface,
                        ),
                        // Atom-variant fallback
                      ),
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Icon(
                            Icons.search,
                            size: 22,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
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
                      // Profile Section
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ).copyWith(top: 12),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            profileName,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              color: colorScheme.onSurface,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          if (isVerified)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 6,
                                              ),
                                              child: Icon(
                                                Icons.verified,
                                                size: 20,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                            username,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: themeExt.secondaryText,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: themeExt.successColor,
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                            margin: const EdgeInsets.only(
                                              right: 5,
                                            ),
                                          ),
                                          Text(
                                            'Open to Work',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: themeExt.successColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        professionalInfo.headline,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: themeExt.secondaryText,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Row(
                                            children: [0, 1, 2].map((i) {
                                              return Container(
                                                width: 22,
                                                height: 22,
                                                margin: EdgeInsets.only(
                                                  left: i > 0 ? 6.0 : 0.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: i == 0
                                                      ? const Color(0xFFFCD34D)
                                                      : i == 1
                                                      ? const Color(0xFFA78BFA)
                                                      : const Color(0xFF60A5FA),
                                                  borderRadius:
                                                      BorderRadius.circular(11),
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  i == 0
                                                      ? '🤵'
                                                      : i == 1
                                                      ? '👩'
                                                      : '🧑',
                                                  style: const TextStyle(
                                                    fontSize: 8,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$connectionCount connections',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: themeExt.secondaryText,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 82,
                                      height: 82,
                                      decoration: BoxDecoration(
                                        color: themeExt.skeletonBase,
                                        borderRadius: BorderRadius.circular(41),
                                        border: Border.all(
                                          color: themeExt.borderColor,
                                          width: 2,
                                        ),
                                        image: const DecorationImage(
                                          image: NetworkImage(
                                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          borderRadius: BorderRadius.circular(
                                            13,
                                          ),
                                          border: Border.all(
                                            color: themeExt.cardColor,
                                            width: 2,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.add,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Edit Profile'),
                                          content: const Text(
                                            'Profile editor will open here.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFD1D5DB),
                                          width: 1.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Edit profile',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      // Native share typically handled via share_plus
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFD1D5DB),
                                          width: 1.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Share profile',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Tabs
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: themeExt.borderColor),
                          ),
                        ),
                        child: Row(
                          children: ['About', 'Posts', 'Certificates'].map((
                            tab,
                          ) {
                            bool isActive = activeTab == tab;
                            return Padding(
                              padding: const EdgeInsets.only(right: 28),
                              child: InkWell(
                                onTap: () => setState(() => activeTab = tab),
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isActive
                                            ? colorScheme.onSurface
                                            : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    tab,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isActive
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isActive
                                          ? colorScheme.onSurface
                                          : themeExt.secondaryText,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Tab Content
                      if (activeTab == 'About')
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ).copyWith(top: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Personal Info
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Personal Info',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: showEditPersonalInfoModal,
                                    child: const Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: themeExt.cardColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: themeExt.borderColor,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'FIRST NAME',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: themeExt.secondaryText,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            personalInfo.firstName,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: themeExt.cardColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: themeExt.borderColor,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'LAST NAME',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: themeExt.secondaryText,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            personalInfo.lastName,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'BIO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: themeExt.secondaryText,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                personalInfo.bio,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: themeExt.secondaryText,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.email_outlined,
                                      size: 20,
                                      color: themeExt.secondaryText,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    personalInfo.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.phone_outlined,
                                      size: 20,
                                      color: themeExt.successColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    personalInfo.phone,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      size: 20,
                                      color: colorScheme.error,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    personalInfo.location,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              Container(
                                height: 1,
                                color: themeExt.borderColor,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 28,
                                ),
                              ),

                              // Professional Info
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Professional Info',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: showEditProfessionalInfoModal,
                                    child: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: themeExt.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: themeExt.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: themeExt.borderColor,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'HEADLINE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: themeExt.secondaryText,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      professionalInfo.headline,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: themeExt.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: themeExt.borderColor,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'AVAILABILITY',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: themeExt.secondaryText,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: themeExt.successColor,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              margin: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                            ),
                                            Text(
                                              professionalInfo.availability,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 20,
                                      color: themeExt.secondaryText,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'SKILLS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: themeExt.secondaryText,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: professionalInfo.skills
                                    .map(
                                      (skill) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: themeExt.cardColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: themeExt.borderColor,
                                          ),
                                        ),
                                        child: Text(
                                          skill,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Icon(
                                    Icons.language,
                                    size: 16,
                                    color: themeExt.secondaryText,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'LANGUAGES',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: themeExt.secondaryText,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 20,
                                runSpacing: 8,
                                children: professionalInfo.languages
                                    .map(
                                      (lang) => Text(
                                        lang,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_border,
                                    size: 16,
                                    color: themeExt.secondaryText,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'INTERESTS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: themeExt.secondaryText,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: professionalInfo.interests
                                    .map(
                                      (interest) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: themeExt.cardColor,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: themeExt.borderColor,
                                          ),
                                        ),
                                        child: Text(
                                          interest,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),

                              Container(
                                height: 1,
                                color: themeExt.borderColor,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 28,
                                ),
                              ),

                              // Experience
                              Text(
                                'EXPERIENCE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: themeExt.secondaryText,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...experience.map((exp) {
                                return Container(
                                  margin: EdgeInsets.only(
                                    bottom: exp == experience.last ? 0 : 20,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: themeExt.cardColor,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: themeExt.borderColor,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.only(
                                          right: 14,
                                        ),
                                        child: Icon(
                                          Icons.work_outline,
                                          size: 18,
                                          color: themeExt.secondaryText,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              exp.title,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              exp.company,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: themeExt.secondaryText,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              exp.period,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: themeExt.secondaryText,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              Container(
                                height: 1,
                                color: themeExt.borderColor,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 28,
                                ),
                              ),

                              // Education
                              Text(
                                'EDUCATION',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: themeExt.secondaryText,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...education.map((edu) {
                                return Container(
                                  margin: EdgeInsets.only(
                                    bottom: edu == education.last ? 0 : 20,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: themeExt.cardColor,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: themeExt.borderColor,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.only(
                                          right: 14,
                                        ),
                                        child: Icon(
                                          Icons.school_outlined,
                                          size: 18,
                                          color: themeExt.secondaryText,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              edu.degree,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              edu.institution,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: themeExt.secondaryText,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              edu.period,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: themeExt.secondaryText,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              Container(
                                height: 1,
                                color: themeExt.borderColor,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 28,
                                ),
                              ),

                              // Social Connections
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Social Connections',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: showAddSocialModal,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: themeExt.cardColor,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: themeExt.borderColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.add,
                                        size: 18,
                                        color: themeExt.secondaryText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ...socialLinks.map((link) {
                                return InkWell(
                                  onTap: () => handleSocialLink(link),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: link == socialLinks.last
                                              ? Colors.transparent
                                              : themeExt.borderColor,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: themeExt.cardColor,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: themeExt.borderColor,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.only(
                                            right: 14,
                                          ),
                                          child: Icon(
                                            link.icon,
                                            size: 20,
                                            color: link.color,
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                link.platform,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                link.url,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: themeExt.secondaryText,
                                                ),
                                              ),
                                            ],
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
                              }),
                            ],
                          ),
                        ),

                      if (activeTab == 'Posts')
                        Container(
                          padding: const EdgeInsets.only(top: 40),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 48,
                                color: themeExt.borderColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No posts yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: themeExt.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your published posts will appear here.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: themeExt.secondaryText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                      if (activeTab == 'Certificates')
                        Container(
                          padding: const EdgeInsets.only(top: 40),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(
                                Icons.military_tech_outlined,
                                size: 48,
                                color: themeExt.borderColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No certificates yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: themeExt.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Complete courses to earn certificates.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: themeExt.secondaryText,
                                ),
                                textAlign: TextAlign.center,
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
      ),
    );
  }
}
