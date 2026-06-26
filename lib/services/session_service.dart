import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pina/screens/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _userIdKey = 'userId';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';
  static const String _authTokenKey = 'authToken';
  static const String _userRoleKey = 'userRole';
  static const String _categoryKey = 'category';
  static const String _userTypeKey = 'userType';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static String _tokenPreview(String? token) {
    final cleaned = _clean(token);
    if (cleaned == null) {
      return 'none';
    }
    if (cleaned.length <= 16) {
      return cleaned;
    }
    return '${cleaned.substring(0, 8)}...${cleaned.substring(cleaned.length - 6)}';
  }

  static Map<String, dynamic>? _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) {
      return null;
    }

    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      if (payload is Map) {
        return payload.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static String _describeTokenState(String? token) {
    final cleaned = _clean(token);
    if (cleaned == null) {
      return 'missing';
    }

    final payload = _decodeJwtPayload(cleaned);
    if (payload == null) {
      return 'present-unparseable';
    }

    final expSeconds = payload['exp'];
    if (expSeconds is! num) {
      return 'present-no-exp';
    }

    final expiry = DateTime.fromMillisecondsSinceEpoch(
      expSeconds.toInt() * 1000,
      isUtc: true,
    );
    final now = DateTime.now().toUtc();

    if (expiry.isBefore(now)) {
      return 'expired:${expiry.toIso8601String()}';
    }

    return 'valid:${expiry.toIso8601String()}';
  }

  static bool _looksLikeMongoId(String? value) {
    if (value == null) {
      return false;
    }
    return RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(value);
  }

  static Future<String?> _migrateLegacyToken(SharedPreferences prefs) async {
    final legacyToken = _clean(prefs.getString(_authTokenKey));
    if (legacyToken == null) {
      return null;
    }

    await _secureStorage.write(key: _authTokenKey, value: legacyToken);
    await prefs.remove(_authTokenKey);
    return legacyToken;
  }

  static String? resolveMongoUserId(
    Map<String, dynamic>? data, {
    Map<String, dynamic>? user,
    dynamic directValue,
  }) {
    final candidates = <dynamic>[
      directValue,
      user?['_id'],
      user?['id'],
      user?['userId'],
      user?['affiliateId'],
      user?['affiliateUserId'],
      data?['_id'],
      data?['id'],
      data?['userId'],
      data?['affiliateId'],
      data?['affiliateUserId'],
    ];

    for (final candidate in candidates) {
      final cleaned = _clean(candidate?.toString());
      if (cleaned != null) {
        return cleaned;
      }
    }

    return null;
  }

  static Future<String?> _refreshMongoUserId(SharedPreferences prefs) async {
    final token = await getAuthToken();
    if (token == null) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.authUrl}/api/auth/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final rawUser = decoded['user'];
      final user = rawUser is Map<String, dynamic>
          ? rawUser
          : rawUser is Map
              ? rawUser.map(
                  (key, value) => MapEntry(key.toString(), value),
                )
              : <String, dynamic>{};

      final mongoUserId = resolveMongoUserId(decoded, user: user);
      if (mongoUserId == null) {
        return null;
      }

      await prefs.setString(_userIdKey, mongoUserId);
      return mongoUserId;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getUserId() async {
    final prefs = await _prefs();
    final storedString = _clean(prefs.getString(_userIdKey));
    if (storedString != null) {
      if (_looksLikeMongoId(storedString)) {
        return storedString;
      }

      final refreshed = await _refreshMongoUserId(prefs);
      return refreshed ?? storedString;
    }

    final legacyInt = prefs.getInt(_userIdKey);
    if (legacyInt != null) {
      final migrated = legacyInt.toString();
      await prefs.remove(_userIdKey);
      await prefs.setString(_userIdKey, migrated);
    }

    return _refreshMongoUserId(prefs) ?? _clean(prefs.getString(_userIdKey));
  }

  static Future<String?> getUserName() async {
    final prefs = await _prefs();
    return _clean(prefs.getString(_userNameKey));
  }

  static Future<String?> getUserEmail() async {
    final prefs = await _prefs();
    return _clean(prefs.getString(_userEmailKey));
  }

  static Future<String?> getAuthToken() async {
    final secureToken = _clean(await _secureStorage.read(key: _authTokenKey));
    if (secureToken != null) {
      return secureToken;
    }

    final prefs = await _prefs();
    return _migrateLegacyToken(prefs);
  }

  static Future<String?> getUserRole() async {
    final prefs = await _prefs();
    return _clean(prefs.getString(_userRoleKey)) ??
        _clean(prefs.getString(_categoryKey));
  }

  static Future<String?> getUserType() async {
    final prefs = await _prefs();
    return _clean(prefs.getString(_userTypeKey));
  }

  static Future<void> saveSession({
    required String userId,
    String? userName,
    String? userEmail,
    String? authToken,
    String? userRole,
    String? userType,
    bool? completedStep1,
    bool? completedStep2,
    bool? completedStep3,
  }) async {
    final prefs = await _prefs();
    await prefs.remove(_userIdKey);
    await prefs.setString(_userIdKey, userId);

    final cleanName = _clean(userName);
    if (cleanName != null) {
      await prefs.setString(_userNameKey, cleanName);
    }

    final cleanEmail = _clean(userEmail);
    if (cleanEmail != null) {
      await prefs.setString(_userEmailKey, cleanEmail);
    }

    final cleanToken = _clean(authToken);
    if (cleanToken != null) {
      await _secureStorage.write(key: _authTokenKey, value: cleanToken);
      await prefs.remove(_authTokenKey);
    }

    final cleanRole = _clean(userRole);
    if (cleanRole != null) {
      await prefs.setString(_userRoleKey, cleanRole);
      await prefs.setString(_categoryKey, cleanRole);
    }

    final cleanUserType = _clean(userType);
    if (cleanUserType != null) {
      await prefs.setString(_userTypeKey, cleanUserType);
    }

    if (completedStep1 != null) {
      await prefs.setBool('completedStep1', completedStep1);
    }
    if (completedStep2 != null) {
      await prefs.setBool('completedStep2', completedStep2);
    }
    if (completedStep3 != null) {
      await prefs.setBool('completedStep3', completedStep3);
    }
  }

  static Future<void> saveRegistrationProgress({
    bool? completedStep1,
    bool? completedStep2,
    bool? completedStep3,
  }) async {
    final prefs = await _prefs();

    if (completedStep1 != null) {
      await prefs.setBool('completedStep1', completedStep1);
    }
    if (completedStep2 != null) {
      await prefs.setBool('completedStep2', completedStep2);
    }
    if (completedStep3 != null) {
      await prefs.setBool('completedStep3', completedStep3);
    }
  }

  /// Clears auth-related session values.
  ///
  /// Note: This is intentionally more aggressive than [clearAuthOnly].
  /// It is suitable when you want to fully reset onboarding + feature state.
  static Future<void> clearSession() async {
    final prefs = await _prefs();

    await _secureStorage.delete(key: _authTokenKey);

    final keysToRemove = <String>[
      _userIdKey,
      _userNameKey,
      _userEmailKey,
      _userRoleKey,
      _categoryKey,
      _userTypeKey,
      'completedStep1',
      'completedStep2',
      'completedStep3',
      'postLoginFeature',
    ];

    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }

  /// Clears only the authentication identifiers.
  ///
  /// Used for flows like "email verification required" where we must
  /// keep onboarding progress intact.
  ///
  /// Removes ONLY:
  /// - authToken
  /// - userId
  /// - userEmail
  /// - userName
  ///
  /// Does NOT remove:
  /// - completedStep1/2/3
  /// - userRole/category/userType
  static Future<void> clearAuthOnly() async {
    final prefs = await _prefs();

    await _secureStorage.delete(key: _authTokenKey);

    final keysToRemove = <String>[
      _userIdKey,
      _userNameKey,
      _userEmailKey,
    ];

    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }


  static Future<Map<String, String>> authHeaders({
    bool includeJsonContentType = false,
  }) async {
    final headers = <String, String>{};
    if (includeJsonContentType) {
      headers['Content-Type'] = 'application/json';
    }

    final token = await getAuthToken();
    final tokenState = _describeTokenState(token);
    final preview = _tokenPreview(token);

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final safeHeaders = <String, String>{
      ...headers,
      if (headers.containsKey('Authorization')) 'Authorization': 'Bearer <redacted>',
    };

    print(
      'SessionService.authHeaders: authUrl=${ApiConstants.authUrl} '
      'includeJsonContentType=$includeJsonContentType '
      'tokenPresent=${token != null} tokenState=$tokenState tokenPreview=$preview '
      'headers=$safeHeaders',
    );

    return headers;
  }
}
