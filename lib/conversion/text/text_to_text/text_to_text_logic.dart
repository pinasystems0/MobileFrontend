import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/text/text_to_text/text_to_text_params.dart';

class TextToTextLogic {
  final AiRequestService _aiRequestService;

  TextToTextLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers
  String _buildEnhancedPrompt(String prompt, Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return prompt;
    
    final modifiers = <String>[];
    
    // Tone
    if (parameters['tone'] != null) {
      final tone = parameters['tone'].toString().toLowerCase();
      modifiers.add('in $tone tone');
    }
    
    // Writing Style
    if (parameters['writingStyle'] != null) {
      final style = parameters['writingStyle'].toString();
      modifiers.add('using $style style');
    }
    
    // Length
    if (parameters['length'] != null) {
      final length = parameters['length'].toString().toLowerCase();
      modifiers.add('keep the response $length');
    }
    
    // Language
    if (parameters['language'] != null) {
      final lang = parameters['language'].toString();
      modifiers.add('in $lang language');
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
    
    // Length post-processing (if model didn't handle it)
    if (parameters['length'] != null) {
      final length = parameters['length'].toString().toLowerCase();
      if (length == 'short') {
        // Truncate to roughly 2 sentences
        final sentences = processed.split(RegExp(r'[.!?]+'));
        if (sentences.length > 2) {
          processed = '${sentences[0].trim()}. ${sentences[1].trim()}.';
        }
      } else if (length == 'long') {
        // Could expand but we'll leave as is for now
      }
    }
    
    return processed;
  }

  Future<Map<String, dynamic>> submit({
    required String prompt,
    required String userId,
    required TextToTextParams params,
    Map<String, dynamic> parameters = const {},
    File? file,
  }) async {
    // Build enhanced prompt with parameters
    final enhancedPrompt = _buildEnhancedPrompt(prompt, parameters);
    
    // Override temperature if provided in parameters
    double finalTemperature = params.temperature;
    if (parameters['temperature'] != null) {
      finalTemperature = (parameters['temperature'] as num).toDouble();
    }
    
    // Get max tokens if provided
    int? maxTokens;
    if (parameters['maxTokens'] != null) {
      maxTokens = parameters['maxTokens'] as int;
    }
    
    final response = await _aiRequestService.generateAIResponse(
      prompt: enhancedPrompt,
      from: params.from,
      to: params.to,
      temperature: finalTemperature,
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
