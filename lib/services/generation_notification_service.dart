import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local notification helper for AI generation completion.
///
/// Requirements:
/// - Use existing channel: arthum_notifications
/// - Persist payload in SharedPreferences so tap works even if app was closed
class GenerationNotificationService {
  static const String _kPrefPayloadKey = 'gen_notif_payload_v1';
  static const String _kPrefPendingTapKey = 'gen_notif_pending_tap_v1';

  static const String _kChannelId = 'arthum_notifications';

  static const String kActionStudent = 'student_generate';
  static const String kActionTeacher = 'teacher_generate';

  /// Call on successful generation.
  static Future<void> createGenerationCompletedNotification({
    required String type,
    required String generatedOutput,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final payload = <String, dynamic>{
      'type': type,
      'generatedOutput': generatedOutput,
    };

    await prefs.setString(_kPrefPayloadKey, jsonEncode(payload));

    // Flag used by screens to know whether notification was tapped.
    await prefs.setBool(_kPrefPendingTapKey, false);

    final plugin = FlutterLocalNotificationsPlugin();

    // Notification payload is not relying on details payload (plugin callback
    // handling differs by platform). We persist output + type above.
    const androidDetails = AndroidNotificationDetails(
      _kChannelId,
      'Registration Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Content Ready 🎉',
      'Your AI generated content is ready. Tap to view.',
      details,
      payload: jsonEncode({'type': type}),
    );
  }

  /// Called from main.dart when user taps notification.
  static Future<void> markPendingTapAndReturnPayload() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrefPendingTapKey, true);
  }

  static Future<Map<String, dynamic>?> takePendingPayloadIfAny() async {
    final prefs = await SharedPreferences.getInstance();

    final pending = prefs.getBool(_kPrefPendingTapKey) ?? false;
    if (!pending) return null;

    final raw = prefs.getString(_kPrefPayloadKey);
    await prefs.setBool(_kPrefPendingTapKey, false);

    if (raw == null) return null;

    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

