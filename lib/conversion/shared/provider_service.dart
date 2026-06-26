import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';


/// Model class for provider information
class ProviderInfo {
  final String companyName;
  final String llmName;
  final String modelIdentifier;
  final String? preference;

  ProviderInfo({
    required this.companyName,
    required this.llmName,
    required this.modelIdentifier,
    this.preference,
  });

  /// Returns display label for UI: "CompanyName - ModelName"
  String get displayLabel => "$companyName - $llmName";

  /// Returns the provider key for API calls
  String get providerKey => modelIdentifier;

  factory ProviderInfo.fromJson(Map<String, dynamic> json) {
    return ProviderInfo(
      companyName: json['companyName'] ?? '',
      llmName: json['llmName'] ?? '',
      modelIdentifier: json['modelIdentifier'] ?? '',
      preference: json['preference']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'llmName': llmName,
      'modelIdentifier': modelIdentifier,
      'preference': preference,
    };
  }
}

/// Service to fetch available providers for each conversion type
class ProviderService {
  String get _providersUrl => "${ApiConstants.authUrl}/api/ai/providers";

  /// Cache for providers to avoid repeated API calls
  final Map<String, List<ProviderInfo>> _providerCache = {};

  /// Fetch available providers for a specific conversion type
  /// [fromType] - source type (text, image, audio, video)
  /// [toType] - target type (text, image, audio, video)
  Future<List<ProviderInfo>> getProviders({
    required String fromType,
    required String toType,
  }) async {
    // Create cache key
    final cacheKey = "${fromType}_$toType";

    // Temporary debug: bypass cache to rule out stale empty results.
    // Enable by setting: PROVIDERS_BYPASS_CACHE=true at runtime (e.g., in your app env/config).
    const bool bypassCache = bool.fromEnvironment('PROVIDERS_BYPASS_CACHE', defaultValue: false);

    // Return cached providers if available (unless bypassing cache)
    if (!bypassCache && _providerCache.containsKey(cacheKey)) {
      debugPrint('ProviderService.getProviders: cache hit key=$cacheKey size=${_providerCache[cacheKey]!.length}');
      return _providerCache[cacheKey]!;
    }


    final uri = Uri.parse(_providersUrl).replace(
      queryParameters: {
        'from': fromType.toLowerCase(),
        'to': toType.toLowerCase(),
      },
    );

    try {
      final headers = await SessionService.authHeaders(
        includeJsonContentType: true,
      );

      final safeHeaders = <String, String>{
        ...headers,
        if (headers.containsKey('Authorization')) 'Authorization': 'Bearer <redacted>',
      };

      debugPrint(
        'ProviderService.getProviders: requestStart '
        'authUrl=${ApiConstants.authUrl} cacheKey=$cacheKey uri=$uri headers=$safeHeaders '
        'authHeaderPresent=${headers.containsKey('Authorization')}',
      );

      final response = await http
          .get(
            uri,
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      debugPrint(
        'ProviderService.getProviders: response '
        'status=${response.statusCode} body=${response.body}',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'PROVIDER_FETCH_FAILED_REASON: backend_non_2xx '
          'status=${response.statusCode} uri=$uri body=${response.body}',
        );
        return _getDefaultProviders(fromType: fromType, toType: toType);
      }

      final dynamic decoded = jsonDecode(response.body);
      debugPrint(
        'ProviderService.getProviders: decodedJson type=${decoded.runtimeType} '
        'value=$decoded',
      );

      if (decoded is Map<String, dynamic>) {
        final bool success = decoded['success'] == true;
        if (!success) {
          debugPrint(
            'PROVIDER_FETCH_FAILED_REASON: decoded_success_false '
            'decodedKeys=${decoded.keys.toList()} error=${decoded['error']} '
            'message=${decoded['message']} decoded=$decoded',
          );
          return _getDefaultProviders(fromType: fromType, toType: toType);
        }

        final List<dynamic> providersList = decoded['providers'] ?? [];
        debugPrint('ProviderService.getProviders: backend provider count=${providersList.length}');

        final providers = providersList
            .map((json) {
              if (json is Map<String, dynamic>) {
                debugPrint('ProviderService.getProviders: parsingProviderJson=$json');
                return ProviderInfo.fromJson(json);
              }
              // If backend returns unexpected shape, log and skip
              debugPrint('ProviderService.getProviders: unexpected provider item type=${json.runtimeType}');
              return ProviderInfo(
                companyName: '',
                llmName: '',
                modelIdentifier: '',
              );
            })
            .where((p) => p.modelIdentifier.isNotEmpty)
            .toList();

        debugPrint(
          'ProviderService.getProviders: parsedProviders=${providers.map((p) => p.toJson()).toList()}',
        );

        // Sort by preference (lower number = higher priority)
        providers.sort((a, b) {
          final prefA = int.tryParse(a.preference ?? '999') ?? 999;
          final prefB = int.tryParse(b.preference ?? '999') ?? 999;
          return prefA.compareTo(prefB);
        });

        debugPrint(
          'ProviderService.getProviders: sortedProviders=${providers.map((p) => p.toJson()).toList()}',
        );

        // Cache the result only on successful backend parsing.
        // IMPORTANT: failed requests / unexpected parsing never get cached.
        _providerCache[cacheKey] = providers;
        debugPrint('ProviderService.getProviders: cached providers key=$cacheKey size=${providers.length}');
        debugPrint('ProviderService.getProviders: successReturn key=$cacheKey returning=${providers.length}');

        return providers;
      }

      debugPrint(
        'PROVIDER_FETCH_FAILED_REASON: decoded_not_map '
        'decodedType=${decoded.runtimeType} decoded=$decoded',
      );
      return _getDefaultProviders(fromType: fromType, toType: toType);
    } catch (e, st) {
      debugPrint(
        'PROVIDER_FETCH_FAILED_REASON: exception '
        'uri=$uri exception=$e stack=$st',
      );
      return _getDefaultProviders(fromType: fromType, toType: toType);
    }
  }

