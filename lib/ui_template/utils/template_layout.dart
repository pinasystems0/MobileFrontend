import 'package:flutter/material.dart';
import 'package:pina/ui_template/utils/template_header.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class TemplateLayout extends StatelessWidget {
  const TemplateLayout({
    super.key,
    required this.child,
    this.brandTitle = 'Arthum AI',
    this.brandSubtitle,
    this.leading,
    this.sectionTitle,
    this.sectionSubtitle,
    this.headerAction,
    this.padding,
  });

  final Widget child;
  final String brandTitle;
  final String? brandSubtitle;
  final Widget? leading;
  final String? sectionTitle;
  final String? sectionSubtitle;
  final Widget? headerAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final contentPadding =
        padding ??
        EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: media.padding.bottom + 16,
        );

    return TemplateBackdrop(
      child: SafeArea(
        child: Padding(
          padding: contentPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TemplateHeader(
                brandTitle: brandTitle,
                brandSubtitle: brandSubtitle,
                leading: leading,
                sectionTitle: sectionTitle,
                sectionSubtitle: sectionSubtitle,
                action: headerAction,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ClipRect(
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
