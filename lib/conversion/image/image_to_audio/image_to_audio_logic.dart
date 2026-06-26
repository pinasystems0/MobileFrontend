import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/image/image_to_audio/image_to_audio_params.dart';

class ImageToAudioLogic {
  final AiRequestService _aiRequestService;

  ImageToAudioLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers for image to audio conversion
  String _buildEnhancedPrompt(String prompt, Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return prompt;
    
    final modifiers = <String>[];
    
    // Voice
    if (parameters['voice'] != null) {
      final voice = parameters['voice'].toString();
      modifiers.add('Use a $voice voice');
    }
    
    // Language
    if (parameters['language'] != null) {
      final lang = parameters['language'].toString();
      modifiers.add('Speak in $lang');
    }
    
    // Emotion
    if (parameters['emotion'] != null) {
      final emotion = parameters['emotion'].toString();
      if (emotion != 'Neutral') {
        modifiers.add('with a $emotion tone');
      }
    }
    
    // Description Style
    if (parameters['descriptionStyle'] != null) {
      final style = parameters['descriptionStyle'].toString();
      if (style == 'Story') {
        modifiers.add('Tell as a story');
      } else if (style == 'Technical') {
        modifiers.add('Provide technical description');
      } else if (style == 'Caption') {
        modifiers.add('Keep it as a caption');
      }
    }
    
    // Speed
    if (parameters['speed'] != null) {
      final speed = parameters['speed'] as double;
      if (speed < 1.0) {
        modifiers.add('Speak slowly');
      } else if (speed > 1.0) {
        modifiers.add('Speak quickly');
      }
    }
    
    if (modifiers.isEmpty) return prompt;
    return '$prompt. ${modifiers.join('. ')}.';
  }

  Future<Map<String, dynamic>> submit({
    required String prompt,
    required String userId,
    required ImageToAudioParams params,
    Map<String, dynamic> parameters = const {},
    File? file,
  }) {
    // Build enhanced prompt with parameters
    final enhancedPrompt = _buildEnhancedPrompt(prompt, parameters);
    
    return _aiRequestService.generateAIResponse(
      prompt: enhancedPrompt,
      from: params.from,
      to: params.to,
      temperature: params.temperature,
      userId: userId,
      provider: params.provider,
      parameters: parameters,
      file: file,
    );
  }
}

