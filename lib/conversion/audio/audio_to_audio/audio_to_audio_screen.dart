import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pina/conversion/shared/conversion_chat_screen.dart';
import 'package:pina/conversion/audio/audio_to_audio/audio_to_audio_logic.dart';
import 'package:pina/conversion/audio/audio_to_audio/audio_to_audio_params.dart';

class AudioToAudioScreen extends StatelessWidget {
  final String userId;
  final String? userEmail;
  final double temperature;

  const AudioToAudioScreen({
    super.key,
    this.userId = "0",
    this.userEmail,
    this.temperature = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final logic = AudioToAudioLogic();
    final baseParams = AudioToAudioParams(temperature: temperature);

    return ConversionChatScreen(
      title: "Audio to Audio",
      fromType: baseParams.from,
      toType: baseParams.to,
      userId: userId,
      userEmail: userEmail,
      initialTemperature: baseParams.temperature,
      getParametersConfig: () => AudioToAudioParams.parametersConfig,
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
