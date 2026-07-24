import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Backend-connected chatbot service.
///
/// Sends user questions to the existing backend at /api/chatbot/chat.
@immutable
class ChatbotService {
  const ChatbotService();

  Future<String> sendChatMessage({required String question}) async {
    final trimmedQuestion = question.trim();
    if (trimmedQuestion.isEmpty) {
      throw ArgumentError('Question cannot be empty.');
    }

    final studentId = await SessionService.getUserId();
    if (studentId == null || studentId.isEmpty) {
      throw Exception('Unable to determine current student id from session.');
    }

    final uri = await _buildUri('/api/chatbot/chat');
    final headers = await SessionService.authHeaders(includeJsonContentType: true);
    final body = <String, dynamic>{
      'studentId': studentId,
      'question': trimmedQuestion,
    };
    final bodyJson = jsonEncode(body);

    debugPrint('========== CHATBOT REQUEST ==========');
    debugPrint('URI: $uri');
    debugPrint('Student ID: $studentId');
    debugPrint('Headers: $headers');
    debugPrint('Body: $bodyJson');

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: bodyJson,
      );

      debugPrint('========== CHATBOT RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorBody = response.body.trim();
        final errorMessage = _extractErrorMessage(errorBody);
        throw Exception('Chatbot request failed: $errorMessage');
      }

      if (response.body.trim().isEmpty) {
        return '';
      }

      final decoded = _decodeJson(response.body);
      debugPrint('========== CHATBOT RESPONSE DECODED ==========');
      debugPrint(decoded.toString());
      return _extractResponseText(decoded);
    } catch (error, stackTrace) {
      debugPrint('========== CHATBOT SERVICE ERROR ==========');
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  Future<Uri> _buildUri(String endpoint) async {
    final baseUrl = await _resolveBaseUrl();
    final normalizedBase = baseUrl.trim().replaceAll(RegExp(r'/+$'), '').replaceAll(RegExp(r'/$'), '');
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return Uri.parse('$normalizedBase$normalizedEndpoint');
  }

  Future<String> _resolveBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('apiBaseUrl');
    return (saved != null && saved.trim().isNotEmpty)
        ? saved.trim()
        : ApiConstants.authUrl;
  }

  dynamic _decodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _extractResponseText(dynamic decoded) {
    if (decoded is String) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final payload = _resolvePayload(decoded);

      if (payload['success'] == false) {
        return payload['message']?.toString() ?? 'Backend returned an unsuccessful response.';
      }

      if (payload.containsKey('response')) {
        final responseValue = payload['response'];
        if (responseValue is Map<String, dynamic>) {
          return _formatEducationalResponse(responseValue);
        }
        return _extractTextFromDynamic(responseValue);
      }

      if (payload.containsKey('data')) {
        return _extractTextFromDynamic(payload['data']);
      }

      return _extractTextFromDynamic(payload);
    }

    return decoded.toString();
  }

  Map<String, dynamic> _resolvePayload(Map<String, dynamic> decoded) {
    final rawData = decoded['data'];
    if (rawData is Map<String, dynamic>) {
      return rawData;
    }
    return decoded;
  }

  String _formatEducationalResponse(Map<String, dynamic> response) {
    final buffer = StringBuffer();

    final topicName = response['topicName']?.toString().trim();
    if (topicName != null && topicName.isNotEmpty) {
      buffer.writeln(topicName);
      buffer.writeln();
    }

    void addSection(String title, dynamic value, {bool bullets = false}) {
      if (value == null) return;

      if (bullets) {
        final listText = _listToBulletString(value);
        if (listText.isEmpty) return;
        buffer.writeln(title);
        buffer.writeln(listText);
        buffer.writeln();
        return;
      }

      final text = value?.toString().trim();
      if (text == null || text.isEmpty) return;
      buffer.writeln(title);
      buffer.writeln(text);
      buffer.writeln();
    }

    addSection('Definition', response['definition']);
    addSection('Study Material', response['studyMaterial'], bullets: true);
    addSection('Important Points', response['importantPoints'], bullets: true);
    addSection('Worked Examples', response['workedExamples'], bullets: true);
    addSection('Revision Notes', response['revisionNotes'], bullets: true);
    addSection('Related Topics', response['relatedTopics'], bullets: true);

    final formatted = buffer.toString().trim();
    return formatted.isEmpty ? _extractTextFromDynamic(response) : formatted;
  }

  String _listToBulletString(dynamic value) {
    if (value is Iterable) {
      final items = value
          .map((item) => item?.toString().trim())
          .where((item) => item != null && item.isNotEmpty)
          .cast<String>()
          .toList();
      if (items.isEmpty) return '';
      return items.map((item) => '• $item').join('\n');
    }

    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return '';
    return '• $text';
  }

  String _extractTextFromDynamic(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value;
    }

    if (value is Map<String, dynamic>) {
      return value['text']?.toString() ??
          value['message']?.toString() ??
          value['answer']?.toString() ??
          value['content']?.toString() ??
          value['response']?.toString() ??
          jsonEncode(value);
    }

    if (value is Iterable) {
      return value.map(_extractTextFromDynamic).join('\n');
    }

    return value.toString();
  }

  String _extractErrorMessage(String body) {
    if (body.isEmpty) {
      return 'Empty backend response.';
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ?? decoded['error']?.toString() ?? body;
      }
      return decoded.toString();
    } catch (_) {
      return body;
    }
  }
}

