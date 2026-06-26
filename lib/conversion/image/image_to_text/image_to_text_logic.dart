import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/image/image_to_text/image_to_text_params.dart';

class ImageToTextLogic {
  final AiRequestService _aiRequestService;

  ImageToTextLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers for image to text conversion
  String _buildEnhancedPrompt(String prompt, Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return prompt;
    
    final modifiers = <String>[];
    
    // Description Detail
    if (parameters['descriptionDetail'] != null) {
      final detail = parameters['descriptionDetail'].toString().toLowerCase();
      if (detail == 'short') {
        modifiers.add('Provide a brief description');
      } else if (detail == 'detailed') {
        modifiers.add('Provide a detailed and comprehensive description');
      }
    }
    
    // Language
    if (parameters['language'] != null) {
      final lang = parameters['language'].toString();
      modifiers.add('Use $lang language');
    }
    
    // Caption Style
    if (parameters['captionStyle'] != null) {
      final style = parameters['captionStyle'].toString();
      if (style == 'Technical') {
        modifiers.add('Use technical terminology');
      } else if (style == 'SEO') {
        modifiers.add('Optimize for SEO with relevant keywords');
      }
    }
    
    // Focus Area
    if (parameters['focusArea'] != null) {
      final focus = parameters['focusArea'].toString();
      modifiers.add('Focus on $focus');
    }
    
    // OCR Mode
    if (parameters['ocrMode'] != null) {
      final ocr = parameters['ocrMode'].toString();
      if (ocr == 'On') {
        modifiers.add('Extract any visible text from the image');
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
    required ImageToTextParams params,
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
