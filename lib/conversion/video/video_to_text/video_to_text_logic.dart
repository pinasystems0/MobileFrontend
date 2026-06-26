import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/video/video_to_text/video_to_text_params.dart';

class VideoToTextLogic {
  final AiRequestService _aiRequestService;

  VideoToTextLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers
  String _buildEnhancedPrompt(String prompt, Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return prompt;
    
    final modifiers = <String>[];
    
    // Language
    if (parameters['language'] != null) {
      final lang = parameters['language'].toString();
      modifiers.add('in $lang language');
    }
    
    // Summary Length
    if (parameters['summaryLength'] != null) {
      final length = parameters['summaryLength'].toString().toLowerCase();
      modifiers.add('keep the summary $length');
    }
    
    // Transcript Style
    if (parameters['transcriptStyle'] != null) {
      final style = parameters['transcriptStyle'].toString();
      modifiers.add('use $style style for transcript');
    }
    
    // Speaker Detection
    if (parameters['speakerDetection'] != null) {
      final speaker = parameters['speakerDetection'].toString().toLowerCase();
      if (speaker == 'on') {
        modifiers.add('detect and label speakers');
      }
    }
    
    if (modifiers.isEmpty) return prompt;
    return '$prompt. ${modifiers.join('. ')}.';
  }

  /// Apply post-processing to response based on parameters
  String _applyPostProcessing(String response, Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return response;
    
    String processed = response;
    
    // Case transformation
    if (parameters['case'] != null) {
      final caseType = parameters['case'].toString().toLowerCase();
      if (caseType == 'uppercase') {
        processed = processed.toUpperCase();
      } else if (caseType == 'lowercase') {
        processed = processed.toLowerCase();
      }
    }
    
    return processed;
  }

  Future<Map<String, dynamic>> submit({
    required String prompt,
    required String userId,
    required VideoToTextParams params,
    Map<String, dynamic> parameters = const {},
    File? file,
  }) async {
    // Build enhanced prompt with parameters
    final enhancedPrompt = _buildEnhancedPrompt(prompt, parameters);
    
    // Get max tokens if provided
    int? maxTokens;
    if (parameters['maxTokens'] != null) {
      maxTokens = parameters['maxTokens'] as int;
    }
    
    final response = await _aiRequestService.generateAIResponse(
      prompt: enhancedPrompt,
      from: params.from,
      to: params.to,
      temperature: params.temperature,
      userId: userId,
      provider: params.provider,
      maxTokens: maxTokens,
      parameters: parameters,
      file: file,
    );
    
    // Apply post-processing to response if successful
    if (response['success'] == true && response['content'] is String) {
      final originalContent = response['content'] as String;
      final processedContent = _applyPostProcessing(originalContent, parameters);
      response['content'] = processedContent;
    }
    
    return response;
  }
}
