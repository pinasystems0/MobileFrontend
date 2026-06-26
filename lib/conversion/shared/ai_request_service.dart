import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';

class AiRequestService {
  String get _generateUrl => "${ApiConstants.authUrl}/api/ai/generate";

  Future<Map<String, dynamic>> generateAIResponse({
    required String prompt,
    required String from,
    required String to,
    double temperature = 0.7,
    required String userId,
    String? provider,
    int? maxTokens,
    File? file,
    Map<String, dynamic> parameters = const {},
  }) async {
    if (prompt.trim().isEmpty) {
      return {
        "success": false,
        "error": "Prompt cannot be empty.",
      };
    }

    try {
      final Map<String, dynamic> payload = {
        "prompt": prompt,
        "from": from,
        "to": to,
        "temperature": temperature,
        "userId": userId,
      };

      if (provider != null && provider.trim().isNotEmpty) {
        payload["provider"] = provider;
      }

      if (maxTokens != null) {
        payload["maxTokens"] = maxTokens;
      }

      // Add parameters to payload if not empty
      if (parameters.isNotEmpty) {
        payload["parameters"] = parameters;
      }

      if (file == null) {
        return _sendJsonRequest(payload);
      }

      return _sendMultipartRequest(
        payload: payload,
        file: file,
        parameters: parameters,
      );
    } catch (e) {
      return {
        "success": false,
        "error": "Connection failed: $e",
      };
    }
  }

  Future<Map<String, dynamic>> _sendJsonRequest(
    Map<String, dynamic> payload,
  ) async {
    final response = await http
        .post(
          Uri.parse(_generateUrl),
          headers: await SessionService.authHeaders(
            includeJsonContentType: true,
          ),
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 60));

    return _normalizeResponse(response);
  }

  Future<Map<String, dynamic>> _sendMultipartRequest({
    required Map<String, dynamic> payload,
    required File file,
    required Map<String, dynamic> parameters,
  }) async {
    final request = http.MultipartRequest("POST", Uri.parse(_generateUrl));
    request.headers.addAll(await SessionService.authHeaders());

    for (final entry in payload.entries) {
      if (entry.key == "parameters") continue;
      request.fields[entry.key] = entry.value.toString();
    }

    for (final entry in parameters.entries) {
      if (entry.value == null) continue;
      request.fields[entry.key] = entry.value.toString();
    }

    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 120));
    final response = await http.Response.fromStream(streamedResponse);

    return _normalizeResponse(response);
  }

  Map<String, dynamic> _normalizeResponse(http.Response response) {
    final dynamic decoded = _decodeResponseBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {
        "success": false,
        "error": "Unexpected response format.",
        "statusCode": response.statusCode,
      };
    }

    if (decoded is Map<String, dynamic>) {
      return {
        "success": false,
        "statusCode": response.statusCode,
        ...decoded,
      };
    }

    return {
      "success": false,
      "statusCode": response.statusCode,
      "error": "Request failed.",
    };
  }

  dynamic _decodeResponseBody(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(body);
    } catch (_) {
      return {
        "success": false,
        "error": body,
      };
    }
  }
}
