import 'package:flutter/material.dart';
import 'package:pina/ui_template/screens/entryPoint/entry_point.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

typedef OnbodingScreen = TemplateOnboardingScreen;

class TemplateOnboardingScreen extends StatelessWidget {
  const TemplateOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TemplateBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: TemplateTheme.glassPanel(
                    color: Colors.white,
                    opacity: 0.55,
                    radius: 22,
                  ),
                  child: const Text(
                    'PINA Template',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: TemplateTheme.textPrimary,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 330,
                  padding: const EdgeInsets.all(26),
                  decoration: TemplateTheme.glassPanel(),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modern UI,\nreal app logic.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 36,
                          height: 1.08,
                          fontWeight: FontWeight.w700,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'This onboarding file is now self-contained and uses the corrected assets/template paths without demo-only dialogs or broken imports.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.55,
                          color: TemplateTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Use this as a clean UI reference or route into the app shell below.',
                  style: TextStyle(
                    fontSize: 13,
                    color: TemplateTheme.textMuted,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EntryPoint(),
                            ),
                          );
                        },
                        style: TemplateTheme.primaryButtonStyle(),
                        child: const Text('Open Template UI'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
