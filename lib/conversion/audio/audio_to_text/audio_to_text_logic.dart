import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/audio/audio_to_text/audio_to_text_params.dart';

class AudioToTextLogic {
  final AiRequestService _aiRequestService;

  AudioToTextLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers for audio to text conversion
  String _buildEnhancedPrompt(String prompt, Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return prompt;
    
    final modifiers = <String>[];
    
    // Language
    if (parameters['language'] != null) {
      final lang = parameters['language'].toString();
      modifiers.add('in $lang language');
    }
    
    // Speaker Detection
    if (parameters['speakerDetection'] != null) {
      final detection = parameters['speakerDetection'].toString();
      if (detection == 'On') {
        modifiers.add('detect and identify different speakers');
      }
    }
    
    // Noise Reduction
    if (parameters['noiseReduction'] != null) {
      final noise = parameters['noiseReduction'].toString();
      if (noise == 'On') {
        modifiers.add('apply noise reduction');
      }
    }
    
    // Transcript Style
    if (parameters['transcriptStyle'] != null) {
      final style = parameters['transcriptStyle'].toString();
      if (style == 'Detailed') {
        modifiers.add('provide a detailed transcript');
      } else if (style == 'Timestamped') {
        modifiers.add('include timestamps');
      }
    }
    
    if (modifiers.isEmpty) return prompt;
    return '$prompt. ${modifiers.join('. ')}.';
  }

  /// Apply case transformation to response if needed
  String _applyCaseTransformation(String response, Map<String, dynamic> parameters) {
    final caseValue = parameters['case']?.toString();
    if (caseValue == null || caseValue == 'Normal') return response;
    
    if (caseValue == 'Uppercase') {
      return response.toUpperCase();
    } else if (caseValue == 'Lowercase') {
      return response.toLowerCase();
    }
    return response;
  }

  Future<Map<String, dynamic>> submit({
    required String prompt,
    required String userId,
    required AudioToTextParams params,
    Map<String, dynamic> parameters = const {},
    File? file,
  }) async {
    // Build enhanced prompt with parameters
    final enhancedPrompt = _buildEnhancedPrompt(prompt, parameters);
    
    // Get maxTokens if specified
    final maxTokens = parameters['maxTokens'] as int?;
    
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
    
    // Apply case transformation if needed
    if (response.containsKey('content')) {
      final content = response['content'] as String?;
      if (content != null) {
        response['content'] = _applyCaseTransformation(content, parameters);
      }
    } else if (response.containsKey('text')) {
      final text = response['text'] as String?;
      if (text != null) {
        response['text'] = _applyCaseTransformation(text, parameters);
      }
    }
    
    return response;
  }
}
