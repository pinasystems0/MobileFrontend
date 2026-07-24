import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';

/// Reusable service that wraps the POST /api/registration/done endpoint.
///
/// The backend is the single source of truth for registration status.
/// SharedPreferences is used only to cache the backend response so the
/// frontend can render the correct UI without a second network call.
class RegistrationCompletionService {
  static const Duration _requestTimeout = Duration(seconds: 20);

  /// Completes the registration by calling POST /api/registration/done.
  ///
  /// Returns `true` if the backend confirmed success, `false` otherwise.
  /// On success the response (including assigned balance) is cached locally.
  static Future<bool> completeRegistration({
    required String email,
  }) async {
    final token = await SessionService.getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final response = await http
        .post(
          Uri.parse('${ApiConstants.authUrl}/api/registration/done'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'email': email}),
        )
        .timeout(_requestTimeout);

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && data['success'] == true) {
      // Cache the backend response locally so the frontend can use it
      // without an additional network call. The backend remains the
      // source of truth.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('registrationCompleted', true);
      await prefs.setBool('completedStep3', true);

      // Cache the assigned balance if the backend provides one
      if (data['balance'] != null) {
        await prefs.setInt('registrationBalance', data['balance'] as int);
      }

      return true;
    }

    throw Exception(data['message'] ?? 'Registration completion failed');
  }
}

