import 'package:flutter/material.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class TemplateHeader extends StatelessWidget {
  const TemplateHeader({
    super.key,
    this.brandTitle = 'Arthum AI',
    this.brandSubtitle,
    this.leading,
    this.sectionTitle,
    this.sectionSubtitle,
    this.action,
  });

  final String brandTitle;
  final String? brandSubtitle;
  final Widget? leading;
  final String? sectionTitle;
  final String? sectionSubtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Replaced section starts here
          Row(
            children: [
              Image.asset(
                'assets/template/icons/arthum_logo.png',
                height: 40,
                width: 40,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brandTitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TemplateTheme.textPrimary,
                      ),
                    ),
                    if (brandSubtitle != null)
                      Text(
                        brandSubtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: TemplateTheme.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Replaced section ends here
          const SizedBox(height: 16),
          Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sectionTitle ?? brandTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: TemplateTheme.textPrimary,
                      ),
                    ),
                    if (sectionSubtitle != null)
                      Text(
                        sectionSubtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: TemplateTheme.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: 12),
                action!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}