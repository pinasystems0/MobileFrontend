import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';


class GenerateService {

  static String get baseUrl =>
      ApiConstants.baseUrl;

  static Future<Map<String, dynamic>> generateStudentContent({
    required Map<String, dynamic> studentContext,
    required Map<String, dynamic> params,
    required String prompt,
  }) async {

    try {

      final token = await SessionService.getAuthToken();


      if (token == null || token.isEmpty) {

        return {
          "success": false,
          "message": "Token not found",
        };
      }

      final body = {
        "studentContext": studentContext,
        "params": params,
        "prompt": prompt,
      };

      // ✅ IMPROVEMENT 3: REQUEST TIMEOUT ADDED (90 seconds)
      final response = await http.post(

        Uri.parse('$baseUrl/api/generate'),

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },

        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 90),
        onTimeout: () {
          // Return a timeout response
          throw Exception('Request timeout after 90 seconds');
        },
      );

      // ✅ IMPROVEMENT 1: HTTP STATUS CHECK BEFORE JSON DECODE
      if (response.statusCode < 200 ||
          response.statusCode >= 300) {

        return {
          "success": false,
          "message": "Server error (${response.statusCode})",
        };
      }


      // ✅ IMPROVEMENT 2: JSON CRASH SAFETY
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        return {
          "success": false,
          "message": "Invalid server response",
        };
      }

      return data;

    } catch (e) {

      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> generateTeacherContent({
    required Map<String, dynamic> teacherContext,
    required Map<String, dynamic> params,
  }) async {
    try {
      final token = await SessionService.getAuthToken();


      if (token == null || token.isEmpty) {
        return {
          "success": false,
          "message": "Token not found",
        };
      }

      // Match Student request shape: /api/generate expects `prompt` (mapped to req.body.prompt)
      // Teacher currently uses params.additionalInstructions (and teachingGoal) as extra instruction.
      final teacherExtraPrompt = [
        (params['teachingGoal'] ?? '').toString().trim(),
        (params['additionalInstructions'] ?? '').toString().trim(),
      ].where((s) => s.isNotEmpty).join("\n\n").trim();

      final body = {
        "teacherContext": teacherContext,
        "params": params,
        "prompt": teacherExtraPrompt,
      };

      // ✅ IMPROVEMENT 3: REQUEST TIMEOUT ADDED (90 seconds)
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 90),
        onTimeout: () {
          throw Exception('Request timeout after 90 seconds');
        },
      );

      // ✅ IMPROVEMENT 1: HTTP STATUS CHECK BEFORE JSON DECODE
      if (response.statusCode < 200 ||
          response.statusCode >= 300) {

        return {
          "success": false,
          "message": "Server error (${response.statusCode})",
        };
      }

      // ✅ IMPROVEMENT 2: JSON CRASH SAFETY
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        return {
          "success": false,
          "message": "Invalid server response",
        };
      }

      return data;
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
}