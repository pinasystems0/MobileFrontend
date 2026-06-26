import 'package:flutter/material.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  int _selectedIndex = 0;

  static const List<_TemplateTab> _tabs = [
    _TemplateTab(
      label: 'Home',
      icon: Icons.home_rounded,
      title: 'Template Home',
      subtitle: 'UI shell kept only for layout preview.',
    ),
    _TemplateTab(
      label: 'Explore',
      icon: Icons.explore_rounded,
      title: 'Explore Layouts',
      subtitle: 'No demo navigation or business logic is attached.',
    ),
    _TemplateTab(
      label: 'Profile',
      icon: Icons.person_rounded,
      title: 'Profile Space',
      subtitle: 'Use this file only as a design reference.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tab = _tabs[_selectedIndex];

    return Scaffold(
      body: TemplateBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: TemplateTheme.glassPanel(
                    color: Colors.white,
                    opacity: 0.62,
                    radius: 28,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              TemplateTheme.primary,
                              TemplateTheme.accent,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tab.title,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: TemplateTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tab.subtitle,
                              style: const TextStyle(
                                fontSize: 14,
                                color: TemplateTheme.textMuted,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: const [
                      _PreviewCard(
                        title: 'Clean Template Integration',
                        description:
                            'Broken imports, demo navigation, and missing references have been removed from the template layer.',
                        icon: Icons.build_circle_outlined,
                      ),
                      SizedBox(height: 16),
                      _PreviewCard(
                        title: 'Rive-Ready Background',
                        description:
                            'The shared template backdrop uses the corrected assets/template paths.',
                        icon: Icons.animation_rounded,
                      ),
                      SizedBox(height: 16),
                      _PreviewCard(
                        title: 'Safe for Production App',
                        description:
                            'This screen is UI-only and does not depend on backend logic, APIs, or live routing.',
                        icon: Icons.verified_user_outlined,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: TemplateTheme.softCard(
                    color: Colors.white.withValues(alpha: 0.86),
                    radius: 24,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_tabs.length, (index) {
                      final item = _tabs[index];
                      final isSelected = _selectedIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        TemplateTheme.primary,
                                        TemplateTheme.accent,
                                      ],
                                    )
                                  : null,
                              color: isSelected ? null : Colors.transparent,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.icon,
                                  color: isSelected
                                      ? Colors.white
                                      : TemplateTheme.textMuted,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : TemplateTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: TemplateTheme.softCard(
        color: Colors.white.withValues(alpha: 0.88),
        radius: 26,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: TemplateTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: TemplateTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: TemplateTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: TemplateTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateTab {
  const _TemplateTab({
    required this.label,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String label;
  final IconData icon;
  final String title;
  final String subtitle;
}
