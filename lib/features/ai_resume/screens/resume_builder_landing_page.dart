import 'package:eduprova/theme/theme.dart';
import 'package:eduprova/ui/background.dart';
import 'package:eduprova/ui/gradient_btn.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/navigation/app_routes.dart';
import '../widgets/resume_flipping_widget.dart';

class ResumeBuilderLandingPage extends StatelessWidget {
  const ResumeBuilderLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == .dark;
    final themeExt = theme.extension<AppDesignExtension>()!;

    return Scaffold(
      backgroundColor: themeExt.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,

      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: .symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: .center,
                children: [
                  const SizedBox(height: 30),
                  // Title
                  Padding(
                    padding: .symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // RichText(
                        //   textAlign: .center,
                        //   text: TextSpan(
                        //     style: theme.textTheme.headlineMedium?.copyWith(
                        //       fontWeight: FontWeight.w800,
                        //       fontSize: 32,
                        //       color: colorScheme.onSurface,
                        //     ),
                        //     children: [
                        //       const TextSpan(text: 'Build a Job-Winning\n'),

                        //       TextSpan(
                        //         text: 'Resume With AI',
                        //         style: TextStyle(color: themeExt.gradiantEnd),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Text(
                          'Build a Job-Winning',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.onSurface,
                            height: 1.05,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 7),
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFF0066FF),
                              Color(0xFFE056FD),
                            ], // Blue to pink/purple gradient
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds),
                          child: const Text(
                            'Resume With AI',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors
                                  .white, // Color needed for shader mask to work
                              height: 1.05,
                              letterSpacing: -1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 55),
                  // Animation Section
                  const ResumeFlippingWidget(),
                  // Description
                  const SizedBox(height: 45),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      // 'Create a professional, ATS-friendly resume in minutes with our advanced AI. Land your dream job with data-backed templates and smart suggestions.',
                      'Create a professional, ATS-friendly resume in minutes with our advanced AI.',
                      textAlign: .center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: themeExt.secondaryText,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Badges
                  Padding(
                    padding: .symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildFeatureBadge(
                          context,
                          label: 'Ai Assisted Writing',
                          iconSymbol: LucideIcons.sparkles,
                          backgroundColor: const Color(0xFFEEF2FF),
                          textColor: isDark
                              ? const Color(0xFFA5A0FF)
                              : const Color(0xFF4F46E5),
                        ),
                        _buildFeatureBadge(
                          context,
                          label: 'Instant Pdf Export',
                          iconSymbol: LucideIcons.fileText,
                          backgroundColor: const Color(0xFFFFF1F2),
                          textColor: isDark
                              ? const Color(0xFFFFA5A5)
                              : const Color(0xFFE11D48),
                        ),
                        _buildFeatureBadge(
                          context,
                          label: 'ATS Optimized',
                          iconSymbol: LucideIcons.badgeCheck,
                          backgroundColor: const Color(0xFFF0FDF4),
                          textColor: isDark
                              ? const Color(0xFFA5FFA5)
                              : const Color(0xFF16A34A),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // CTA Button
                  Padding(
                    padding: .symmetric(horizontal: 24),
                    child: GradientBtn(
                      width: double.infinity,
                      height: 56,
                      borderRadius: 16,
                      onTap: () {
                        context.push(AppRoutes.resumeBuilderList);
                      },
                      child: Row(
                        mainAxisAlignment: .center,
                        children: [
                          const Text(
                            'Build My Resume',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            LucideIcons.arrowRight,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(
    BuildContext context, {
    required String label,
    required IconData iconSymbol,
    required Color backgroundColor,
    required Color textColor,
  }) {
    final isDark = Theme.of(context).brightness == .dark;
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;

    return Container(
      padding: .symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        // color: isDark ? textColor.withValues(alpha: 0.15) : backgroundColor,
        // color: isDark ? const Color.fromARGB(255, 30, 30, 30) : Colors.white,
        color: themeExt.cardColor,
        borderRadius: .circular(30),
        // border: Border.all(
        //   color: isDark
        //       ? textColor.withValues(alpha: 0.3)
        //       : textColor.withValues(alpha: 0.1),
        //   width: 1,
        // ),
        border: Border.all(
          color: themeExt.borderColor.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          // if (!isDark)
          BoxShadow(
            color: textColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const .new(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: .all(8),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              // borderRadius: .circular(30),
            ),
            child: Icon(
              iconSymbol,
              size: 16,
              color: isDark ? textColor.withValues(alpha: 0.9) : textColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? textColor.withValues(alpha: 0.9) : textColor,
            ),
          ),
        ],
      ),
    );
  }
}
