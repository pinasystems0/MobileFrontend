import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import '../config/widget_configs.dart';
import '../models/widget_model.dart';
import '../services/myai_api_service.dart';
import '../widgets/myai_glass_widgets.dart';
import '../widgets/widget_catalog_helpers.dart';
import 'list_screen.dart';

class WidgetLibraryScreen extends StatefulWidget {
  final String? userEmail;

  const WidgetLibraryScreen({
    super.key,
    this.userEmail,
  });

  @override
  State<WidgetLibraryScreen> createState() => _WidgetLibraryScreenState();
}

class _WidgetLibraryScreenState extends State<WidgetLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<WidgetModel> _libraryWidgets = <WidgetModel>[];
  Set<String> _selectedWidgetKeys = <String>{};
  Set<String> _addingWidgetKeys = <String>{};
  bool _loading = false;
  String? _userEmail;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadData(showLoader: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<WidgetModel> _readWidgets(List<dynamic> raw) {
    try {
      if (raw.isEmpty) {
        return [];
      }

      return raw
          .whereType<Map>()
          .map((item) {
            try {
              return WidgetModel.fromJson(Map<String, dynamic>.from(item));
            } catch (e) {
              print('⚠️ [_readWidgets] Error parsing widget: $e');
              return null;
            }
          })
          .whereType<WidgetModel>()
          .where((item) => (item.widgetName?.trim() ?? '').isNotEmpty)
          .toList(growable: false);
    } catch (e) {
      print('❌ [_readWidgets] Fatal error: $e');
      return [];
    }
  }

  Future<void> _loadData({bool showLoader = false}) async {
    if (showLoader) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      // ✅ STEP 1: Resolve email
      print('📧 [WidgetLibrary] Step 1: Resolving user email...');
      final email = _userEmail ?? await _resolveUserEmail();
      print('✅ [WidgetLibrary] Email resolved: $email');

      // ✅ STEP 2: Fetch from API
      print('🌐 [WidgetLibrary] Step 2: Calling API endpoints...');
      final results = await Future.wait<dynamic>([
        myAiService.getUserWidgets(email),
        myAiService.getWidgets(),
      ]);
      print('✅ [WidgetLibrary] API responses received');
      print('   - getUserWidgets response type: ${results[0].runtimeType}');
      print('   - getWidgets response type: ${results[1].runtimeType}');

      // ✅ STEP 3: Parse widgets
      print('📝 [WidgetLibrary] Step 3: Parsing widgets from API response...');
      final rawSelected = results[0] as List<dynamic>;
      final rawLibrary = results[1] as List<dynamic>;
      print('   - Raw selected widgets count: ${rawSelected.length}');
      print('   - Raw library widgets count: ${rawLibrary.length}');

      final selectedWidgets = dedupeWidgets(_readWidgets(rawSelected));
      print('✅ [WidgetLibrary] Selected widgets parsed: ${selectedWidgets.length}');
      for (var w in selectedWidgets.take(3)) {
        print('   - ${w.widgetName} (key: ${w.widgetKey})');
      }

      final libraryWidgets = dedupeWidgets(_readWidgets(rawLibrary));
      print('✅ [WidgetLibrary] Library widgets parsed: ${libraryWidgets.length}');
      for (var w in libraryWidgets.take(3)) {
        print('   - ${w.widgetName} (key: ${w.widgetKey})');
      }

      // ✅ STEP 4: Validate configs exist
      print('🔍 [WidgetLibrary] Step 4: Validating widget configs...');
      final missingConfigs = <String>[];
      for (final widget in libraryWidgets) {
        try {
          resolveWidgetConfigForWidget(widget);
          print('   ✅ Config found for: ${widget.widgetName}');
        } catch (e) {
          print('   ❌ Config MISSING for: ${widget.widgetName} - Error: $e');
          missingConfigs.add(widget.widgetName);
        }
      }

      if (missingConfigs.isNotEmpty) {
        print('⚠️ [WidgetLibrary] ${missingConfigs.length} widgets missing configs!');
        print('Missing: $missingConfigs');
      }

      // ✅ STEP 5: Group by category (WITH ERROR HANDLING)
      print('📂 [WidgetLibrary] Step 5: Grouping by category...');
      late final Map<String, List<WidgetModel>> grouped;
      try {
        grouped = groupWidgetsByCategory(libraryWidgets, query: _query);
        print('✅ [WidgetLibrary] Categories created: ${grouped.keys.length}');
        for (final cat in grouped.keys) {
          print('   - $cat: ${grouped[cat]?.length ?? 0} widgets');
        }
      } catch (e, st) {
        print('❌ [WidgetLibrary] ERROR in groupWidgetsByCategory: $e');
        print('📍 Stack trace: $st');
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Error organizing widgets: $e';
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _libraryWidgets = libraryWidgets;
        _selectedWidgetKeys = selectedWidgets
            .map((item) => normalizeWidgetName(item.widgetName ?? ''))
            .where((item) => item.isNotEmpty)
            .toSet();
        _loading = false;
        _error = null;
      });

      print('✅ [WidgetLibrary] _loadData completed successfully!');
    } catch (error, stackTrace) {
      print('❌ [WidgetLibrary] FATAL ERROR in _loadData:');
      print('   Error: $error');
      print('   Stack trace: $stackTrace');

      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _addWidget(WidgetModel item) async {
    try {
      final normalized = normalizeWidgetName(item.widgetName ?? '');
      if (normalized.isEmpty ||
          _selectedWidgetKeys.contains(normalized) ||
          _addingWidgetKeys.contains(normalized)) {
        return;
      }

      setState(() {
        _addingWidgetKeys = {..._addingWidgetKeys, normalized};
        _selectedWidgetKeys = {..._selectedWidgetKeys, normalized};
      });

      final email = _userEmail ?? await _resolveUserEmail();
      final added = await myAiService.addUserWidget(
        email,
        item.widgetName ?? 'Unknown',
        item.widgetId.isNotEmpty ? item.widgetId : item.id,
      );

      if (!mounted) return;
      setState(() {
        _addingWidgetKeys = Set<String>.from(_addingWidgetKeys)..remove(normalized);
      });

      if (!added) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.widgetName} is already added.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      final normalized = normalizeWidgetName(item.widgetName ?? '');
      setState(() {
        _addingWidgetKeys = Set<String>.from(_addingWidgetKeys)..remove(normalized);
        _selectedWidgetKeys = Set<String>.from(_selectedWidgetKeys)..remove(normalized);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _buildLibraryAction(WidgetModel item) {
    try {
      final normalized = normalizeWidgetName(item.widgetName ?? '');
      final isAdding = _addingWidgetKeys.contains(normalized);
      final isAdded = _selectedWidgetKeys.contains(normalized);

      if (isAdding) {
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        );
      }

      if (isAdded) {
        return const Icon(Icons.check_circle_rounded, color: Color(0xFFB7FFCB), size: 28);
      }

      return GestureDetector(
        onTap: () => _addWidget(item),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8A7CFF), Color(0xFF44D7FF)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      );
    } catch (e) {
      print('❌ [_buildLibraryAction] Error: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildTile(WidgetModel item) {
    try {
      // ✅ DEFENSIVE: Catch config resolution errors
      late final WidgetConfig config;
      try {
        config = resolveWidgetConfigForWidget(item);
      } catch (e) {
        print('⚠️ [_buildTile] Config error for ${item.widgetName}: $e');
        // Return a fallback tile if config is missing
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MyAiGlassPanel(
            child: ListTile(
              title: Text(
                item.widgetName ?? 'Unknown',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              subtitle: const Text(
                '⚠️ Config missing - contact support',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: MyAiGlassPanel(
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      config.accentColor.withOpacity(0.92),
                      const Color(0xFF44D7FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(config.icon, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.widgetName ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
              _buildLibraryAction(item),
            ],
          ),
        ),
      );
    } catch (e) {
      print('❌ [_buildTile] Fatal error building tile: $e');
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: MyAiGlassPanel(
          child: ListTile(
            title: Text(
              'Error rendering widget',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      );
    }
  }

  // ✅ Optimized ListView with lazy loading
  Widget _buildOptimizedListView(Map<String, List<WidgetModel>> grouped) {
    final categories = grouped.keys.toList()..sort();
    
    return RefreshIndicator(
      onRefresh: () => _loadData(showLoader: false),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: categories.length,
        itemBuilder: (context, categoryIndex) {
          try {
            final category = categories[categoryIndex];
            final widgets = grouped[category] ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (categoryIndex == 0)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: MyAiGlassPanel(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          MyAiMetaChip(icon: Icons.library_books_rounded, label: '${_libraryWidgets.length} total widgets'),
                          MyAiMetaChip(icon: Icons.check_circle_rounded, label: '${_selectedWidgetKeys.length} added'),
                          const MyAiMetaChip(icon: Icons.account_tree_rounded, label: 'Auto-grouped categories'),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12, bottom: 10, right: 12),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ...widgets.map((widget) => _buildTile(widget)),
                const SizedBox(height: 10),
              ],
            );
          } catch (e) {
            print('❌ [_buildOptimizedListView] Error building category: $e');
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Minimal logging for Phase 1 diagnostic.
    debugPrint('WidgetLibraryScreen build');
    try {
      if (_loading) {
        return ListScreen(
          title: 'Widget Library',
          subtitle: 'Browse every widget, search by category, and add tools to your shared-screen workspace.',
          searchBar: MyAiSearchField(
            controller: _searchController,
            hintText: 'Search by widget or category',
            onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
            onClear: () {
              _searchController.clear();
              setState(() => _query = '');
            },
          ),
          body: const Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }

      if (_error != null) {
        return ListScreen(
          title: 'Widget Library',
          subtitle: 'Browse every widget, search by category, and add tools to your shared-screen workspace.',
          searchBar: MyAiSearchField(
            controller: _searchController,
            hintText: 'Search by widget or category',
            onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
            onClear: () {
              _searchController.clear();
              setState(() => _query = '');
            },
          ),
          body: MyAiEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Unable to load widget library',
            subtitle: _error!,
            action: MyAiGradientButton(
              onPressed: () => _loadData(showLoader: true),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        );
      }

      if (_libraryWidgets.isEmpty) {
        return ListScreen(
          title: 'Widget Library',
          subtitle: 'Browse every widget, search by category, and add tools to your shared-screen workspace.',
          searchBar: MyAiSearchField(
            controller: _searchController,
            hintText: 'Search by widget or category',
            onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
            onClear: () {
              _searchController.clear();
              setState(() => _query = '');
            },
          ),
          body: const MyAiEmptyState(
            icon: Icons.library_add_outlined,
            title: 'No widgets available',
            subtitle: 'The widget library is empty right now.',
          ),
        );
      }

      print('📂 [build] About to call groupWidgetsByCategory with ${_libraryWidgets.length} widgets...');
      
      late final Map<String, List<WidgetModel>> grouped;
      try {
        grouped = groupWidgetsByCategory(_libraryWidgets, query: _query);
        print('✅ [build] groupWidgetsByCategory succeeded: ${grouped.keys.length} categories');
      } catch (e, st) {
        print('❌ [build] groupWidgetsByCategory failed: $e');
        print('📍 Stack: $st');
        return ListScreen(
          title: 'Widget Library',
          subtitle: 'Browse every widget, search by category, and add tools to your shared-screen workspace.',
          searchBar: MyAiSearchField(
            controller: _searchController,
            hintText: 'Search by widget or category',
            onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
            onClear: () {
              _searchController.clear();
              setState(() => _query = '');
            },
          ),
          body: MyAiEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Error organizing widgets',
            subtitle: 'Failed to organize widgets: $e',
            action: MyAiGradientButton(
              onPressed: () => _loadData(showLoader: true),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        );
      }

      if (grouped.isEmpty) {
        return ListScreen(
          title: 'Widget Library',
          subtitle: 'Browse every widget, search by category, and add tools to your shared-screen workspace.',
          searchBar: MyAiSearchField(
            controller: _searchController,
            hintText: 'Search by widget or category',
            onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
            onClear: () {
              _searchController.clear();
              setState(() => _query = '');
            },
          ),
          body: const MyAiEmptyState(
            icon: Icons.search_off_rounded,
            title: 'No widgets found',
            subtitle: 'Try another widget name or category.',
          ),
        );
      }

      return ListScreen(
        title: 'Widget Library',
        subtitle: 'Browse every widget, search by category, and add tools to your shared-screen workspace.',
        searchBar: MyAiSearchField(
          controller: _searchController,
          hintText: 'Search by widget or category',
          onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
          onClear: () {
            _searchController.clear();
            setState(() => _query = '');
          },
        ),
        body: _buildOptimizedListView(grouped),
      );
    } catch (e, st) {
      print('❌ [build] Fatal error: $e');
      print('📍 Stack: $st');
      return ListScreen(
        title: 'Widget Library',
        subtitle: 'Browse every widget, search by category, and add tools to your shared-screen workspace.',
        searchBar: MyAiSearchField(
          controller: _searchController,
          hintText: 'Search by widget or category',
          onChanged: (value) {},
          onClear: () {},
        ),
        body: MyAiEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Critical Error',
          subtitle: 'Failed to render widget library: $e',
          action: MyAiGradientButton(
            onPressed: () => _loadData(showLoader: true),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      );
    }
  }
}