import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pina/conversion/shared/conversion_chat_screen.dart';
import 'package:pina/conversion/text/text_to_audio/text_to_audio_logic.dart';
import 'package:pina/conversion/text/text_to_audio/text_to_audio_params.dart';

class TextToAudioScreen extends StatelessWidget {
  final String userId;
  final String? userEmail;
  final double temperature;

  const TextToAudioScreen({
    super.key,
    this.userId = "0",
    this.userEmail,
    this.temperature = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final logic = TextToAudioLogic();
    final baseParams = TextToAudioParams(temperature: temperature);

    return ConversionChatScreen(
      title: "Text to Audio",
      fromType: baseParams.from,
      toType: baseParams.to,
      userId: userId,
      userEmail: userEmail,
      initialTemperature: baseParams.temperature,
      getParametersConfig: () => TextToAudioParams.parametersConfig,
      onSubmit: ({
        required String prompt,
        required String? provider,
        required double temperature,
        required String userId,
        File? file,
        Map<String, dynamic>? parameters,
      }) {
        final params = baseParams.copyWith(
          provider: provider,
          temperature: temperature,
        );

        return logic.submit(
          prompt: prompt,
          userId: userId,
          params: params,
          parameters: parameters ?? {},
          file: file,
        );
      },
    );
  }
}
