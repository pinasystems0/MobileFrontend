import 'package:flutter/material.dart';

import '../widgets/myai_glass_widgets.dart';

class ListScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget body;
  final Widget? searchBar;
  final Widget? topContent;
  final List<Widget> actions;
  final bool showBackButton;

  const ListScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    this.searchBar,
    this.topContent,
    this.actions = const [],
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return MyAiGlassScreen(
      title: title,
      subtitle: subtitle,
      actions: actions,
      showBackButton: showBackButton,
      child: Column(
        children: [
          if (topContent != null) ...[
            topContent!,
            const SizedBox(height: 16),
          ],
          if (searchBar != null) ...[
            searchBar!,
            const SizedBox(height: 16),
          ],
          Expanded(child: body),
        ],
      ),
    );
  }
}
