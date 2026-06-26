import 'package:flutter/material.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class ResponsiveFormLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final List<Widget> bottomButtons;
  final EdgeInsetsGeometry? contentPadding;
  final double maxWidth;

  const ResponsiveFormLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    this.bottomButtons = const [],
    this.contentPadding,
    this.maxWidth = 420,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TemplateTheme.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: TemplateTheme.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Scrollable Content
              Expanded(
                child: Container(
                  padding: contentPadding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  decoration: TemplateTheme.glassPanel(),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: content,
                    ),
                  ),
                ),
              ),
              // Fixed Bottom Buttons
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: Column(
                  children: bottomButtons,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