  /// Clear cache (useful when user wants to refresh providers)
  void clearCache() {
    _providerCache.clear();
  }

  /// Get default providers based on conversion type
  /// This is a fallback when backend is not available
  List<ProviderInfo> _getDefaultProviders({
    required String fromType,
    required String toType,
  }) {
    // Map conversion types to default providers
    final key = "${fromType.toLowerCase()}_${toType.toLowerCase()}";

    final defaultProvidersMap = {
      // Text → Text
      'text_text': [
        ProviderInfo(
          companyName: 'Google',
          llmName: 'Gemini 2.0 Flash',
          modelIdentifier: 'gemini-2.0-flash-exp',
          preference: '10',
        ),
        ProviderInfo(
          companyName: 'DeepSeek',
          llmName: 'DeepSeek Chat',
          modelIdentifier: 'deepseek-chat',
          preference: '7',
        ),
        ProviderInfo(
          companyName: 'Google',
          llmName: 'Gemma 3',
          modelIdentifier: 'gemma-3-1b',
          preference: '5',
        ),
      ],
      // Text → Image
      'text_image': [
        ProviderInfo(
          companyName: 'Stability AI',
          llmName: 'Stable Diffusion Ultra',
          modelIdentifier: 'stability-ultra',
          preference: '9',
        ),
      ],
      // Text → Audio
      'text_audio': [
        ProviderInfo(
          companyName: 'Google',
          llmName: 'Gemini TTS',
          modelIdentifier: 'gemini-tts',
          preference: '9',
        ),
      ],
      // Text → Video
      'text_video': [
        ProviderInfo(
          companyName: 'Google',
          llmName: 'Gemini Veo',
          modelIdentifier: 'gemini-veo',
          preference: '9',
        ),
      ],
      // Image → Text
      'image_text': [
        ProviderInfo(
          companyName: 'DeepSeek',
          llmName: 'DeepSeek Vision',
          modelIdentifier: 'deepseek-vision',
          preference: '8',
        ),
      ],
      // Image → Image
      'image_image': [
        ProviderInfo(
          companyName: 'Stability AI',
          llmName: 'Stable Diffusion Image Edit',
          modelIdentifier: 'stability-image-edit',
          preference: '9',
        ),
      ],
      // Image → Video
      'image_video': [
        ProviderInfo(
          companyName: 'Google',
          llmName: 'Gemini Image Video',
          modelIdentifier: 'gemini-image-video',
          preference: '8',
        ),
      ],
      // Audio → Text
      'audio_text': [
        ProviderInfo(
          companyName: 'AssemblyAI',
          llmName: 'Universal-1',
          modelIdentifier: 'assemblyai-universal-1',
          preference: '8',
        ),
      ],
      // Audio → Image
      'audio_image': [
        ProviderInfo(
          companyName: 'Stability AI',
          llmName: 'Audio Prompt Image Generator',
          modelIdentifier: 'audio-image-pipeline',
          preference: '8',
        ),
      ],
      // Video → Text
      'video_text': [
        ProviderInfo(
          companyName: 'Google',
          llmName: 'Gemini Vision',
          modelIdentifier: 'gemini-video-text',
          preference: '9',
        ),
      ],
      // Video → Audio
      'video_audio': [
        ProviderInfo(
          companyName: 'AssemblyAI',
          llmName: 'Video Audio Extractor',
          modelIdentifier: 'video-audio-extractor',
          preference: '10',
        ),
      ],
      // Video → Video
      'video_video': [
        ProviderInfo(
          companyName: 'FFmpeg',
          llmName: 'Video Processor',
          modelIdentifier: 'ffmpeg-video-processing',
          preference: '10',
        ),
      ],
    };

    return defaultProvidersMap[key] ?? [];
  }

  /// Static method to get providers synchronously (for initial load)
  /// Returns default providers based on conversion type
  static List<ProviderInfo> getDefaultProviders({
    required String fromType,
    required String toType,
  }) {
    final service = ProviderService();
    return service._getDefaultProviders(fromType: fromType, toType: toType);
  }
}

