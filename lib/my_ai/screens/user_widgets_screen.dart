import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import '../config/widget_configs.dart';
import '../models/widget_model.dart';
import '../services/myai_api_service.dart';
import '../widgets/myai_glass_widgets.dart';
import '../widgets/widget_catalog_helpers.dart';
import 'base_widget_screen.dart';
import 'list_screen.dart';
import 'widget_library_screen.dart';

class UserWidgetsScreen extends StatefulWidget {
  final String? userEmail;

  const UserWidgetsScreen({
    super.key,
    this.userEmail,
  });

  @override
  State<UserWidgetsScreen> createState() => _UserWidgetsScreenState();
}

class _UserWidgetsScreenState extends State<UserWidgetsScreen> {
  List<WidgetModel> _widgets = <WidgetModel>[];
  bool _loading = false;
  String? _userEmail;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWidgets(showLoader: true);
  }

  Future<String> _resolveUserEmail() async {
    final directEmail = widget.userEmail?.trim() ?? '';
    if (directEmail.isNotEmpty) {
      _userEmail = directEmail;
      return directEmail;
    }

    final sessionEmail = (await SessionService.getUserEmail())?.trim() ?? '';
    if (sessionEmail.isNotEmpty) {
      _userEmail = sessionEmail;
      return sessionEmail;
    }

    throw Exception('User email is missing.');
  }

  Future<void> _loadWidgets({bool showLoader = false}) async {
    if (showLoader) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final email = _userEmail ?? await _resolveUserEmail();
      final response = await myAiService.getUserWidgets(email);
      final widgets = dedupeWidgets(
        response
            .whereType<Map>()
            .map((item) => WidgetModel.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false),
      );

      if (!mounted) return;
      setState(() {
        _widgets = widgets;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _openWidget(WidgetModel item) async {
    final email = _userEmail ?? await _resolveUserEmail();
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BaseWidgetScreen(
          widgetItem: item,
          userEmail: email,
        ),
      ),
    );
  }

  Widget _buildWidgetTile(WidgetModel item) {
    final config = resolveWidgetConfigForWidget(item);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openWidget(item),
          borderRadius: BorderRadius.circular(28),
          child: MyAiGlassPanel(
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        config.accentColor.withOpacity(0.92),
                        const Color(0xFF44D7FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(config.icon, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.widgetName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        config.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withOpacity(0.72), height: 1.35),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          MyAiMetaChip(icon: Icons.category_rounded, label: config.category),
                          MyAiMetaChip(icon: Icons.view_carousel_rounded, label: config.screenType),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_error != null) {
      return MyAiEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Unable to load widgets',
        subtitle: _error!,
        action: MyAiGradientButton(
          onPressed: () => _loadWidgets(showLoader: true),
          child: const Text(
            'Retry',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    if (_widgets.isEmpty) {
      return MyAiEmptyState(
        icon: Icons.widgets_outlined,
        title: 'No widgets added yet',
        subtitle: 'Open Widget Library to add tools to your personal MyAI workspace.',
        action: MyAiGradientButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => WidgetLibraryScreen(userEmail: _userEmail ?? widget.userEmail),
              ),
            );
            if (mounted) {
              _loadWidgets(showLoader: true);
            }
          },
          child: const Text(
            'Open Library',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    final grouped = groupWidgetsByCategory(_widgets);
    final categories = grouped.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: () => _loadWidgets(showLoader: false),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          MyAiGlassPanel(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                MyAiMetaChip(icon: Icons.widgets_rounded, label: '${_widgets.length} widgets'),
                const MyAiMetaChip(icon: Icons.account_tree_rounded, label: 'Grouped by category'),
                const MyAiMetaChip(icon: Icons.dashboard_customize_rounded, label: 'Shared widget screens'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final category in categories) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ...grouped[category]!.map(_buildWidgetTile),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListScreen(
      title: 'Widgets',
      subtitle: 'Your selected widgets grouped by category, each opening a shared dynamic screen.',
      body: _buildBody(),
    );
  }
}
