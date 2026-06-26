/// ------------------------------------------------------------
/// 📁 File: myai_api_service.dart
/// 📂 Module: MyAI (Frontend)
///
/// 🧠 Purpose:
/// HTTP client service for all MyAI backend API calls + helpers.
///
/// ⚙️ Responsibilities:
/// - Handles auth base URL resolution
/// - CRUD for widgets/history
/// - Generic callWidget for any endpoint
/// - File multipart uploads (transcribe/safety)
///
/// 🔗 Backend Connection:
/// - Endpoint: /myai/* (widgets/history/search/transcribe/scheduler/safety)
/// - Method: GET/POST/DELETE (JSON/multipart)
/// - Data Flow:
///   UI → service method → http.request → backend routes → JSON response
///
/// 📦 Data Used:
/// - WidgetConfig/WidgetModel
/// - Sent: userEmail/input/file/query/payload
/// - Received: {success, data: results/history/jobs}
///
/// 🔗 Connected Frontend Files:
/// - All screens → callWidget/saveHistory/getUserWidgets/etc.
/// - models/* → fromJson serialization
/// - widget_configs.dart → endpoint resolution
///
/// 🔗 Connected Backend:
/// - myaiRoutes.js → all /myai endpoints
/// - myaiController.js → all handlers
/// - myaiService.js → core business logic
///
/// 🧩 Type:
/// Service (API Client)
///
/// ⚠️ Notes:
/// - Do NOT modify logic here
/// - Central API layer for MyAI
/// ------------------------------------------------------------
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';
import '../config/widget_configs.dart';
import '../models/widget_model.dart';

String? _asNullableString(dynamic v) => v?.toString().trim().isEmpty == true
    ? null
    : v?.toString().trim();

String _safeType(dynamic v, {String defaultValue = 'text'}) {
  final s = _asNullableString(v);
  return (s == null || s.isEmpty) ? defaultValue : s;
}

String _inputTypeFromWidgetConfig(dynamic inputType) {
  final s = _asNullableString(inputType) ?? 'text';
  return s.toLowerCase();
}

String _outputTypeFromWidgetConfig(dynamic outputType, {String defaultValue = 'text'}) {
  final s = _asNullableString(outputType) ?? defaultValue;
  return s.toLowerCase();
}

String _mapWidgetInputType(String inputType) {
  final t = inputType.toLowerCase();
  return t == 'file' ? 'file' : t;
}

String _mapWidgetOutputType(String outputType) {
  final t = outputType.toLowerCase();
  return t.isEmpty ? 'text' : t;
}


// 👇 DYNAMIC BASE URL FROM .env FILE
class _ResolvedWidgetRequest {
  final String title;
  final String key;
  final String action;
  final String apiEndpoint;
  final String inputType;
  final Map<String, dynamic> payload;

  const _ResolvedWidgetRequest({
    required this.title,
    required this.key,
    required this.action,
    required this.apiEndpoint,
    required this.inputType,
    required this.payload,
  });
}

class MyAiApiService {
  String _stringValue(dynamic value) => value?.toString().trim() ?? '';

  String _normalizeEndpoint(String endpoint) {
    final trimmed = endpoint.trim();
    switch (trimmed) {
      case '/myai/safety/deepfake/check':
      case '/api/myai/safety/deepfake/check':
        return '/deepfake/check';
      case '/myai/safety/plagiarism/scan':
      case '/api/myai/safety/plagiarism/scan':
        return '/plagiarism/scan';
      case '/myai/safety/plagiarism/input':
      case '/api/myai/safety/plagiarism/input':
        return '/plagiarism/input';
      case '/myai/safety/plagiarism/output':
      case '/api/myai/safety/plagiarism/output':
        return '/plagiarism/output';
      case '/myai/safety/gdpr/save':
      case '/api/myai/safety/gdpr/save':
        return '/gdpr/save';
      default:
        return trimmed;
    }
  }

