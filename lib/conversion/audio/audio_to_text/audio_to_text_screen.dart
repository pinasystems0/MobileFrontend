import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pina/conversion/shared/conversion_chat_screen.dart';
import 'package:pina/conversion/audio/audio_to_text/audio_to_text_logic.dart';
import 'package:pina/conversion/audio/audio_to_text/audio_to_text_params.dart';

class AudioToTextScreen extends StatelessWidget {
  final String userId;
  final String? userEmail;
  final double temperature;

  const AudioToTextScreen({
    super.key,
    this.userId = "0",
    this.userEmail,
    this.temperature = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final logic = AudioToTextLogic();
    final baseParams = AudioToTextParams(temperature: temperature);

    return ConversionChatScreen(
      title: "Audio to Text",
      fromType: baseParams.from,
      toType: baseParams.to,
      userId: userId,
      userEmail: userEmail,
      initialTemperature: baseParams.temperature,
      getParametersConfig: () => AudioToTextParams.parametersConfig,
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
