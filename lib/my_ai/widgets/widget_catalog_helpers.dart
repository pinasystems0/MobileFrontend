import '../models/widget_model.dart';

String normalizeWidgetName(String value) {
  try {
    if (value == null || value.isEmpty) return '';
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  } catch (e) {
    print('❌ [normalizeWidgetName] Error: $e');
    return '';
  }
}

String widgetCategoryLabel(String value) {
  try {
    if (value == null || value.isEmpty) return 'Other';
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Other' : trimmed;
  } catch (e) {
    print('❌ [widgetCategoryLabel] Error: $e');
    return 'Other';
  }
}

List<WidgetModel> dedupeWidgets(List<WidgetModel> items) {
  try {
    if (items == null || items.isEmpty) {
      print('⚠️ [dedupeWidgets] No items to dedupe');
      return [];
    }

    final unique = <String, WidgetModel>{};

    for (final item in items) {
      try {
        if (item == null) {
          print('⚠️ [dedupeWidgets] Skipping null item');
          continue;
        }

        final key = normalizeWidgetName(item.widgetName ?? '');
        
        if (key.isEmpty) {
          print('⚠️ [dedupeWidgets] Skipping item with empty normalized name: ${item.widgetName}');
          continue;
        }

        if (unique.containsKey(key)) {
          print('⚠️ [dedupeWidgets] Duplicate found, skipping: $key');
          continue;
        }

        unique[key] = item;
      } catch (e) {
        print('❌ [dedupeWidgets] Error processing item: $e');
        continue;
      }
    }

    print('✅ [dedupeWidgets] Deduplicated ${items.length} items to ${unique.length}');

    try {
      final deduped = unique.values.toList(growable: false);
      
      deduped.sort((a, b) {
        try {
          if (a == null || b == null) {
            return 0;
          }

          final categoryA = widgetCategoryLabel(a.visitCategory ?? '');
          final categoryB = widgetCategoryLabel(b.visitCategory ?? '');
          
          final categoryCompare = categoryA.compareTo(categoryB);
          if (categoryCompare != 0) {
            return categoryCompare;
          }

          final nameA = a.widgetName?.toLowerCase() ?? '';
          final nameB = b.widgetName?.toLowerCase() ?? '';
          return nameA.compareTo(nameB);
        } catch (e) {
          print('❌ [dedupeWidgets] Error comparing: $e');
          return 0;
        }
      });

      print('✅ [dedupeWidgets] Sorting completed');
      return deduped;
    } catch (e) {
      print('❌ [dedupeWidgets] Error during sorting: $e');
      return unique.values.toList(growable: false);
    }
  } catch (e) {
    print('❌ [dedupeWidgets] Fatal error: $e');
    return [];
  }
}

bool matchesWidgetQuery(WidgetModel item, String query) {
  try {
    if (item == null) {
      return false;
    }

    if (query == null || query.isEmpty) {
      return true;
    }

    final normalizedQuery = query.toLowerCase().trim();
    
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final widgetName = (item.widgetName ?? '').toLowerCase();
    final categoryName = widgetCategoryLabel(item.visitCategory ?? '').toLowerCase();

    return widgetName.contains(normalizedQuery) || categoryName.contains(normalizedQuery);
  } catch (e) {
    print('❌ [matchesWidgetQuery] Error: $e');
    return false;
  }
}

Map<String, List<WidgetModel>> groupWidgetsByCategory(
  List<WidgetModel> items, {
  String query = '',
}) {
  try {
    print('📂 [groupWidgetsByCategory] Starting with ${items?.length ?? 0} items, query="$query"');

    if (items == null || items.isEmpty) {
      print('⚠️ [groupWidgetsByCategory] No items to group');
      return {};
    }

    final grouped = <String, List<WidgetModel>>{};
    int processedCount = 0;
    int skippedCount = 0;

    for (int i = 0; i < items.length; i++) {
      try {
        final item = items[i];

        if (item == null) {
          print('⚠️ [groupWidgetsByCategory] Skipping null item at index $i');
          skippedCount++;
          continue;
        }

        // Check if item matches query
        if (!matchesWidgetQuery(item, query)) {
          skippedCount++;
          continue;
        }

        try {
          final category = widgetCategoryLabel(item.visitCategory ?? '');
          
          if (!grouped.containsKey(category)) {
            grouped[category] = <WidgetModel>[];
          }
          
          grouped[category]!.add(item);
          processedCount++;
          
          // Log every 10 items to track progress
          if (processedCount % 10 == 0) {
            print('   ✅ Processed $processedCount items...');
          }
        } catch (e) {
          print('❌ [groupWidgetsByCategory] Error grouping widget at index $i: ${item.widgetName} - Error: $e');
          skippedCount++;
          continue;
        }
      } catch (e) {
        print('❌ [groupWidgetsByCategory] Error at index $i: $e');
        skippedCount++;
        continue;
      }
    }

    print('✅ [groupWidgetsByCategory] Processed $processedCount items, skipped $skippedCount');
    print('📊 [groupWidgetsByCategory] Created ${grouped.keys.length} categories');

    // Sort widgets within each category
    try {
      for (final category in grouped.keys) {
        try {
          final widgets = grouped[category];
          
          if (widgets == null || widgets.isEmpty) {
            continue;
          }

          widgets.sort((a, b) {
            try {
              if (a == null || b == null) {
                return 0;
              }

              final nameA = (a.widgetName ?? '').toLowerCase();
              final nameB = (b.widgetName ?? '').toLowerCase();
              return nameA.compareTo(nameB);
            } catch (e) {
              print('❌ [groupWidgetsByCategory] Error comparing widgets in category "$category": $e');
              return 0;
            }
          });

          print('   ✅ Sorted category "$category": ${widgets.length} widgets');
        } catch (e) {
          print('❌ [groupWidgetsByCategory] Error sorting category "$category": $e');
          continue;
        }
      }
    } catch (e) {
      print('❌ [groupWidgetsByCategory] Error during category sorting: $e');
    }

    print('✅ [groupWidgetsByCategory] Completed successfully - ${grouped.keys.length} categories');
    
    // Log category distribution
    for (final entry in grouped.entries) {
      print('   📂 ${entry.key}: ${entry.value.length} widgets');
    }

    return grouped;
  } catch (e, stackTrace) {
    print('❌ [groupWidgetsByCategory] FATAL ERROR: $e');
    print('📍 Stack trace: $stackTrace');
    return {};
  }
}