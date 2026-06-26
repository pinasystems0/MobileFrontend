typedef FeaturePermissionMap = Map<String, List<String>>;

FeaturePermissionMap normalizeFeaturePermissions(dynamic raw) {
  if (raw is! Map) {
    return <String, List<String>>{};
  }

  final permissions = <String, List<String>>{};

  for (final entry in raw.entries) {
    final key = entry.key?.toString().trim();
    if (key == null || key.isEmpty) {
      continue;
    }

    final value = entry.value;
    if (value is! List) {
      continue;
    }

    permissions[key] = value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  return permissions;
}

List<String> normalizeFreeConversionKeys(dynamic raw) {
  if (raw is! List) {
    return const <String>[];
  }

  return raw
      .map((item) => item?.toString().trim().toLowerCase() ?? '')
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList(growable: false);
}

bool canAccess(
  FeaturePermissionMap permissions,
  String feature,
  String? userCategory,
) {
  final category = userCategory?.trim();
  if (category == null || category.isEmpty) {
    return false;
  }

  return permissions[feature]?.contains(category) ?? false;
}

String normalizeConversionOptionKey(String optionTitle) {
  return optionTitle.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
}

bool isFreeConversionOption(List<String> freeKeys, String optionTitle) {
  return freeKeys.contains(normalizeConversionOptionKey(optionTitle));
}
