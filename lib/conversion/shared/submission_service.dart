import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pina/screens/constants.dart';

class SubmissionResult {
  final bool success;
  final String? errorMessage;
  final int? promptId;
  final int statusCode;

  SubmissionResult({
    required this.success,
    this.errorMessage,
    this.promptId,
    required this.statusCode,
  });
}

class SubmissionService {
  String get saveInputUrl => "${ApiConstants.authUrl}/api/save-input";
  String get saveOutputUrl => "${ApiConstants.authUrl}/api/save-output";
  String get checkStatusUrl =>
      "${ApiConstants.authUrl}/api/auth/check-user-status";

  Future<SubmissionResult> checkUserEligibility({
    required String userEmail,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(checkStatusUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userEmail": userEmail}),
      );
      final body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return SubmissionResult(success: true, statusCode: 200);
      }

      return SubmissionResult(
        success: false,
        errorMessage: body['error'] ?? "Account not eligible",
        statusCode: res.statusCode,
      );
    } catch (e) {
      return SubmissionResult(
        success: false,
        errorMessage: "Connection failed: $e",
        statusCode: 500,
      );
    }
  }

  Future<SubmissionResult> validateAndSaveInput({
    required String userId,
    required String userEmail,
    required String prompt,
    required List<String> fromList,
    required List<String> toList,
    Map<String, dynamic>? inputParams,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(saveInputUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "userEmail": userEmail,
          "prompt": prompt,
          "from": fromList,
          "to": toList,
          "inputParams": inputParams ?? {},
        }),
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return SubmissionResult(
          success: true,
          promptId: body['promptId'],
          statusCode: 200,
        );
      }

      return SubmissionResult(
        success: false,
        errorMessage: body['error'] ?? "Unknown Server Error",
        statusCode: res.statusCode,
      );
    } catch (e) {
      return SubmissionResult(
        success: false,
        errorMessage: "Connection failed: $e",
        statusCode: 500,
      );
    }
  }

  Future<void> saveOutput({
    required int promptId,
    required String userId,
    required String content,
    required String modelName,
    Map<String, dynamic>? outputParams,
    List<dynamic>? errorLogs,
  }) async {
    try {
      await http.post(
        Uri.parse(saveOutputUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "promptId": promptId,
          "userId": userId,
          "content": content,
          "modelName": modelName,
          "outputParams": outputParams ?? {},
          "errorLogs": errorLogs ?? [],
        }),
      );
    } catch (_) {}
  }
}