  Future<String> _resolveBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('apiBaseUrl');
    return (saved != null && saved.trim().isNotEmpty)
        ? saved.trim()
        : ApiConstants.authUrl;
  }

  Future<Uri> _buildUri(String endpoint, {Map<String, dynamic>? query}) async {
    final base = await _resolveBaseUrl();
    final normalizedEndpoint = _normalizeEndpoint(endpoint);
    final normalizedPath = normalizedEndpoint.startsWith('/api')
        ? normalizedEndpoint
        : '/api${normalizedEndpoint.startsWith('/') ? normalizedEndpoint : '/$normalizedEndpoint'}';
    final uri = Uri.parse('$base$normalizedPath');

    if (query == null || query.isEmpty) return uri;

    final qp = <String, String>{};
    for (final entry in query.entries) {
      final value = _stringValue(entry.value);
      if (value.isNotEmpty) {
        qp[entry.key] = value;
      }
    }

    if (qp.isEmpty) return uri;

    return uri.replace(
      queryParameters: qp,
    );
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.trim().isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true};
      }
      throw Exception('Request failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final map = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'data': decoded};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    throw Exception(map['error']?.toString() ?? 'Request failed: ${response.statusCode}');
  }

  dynamic _extractData(Map<String, dynamic> json) {
    if (json.containsKey('data')) return json['data'];
    return json;
  }

  Future<Map<String, String>> _headers({bool json = false}) {
    return SessionService.authHeaders(includeJsonContentType: json);
  }

  Future<Map<String, dynamic>> _postJson(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      await _buildUri(endpoint),
      headers: await _headers(json: true),
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _getJson(
    String endpoint, {
    Map<String, dynamic>? query,
  }) async {
    final response = await http.get(
      await _buildUri(endpoint, query: query),
      headers: await _headers(),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _deleteJson(
    String endpoint, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
  }) async {
    final response = await http.delete(
      await _buildUri(endpoint, query: query),
      headers: await _headers(json: true),
      body: body == null ? null : jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _postMultipart(
    String endpoint, {
    required String fileField,
    required PlatformFile file,
    Map<String, String>? fields,
  }) async {
    final request = http.MultipartRequest('POST', await _buildUri(endpoint));
    request.headers.addAll(await _headers());

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (file.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          fileField,
          file.bytes!,
          filename: file.name,
        ),
      );
    } else if (file.path != null && file.path!.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(fileField, file.path!),
      );
    } else {
      throw Exception('Selected file is not readable.');
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _decodeResponse(response);
  }

  List<dynamic> _readList(Map<String, dynamic> json) {
    final data = _extractData(json);
    if (data is List) return data;

    if (data is Map) {
      final widgets = data['widgets'];
      if (widgets is List) return widgets;

      final items = data['items'];
      if (items is List) return items;

      final results = data['results'];
      if (results is List) return results;
    }

    return [];
  }

  Future<List<dynamic>> getWidgets() async {
    final response = await _getJson('/myai/widgets');
    return _readList(response);
  }

  Future<List<dynamic>> getUserWidgets(String userEmail) async {
    final response = await _getJson(
      '/myai/widgets/userWidgets',
      query: {'userEmail': userEmail},
    );
    return _readList(response);
  }

  Future<bool> addUserWidget(
    String userEmail,
    String widgetName,
    String widgetId,
  ) async {
    final response = await _postJson('/myai/widgets/userWidgets', {
      'userEmail': userEmail,
      'widgetName': widgetName,
      'widgetId': widgetId,
    });

    final data = response['data'];
    if (data is Map && data['added'] is bool) {
      return data['added'] as bool;
    }
    return response['success'] == true;
  }

  Future<bool> removeUserWidget(String userEmail, String widgetName) async {
    final response = await _deleteJson(
      '/myai/widgets/userWidgets',
      body: {'userEmail': userEmail, 'widgetName': widgetName},
    );
    return response['success'] == true;
  }

  Future<List<dynamic>> getHistory(
    String userEmail, {
    String? widgetType,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, String>{
      'userEmail': userEmail,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (widgetType != null && widgetType.isNotEmpty) {
      query['widgetType'] = widgetType;
    }
    final response = await _getJson(
      '/myai/history',
      query: query,
    );
    return _readList(response);
  }

  Future<Map<String, dynamic>> saveHistory(
    String userEmail,
    Map<String, dynamic> data,
  ) async {
    return _postJson('/myai/history', {
      ...data,
      'userEmail': userEmail,
    });
  }

  Future<bool> deleteHistory(
    String historyId, {
    String? userEmail,
  }) async {
    final response = await _deleteJson(
      '/myai/history/$historyId',
      query: userEmail == null ? null : {'userEmail': userEmail},
    );
    return response['success'] == true;
  }

  Future<Map<String, dynamic>> search(
    String query, {
    String type = 'bing',
    String? mode,
    String? widgetName,
  }) async {
    return _postJson('/myai/search', {
      'query': query,
      'type': type,
      if (mode != null && mode.trim().isNotEmpty) 'mode': mode.trim(),
      if (widgetName != null && widgetName.trim().isNotEmpty) 'widgetName': widgetName.trim(),
    });
  }

  Future<Map<String, dynamic>> transcribe({
    required PlatformFile file,
    String language = 'en',
    String prompt = '',
  }) async {
    return _postMultipart(
      '/myai/transcribe',
      fileField: 'audio',
      file: file,
      fields: {
        'language': language,
        if (prompt.trim().isNotEmpty) 'prompt': prompt.trim(),
      },
    );
  }

  Future<Map<String, dynamic>> scheduler(Map<String, dynamic> params) async {
    return _postJson('/myai/scheduler', params);
  }

  _ResolvedWidgetRequest _resolveWidgetRequest({
    WidgetConfig? config,
    WidgetModel? widget,
  }) {
    if (widget != null) {
      final resolved = resolveWidgetConfigForWidget(widget);
      return _ResolvedWidgetRequest(
        title: resolved.title,
        key: resolved.key,
        action: resolved.action,
        apiEndpoint: resolved.apiEndpoint,
        inputType: resolved.inputType,
        payload: Map<String, dynamic>.from(resolved.payload),
      );
    }

    if (config != null) {
      return _ResolvedWidgetRequest(
        title: config.title,
        key: config.key,
        action: config.action,
        apiEndpoint: config.apiEndpoint,
        inputType: config.inputType,
        payload: Map<String, dynamic>.from(config.payload),
      );
    }

    throw Exception('Widget configuration is missing.');
  }

  Future<Map<String, dynamic>> callWidget({
    WidgetConfig? config,
    WidgetModel? widget,
    required String userEmail,
    String? input,
    PlatformFile? file,
    String? userId,
  }) async {
    final cleanInput = input?.trim() ?? '';
    final request = _resolveWidgetRequest(config: config, widget: widget);
    final endpoint = _normalizeEndpoint(request.apiEndpoint);

    if (request.inputType == 'file') {
      if (file == null) {
        throw Exception('Please select a file first.');
      }

      switch (request.action) {
        case 'transcribe':
          return transcribe(
            file: file,
            prompt: cleanInput,
          );
        case 'safety':
          return _postMultipart(
            endpoint,
            fileField: _stringValue(request.payload['fileField']).isNotEmpty
                ? _stringValue(request.payload['fileField'])
                : 'media',
            file: file,
            fields: {
              'userEmail': userEmail,
              'widgetType': request.title,
              'widgetName': request.title,
              'widgetKey': request.key,
              'action': request.action,
              if (cleanInput.isNotEmpty) 'prompt': cleanInput,
              if (userId != null) 'userId': userId,
            },
          );
        default:
          throw Exception('Unsupported file action: ${request.action}');
      }
    }

    if (cleanInput.isEmpty) {
      throw Exception('Please enter input first.');
    }

    final payload = <String, dynamic>{
      ...request.payload,
      'userEmail': userEmail,
      'widgetType': request.title,
      'widgetName': request.title,
      'widgetKey': request.key,
      'action': request.action,
      'input': cleanInput,
    };

    switch (request.action) {
      case 'search':
        payload['query'] = cleanInput;
        payload['type'] = _stringValue(payload['type']).isNotEmpty
            ? _stringValue(payload['type'])
            : 'bing';
        break;
      case 'scheduler':
        payload['prompt'] = cleanInput;
        payload['title'] = request.title;
        break;
      case 'safety':
        if (endpoint.endsWith('/plagiarism/scan')) {
          payload['text'] = cleanInput;
          payload['scanId'] = 'myai-${DateTime.now().millisecondsSinceEpoch}';
          payload.remove('input');
        } else if (endpoint.endsWith('/gdpr/save')) {
          payload['url'] = cleanInput;
          payload['userId'] = userId ?? '';
        }
        break;
    }

    return _postJson(endpoint, payload);
  }

  Future<File?> toFile(PlatformFile file) async {
    if (file.path != null && file.path!.isNotEmpty) {
      return File(file.path!);
    }
    return null;
  }

  Future<List<dynamic>> getContent(
    String userEmail, {
    String status = 'completed',
    int limit = 20,
    String? board,
    String? standard,
    String? subjectName,
    String? chapterName,
    String? contentType,
  }) async {
    // 👉 READY CONTENT (BatchJob) - USING DYNAMIC BASE_URL FROM .env
    // 👉 STUDY SCREEN (old backend)
    final response = await _getJson(
      '/myai/content',
      query: {
        'userEmail': userEmail,
        'status': status,
        'limit': limit,
        if (board != null && board.trim().isNotEmpty) 'board': board.trim(),
        if (standard != null && standard.trim().isNotEmpty)
          'standard': standard.trim(),
        if (subjectName != null && subjectName.trim().isNotEmpty)
          'subjectName': subjectName.trim(),
        if (chapterName != null && chapterName.trim().isNotEmpty)
          'chapterName': chapterName.trim(),
        if (contentType != null && contentType.trim().isNotEmpty)
          'contentType': contentType.trim(),
      },
    );
    return _readList(response);
  }

  Future<Map<String, dynamic>> getContentFilters(
    String userEmail, {
    String status = 'completed',
  }) async {
    final response = await _getJson(
      '/myai/content/filters',
      query: {
        'userEmail': userEmail,
        'status': status,
      },
    );
    final data = _extractData(response);
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getContentById(
    String contentId, {
    String? userEmail,
  }) async {
    final response = await _getJson(
      '/myai/content/$contentId',
      query: userEmail == null ? null : {'userEmail': userEmail},
    );
    final data = _extractData(response);
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> unifiedChat({
    required WidgetModel widget,
    required String userId,
    String? inputText,
    PlatformFile? audioFile,
  }) async {
    final resolved = resolveWidgetConfigForWidget(widget);

    // ✅ Safe type mapping (no widget should hit backend without both fields)
    final widgetInputType = _mapWidgetInputType(resolved.inputType);
    final hasText = inputText?.trim().isNotEmpty ?? false;
    final hasAudio = audioFile != null;

    if (!hasText && !hasAudio) {
      throw Exception('Provide either text or audio file');
    }

    final inputType = hasAudio ? 'audio' : 'text';
    final outputType = widgetInputType == 'audio' ? 'text' : 'text';

    if (inputType == 'text') {
      final body = {
        // ✅ REQUIRED TOP-LEVEL FIELDS (preserve existing contract)
        'inputType': inputType,
        'outputType': outputType,
        'mode': 'best',

        // ✅ KEEP EXISTING WIDGET OBJECT (preserve existing shape)
        'widget': {
          'widgetName': resolved.title,
          'inputType': inputType,
          'outputType': outputType,
        },

        // ✅ Preserve the widget payload generically (NO flattening)
        // Backend should forward widgetPayload unchanged.
        'widgetPayload': {...resolved.payload},

        'input': inputText,
        'userId': userId,

        'options': {
          'temperature': 0.7,
        },
      };


      // ✅ Required debug logs before API call
      // ignore: avoid_print
      print("MYAI FINAL PAYLOAD => ${jsonEncode(body)}");
      return _postJson('/myai/process', body);



    } else {
      final widgetPayload = {
        'widgetName': resolved.title,
        'inputType': inputType ?? 'text',
        'outputType': outputType ?? 'text',
      };

      return _postMultipart(
        '/myai/process',
        fileField: 'audio',
        file: audioFile!,
        fields: {
          'userId': userId,
          'mode': 'best',

          // ✅ REQUIRED TOP-LEVEL FIELDS
          'inputType': inputType,
          'outputType': outputType,

          // ✅ EXISTING WIDGET OBJECT
          'widget': jsonEncode(widgetPayload),

          // ✅ Preserve payload generically without flattening
          // Kept as JSON string because multipart fields are strings.
          'widgetPayload': jsonEncode(resolved.payload),
        },
      );
    }
  }
}

final myAiService = MyAiApiService();

