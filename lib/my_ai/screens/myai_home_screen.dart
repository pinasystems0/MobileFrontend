import 'dart:ui';
import 'package:flutter/material.dart';


import '../../ui_template/utils/myai_background.dart';
import 'ready_content_screen.dart';
import 'user_widgets_screen.dart';
import 'widget_library_screen.dart';
import '../../screens/chatbot/chatbot_screen.dart';


class MyAiHomeScreen extends StatelessWidget {
  final String? userEmail;

  const MyAiHomeScreen({
    super.key,
    this.userEmail,
  });

  static const List<_HomeSection> _sections = <_HomeSection>[
    _HomeSection(
      title: 'Ready Content',
      subtitle: 'Open study packs',
      icon: Icons.menu_book_rounded,
    ),
    _HomeSection(
      title: 'Widgets',
      subtitle: 'Use your saved tools',
      icon: Icons.widgets_rounded,
    ),
    _HomeSection(
      title: 'Agents',
      subtitle: 'Coming soon',
      icon: Icons.smart_toy_rounded,
    ),
    _HomeSection(
      title: 'Widget Library',
      subtitle: 'Browse all widgets',
      icon: Icons.library_add_rounded,
    ),
    _HomeSection(
      title: 'Chatbot',
      subtitle: 'Learn with guided Q&A',

      icon: Icons.school_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MyAIBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 14.0;
                    final tileWidth = (constraints.maxWidth - spacing) / 2;
                    final targetHeight =
                        constraints.maxWidth > 420 ? 170.0 : 160.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _HomeTitle(),
                        const SizedBox(height: 24),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              crossAxisSpacing: spacing,
                              mainAxisSpacing: spacing,
                              childAspectRatio: tileWidth / targetHeight,
                              children: List.generate(
                                _sections.length,
                                (index) => _SectionCard(
                                  section: _sections[index],
                                  cardIndex: index,
                                  onTap: () => _handleSectionTap(
                                      context, _sections[index].title),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSectionTap(BuildContext context, String title) {
    Widget? screen;

    switch (title) {
      case 'Ready Content':
        screen = ReadyContentScreen(userEmail: userEmail);
        break;
      case 'Widgets':
        screen = UserWidgetsScreen(userEmail: userEmail);
        break;
      case 'Widget Library':
        screen = WidgetLibraryScreen(userEmail: userEmail);
        break;
      case 'Chatbot':
        screen = const ChatbotScreen();
        break;

      case 'Agents':

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Coming Soon')),
          );
        return;
    }

    if (screen == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen!),
    );
  }
}

// ─────────────────────────────────────────────
// Home Title - REPLACED SECTION
// ─────────────────────────────────────────────
class _HomeTitle extends StatelessWidget {
  const _HomeTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/template/icons/arthum_logo.png',
          width: 34,
          height: 34,
        ),
        const SizedBox(width: 10),
        const Text(
          'MyAI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Meshuis-style Glass Card
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final _HomeSection section;
  final int cardIndex;
  final VoidCallback onTap;

  const _SectionCard({
    required this.section,
    required this.cardIndex,
    required this.onTap,
  });

  static const List<List<Color>> _innerColors = [
    [Color(0xFF6B00CC), Color(0xFF9B30FF)],
    [Color(0xFF0055CC), Color(0xFF7B44FF)],
    [Color(0xFF8800CC), Color(0xFFCC44FF)],
    [Color(0xFF4400AA), Color(0xFF8855FF)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _innerColors[cardIndex % _innerColors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          // Outer thick glass border glow — like screenshot
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.18),
              blurRadius: 0,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: colors[0].withOpacity(0.55),
              blurRadius: 22,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                // Thick bright glass border — exact like screenshot
                border: Border.all(
                  color: Colors.white.withOpacity(0.55),
                  width: 1.8,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.28),
                    Colors.white.withOpacity(0.10),
                    colors[0].withOpacity(0.70),
                    colors[1].withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.18, 0.55, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // ── Inner curved blob (like screenshot dark purple curve)
                  Positioned(
                    bottom: -10,
                    left: -10,
                    right: 30,
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        gradient: RadialGradient(
                          center: Alignment.centerLeft,
                          radius: 1.0,
                          colors: [
                            colors[0].withOpacity(0.60),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Top-right shimmer light (bright streak like screenshot)
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon top left
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.30),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            section.icon,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),

                        const Spacer(),

                        // Title
                        Text(
                          section.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Subtitle
                        Text(
                          section.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Bottom pill button — like screenshot
                        Center(
                          child: Container(
                            height: 22,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Colors.white.withOpacity(0.18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                                width: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Data class
// ─────────────────────────────────────────────
class _HomeSection {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HomeSection({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}