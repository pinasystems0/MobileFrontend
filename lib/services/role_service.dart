import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/constants.dart';
import 'feature_permissions.dart' as permissions;
import 'session_service.dart';

class RoleService {
  static const String _rbacFeaturePermissionsKey = 'rbacFeaturePermissions';
  static const String _rbacFreeConversionKeysKey = 'rbacFreeConversionKeys';

  static String? _currentCategory;
  static String? _currentUserType;
  static permissions.FeaturePermissionMap _featurePermissions =
      <String, List<String>>{};
  static List<String> _freeConversionKeys = <String>[];
  static bool _isFetching = false;

  // ✅ STEP 1: REMOVED duplicate _featurePermissionsMap

  static List<String> getAllowedRoles(String feature) {
    return List<String>.from(_featurePermissions[feature] ?? const <String>[]);
  }

  static void hydrate({
    String? category,
    String? userType,
  }) {
    final cleanCategory = category?.trim();
    final cleanUserType = userType?.trim();

    if (cleanCategory != null && cleanCategory.isNotEmpty) {
      _currentCategory = cleanCategory;
    }

    if (cleanUserType != null && cleanUserType.isNotEmpty) {
      _currentUserType = cleanUserType;
    }
  }

  static Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    hydrate(
      category: prefs.getString('category') ?? prefs.getString('userRole'),
      userType: prefs.getString('userType'),
    );

    final rawPermissions = prefs.getString(_rbacFeaturePermissionsKey);
    if (rawPermissions != null && rawPermissions.isNotEmpty) {
      try {
        _featurePermissions =
            permissions.normalizeFeaturePermissions(jsonDecode(rawPermissions));
      } catch (_) {
        _featurePermissions = <String, List<String>>{};
      }
    }

    _freeConversionKeys = permissions.normalizeFreeConversionKeys(
      prefs.getStringList(_rbacFreeConversionKeysKey),
    );
  }

  static Future<void> _storeRbacSnapshot({
    required permissions.FeaturePermissionMap featurePermissions,
    required List<String> freeConversionKeys,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _featurePermissions = featurePermissions;
    _freeConversionKeys = freeConversionKeys;

    await prefs.setString(
      _rbacFeaturePermissionsKey,
      jsonEncode(featurePermissions),
    );
    await prefs.setStringList(_rbacFreeConversionKeysKey, freeConversionKeys);
  }

  static Future<bool> _fetchRole() async {
    if (_isFetching) {
      return _currentCategory != null;
    }

    _isFetching = true;

    try {
      final headers = await SessionService.authHeaders();
      if (!headers.containsKey('Authorization')) {
        debugPrint('RoleService: No auth token, skipping fetch');
        return false;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.authUrl}/api/auth/profile'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return false;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>? ?? {};
      final newCategory = user['category']?.toString();
      final newUserType = user['userType']?.toString();
      final rbac = data['rbac'] as Map<String, dynamic>? ?? {};

      // ✅ STEP 2: REMOVED duplicate _featurePermissionsMap code
      // Directly use featurePermissions from normalizeFeaturePermissions
      final featurePermissions = permissions.normalizeFeaturePermissions(
        rbac['featurePermissions'],
      );
      final freeConversionKeys = permissions.normalizeFreeConversionKeys(
        rbac['freeConversionKeys'],
      );

      await _storeRbacSnapshot(
        featurePermissions: featurePermissions,
        freeConversionKeys: freeConversionKeys,
      );

      if (newCategory != null && newCategory.isNotEmpty) {
        hydrate(category: newCategory, userType: newUserType);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('category', newCategory);
        await prefs.setString('userRole', newCategory);
        if (newUserType != null && newUserType.isNotEmpty) {
          await prefs.setString('userType', newUserType);
        }

        debugPrint(
          'RoleService: Fetched category: $newCategory, userType: ${newUserType ?? ''}',
        );
        return true;
      }
    } catch (e) {
      debugPrint('RoleService fetch error: $e');
    } finally {
      _isFetching = false;
    }

    return false;
  }

  static Future<void> init() async {
    await _loadFromPrefs();
    await _fetchRole();
  }

  static Future<bool> refreshRole() async {
    await _loadFromPrefs();
    return await _fetchRole() ||
        _currentCategory != null ||
        _featurePermissions.isNotEmpty;
  }

  static Future<bool> canAccess(String feature) async {
    if (_currentCategory == null || _featurePermissions.isEmpty) {
      await _loadFromPrefs();
      if (_currentCategory == null || _featurePermissions.isEmpty) {
        final fetched = await _fetchRole();
        if (!fetched && _featurePermissions.isEmpty) {
          return false;
        }
      }
    }

    // ✅ STEP 3: FIXED canAccess() - Use _featurePermissions directly
    return permissions.canAccess(_featurePermissions, feature, _currentCategory);
  }

  // ✅ STEP 4: FIXED canAccessSync() - Use _featurePermissions directly
  static bool canAccessSync(String feature) {
    return permissions.canAccess(_featurePermissions, feature, _currentCategory);
  }

  static bool canAccessConversionOptionSync(String optionTitle) {
    if (permissions.isFreeConversionOption(_freeConversionKeys, optionTitle)) {
      return true;
    }

    return canAccessPaidConversionSync;
  }

  // ✅ STEP 5: FIXED paid conversion - Use _featurePermissions directly
  static bool get canAccessPaidConversionSync {
    return permissions.canAccess(_featurePermissions, 'CONVERSION', _currentCategory) &&
        userType.toLowerCase() == 'paid';
  }

  static String get category => _currentCategory ?? 'unknown';
  static String get userType => _currentUserType ?? 'unknown';

  static bool isTeacher() {
  return _currentCategory?.toLowerCase() == 'teacher';
}

static bool isStudent() {
  return _currentCategory?.toLowerCase() == 'student';
}

  static Future<void> clear() async {
    _currentCategory = null;
    _currentUserType = null;
    _featurePermissions = <String, List<String>>{};
    _freeConversionKeys = <String>[];

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('category');
    await prefs.remove('userRole');
    await prefs.remove('userType');
    await prefs.remove(_rbacFeaturePermissionsKey);
    await prefs.remove(_rbacFreeConversionKeysKey);
  }
}