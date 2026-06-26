/// ------------------------------------------------------------
 /// 📁 File: add_widget_modal.dart
 /// 📂 Module: MyAI (Frontend)
 ///
 /// ✅ TemplateTheme 100% REMOVED & ERRORS FIXED
 /// Simple Card UI, standard Colors
 /// STRICT structure preserved
 /// ------------------------------------------------------------
import 'package:flutter/material.dart';
import '../../../ui_template/utils/myai_background.dart';
import '../../../ui_template/utils/template_layout.dart';

import '../models/widget_model.dart';
import '../services/myai_api_service.dart';
import '../config/widget_configs.dart';

class AddWidgetModal extends StatefulWidget {
  final String userEmail;
  final MyAiApiService service;
  final VoidCallback? onWidgetAdded;

  const AddWidgetModal({
    super.key,
    required this.userEmail,
    required this.service,
    this.onWidgetAdded,
  });

  @override
  State<AddWidgetModal> createState() => _AddWidgetModalState();
}

class _AddWidgetModalState extends State<AddWidgetModal> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, List<WidgetModel>> _groupedWidgets = {};
  final List<String> _categories = [];

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasCatalogWidgets = false;
  bool _hasAvailableWidgets = false;
  int _catalogCount = 0;
  int _availableCount = 0;
  String? _selectedCategory;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWidgets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Set<String> _extractAddedWidgetNames(List<dynamic> userRaw) {
    final names = <String>{};

    for (final item in userRaw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);

      final directName = (map['widgetName'] ?? '').toString().trim().toLowerCase();
      if (directName.isNotEmpty) {
        names.add(directName);
      }
    }

    return names;
  }

  Future<void> _loadWidgets() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _groupedWidgets.clear();
      _categories.clear();
      _selectedCategory = null;
      _hasCatalogWidgets = false;
      _hasAvailableWidgets = false;
      _catalogCount = 0;
      _availableCount = 0;
    });

    try {
      final results = await Future.wait<dynamic>([
        widget.service.getWidgets(),
        widget.service.getUserWidgets(widget.userEmail),
      ]);

      final allRaw = (results[0] as List<dynamic>);
      final userRaw = (results[1] as List<dynamic>);

      final addedNames = _extractAddedWidgetNames(userRaw);

      final catalogWidgets = allRaw
          .whereType<Map>()
          .map((item) => WidgetModel.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.widgetName.trim().isNotEmpty)
          .where((item) => item.visitStatus.toLowerCase() != 'inactive')
          .toList();

      final available = catalogWidgets
          .where((item) => !addedNames.contains(item.widgetName.trim().toLowerCase()))
          .toList();

      for (final widgetItem in available) {
        final category = widgetItem.visitCategory.trim().isEmpty
            ? 'Other'
            : widgetItem.visitCategory.trim();
        _groupedWidgets.putIfAbsent(category, () => <WidgetModel>[]);
        _groupedWidgets[category]!.add(widgetItem);
      }

      for (final entry in _groupedWidgets.entries) {
        entry.value.sort((a, b) => a.widgetName.compareTo(b.widgetName));
      }

      _categories.addAll(_groupedWidgets.keys);
      _categories.sort();
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }

      if (!mounted) return;
      setState(() {
        _hasCatalogWidgets = catalogWidgets.isNotEmpty;
        _hasAvailableWidgets = available.isNotEmpty;
        _catalogCount = catalogWidgets.length;
        _availableCount = available.length;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _addWidget(WidgetModel item) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final added = await widget.service.addUserWidget(
        widget.userEmail,
        item.widgetName,
        item.id,
      );

      if (!mounted) return;
      if (!added) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.widgetName} is already added.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        await _loadWidgets();
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      widget.onWidgetAdded?.call();
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = isSelected ? null : category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
            : Colors.transparent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          category,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = category == _selectedCategory;
            return _buildCategoryChip(category, isSelected);
          }).toList(),
        ),
      ),
    );
  }

  List<WidgetModel> _filteredWidgets() {
    final selected = _selectedCategory;
    final items = selected == null ? <WidgetModel>[] : (_groupedWidgets[selected] ?? <WidgetModel>[]);
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items
        .where((item) => item.widgetName.toLowerCase().contains(q))
        .toList(growable: false);
  }

  Widget _buildWidgetItem(WidgetModel item) {
    final config = resolveWidgetConfigForWidget(item);

    return InkWell(
      onTap: _isSubmitting ? null : () => _addWidget(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  config.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.widgetName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.visitCategory.isEmpty ? 'General AI' : item.visitCategory,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetList() {
    final items = _filteredWidgets();

    if (items.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 48,
                color: Colors.white70,
              ),
              SizedBox(height: 16),
              Text(
                'No widgets found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildWidgetItem(items[index]),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _loadWidgets,
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      final message = !_hasCatalogWidgets
          ? 'No widgets available'
          : !_hasAvailableWidgets
              ? 'All widgets already added'
              : 'No widgets available';

      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                size: 48,
                color: Colors.white70,
              ),
              const SizedBox(height: 16),
              Text(
                !_hasCatalogWidgets ? message : '$message\nYour home screen already has all active widgets.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildCategoryList(),
        const SizedBox(height: 16),
        Expanded(child: _buildWidgetList()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyAIBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: TemplateLayout(
          sectionTitle: 'Add Widget',
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: 'Search widgets',
                  hintText: 'Search widgets...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _hasCatalogWidgets
                    ? '$_availableCount available of $_catalogCount active widgets'
                    : 'No active widgets available',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }
}
