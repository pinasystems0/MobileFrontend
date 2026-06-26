class AudioToAudioParams {
  final String from;
  final String to;
  final double temperature;
  final String? provider;

  const AudioToAudioParams({
    this.from = "Audio",
    this.to = "Audio",
    this.temperature = 0.7,
    this.provider,
  });

  /// Parameter configuration for Audio to Audio conversion
  static List<Map<String, dynamic>> get parametersConfig => [
    {"name": "Speed", "key": "speed", "type": "slider", "min": 0.5, "max": 2.0, "default": 1.0},
    {"name": "Pitch", "key": "pitch", "type": "slider", "min": 0.5, "max": 2.0, "default": 1.0},
    {"name": "Volume", "key": "volume", "type": "slider", "min": 0.5, "max": 2.0, "default": 1.0},
    {"name": "Noise Reduction", "key": "noiseReduction", "type": "toggle", "default": false},
{"name": "Fade In (sec)", "key": "fadeIn", "type": "slider", "min": 0.0, "max": 5.0, "default": 0.0},
{"name": "Fade Out (sec)", "key": "fadeOut", "type": "slider", "min": 0.0, "max": 5.0, "default": 0.0},
{"name": "Trim Start (sec)", "key": "trimStart", "type": "slider", "min": 0.0, "max": 60.0, "default": 0.0},
{"name": "Trim End (sec)", "key": "trimEnd", "type": "slider", "min": 0.0, "max": 60.0, "default": 0.0},
    {"name": "Format", "key": "format", "type": "dropdown", "options": ["mp3","wav"], "default": "mp3"}
  ];

  AudioToAudioParams copyWith({
    String? from,
    String? to,
    double? temperature,
    String? provider,
  }) {
    return AudioToAudioParams(
      from: from ?? this.from,
      to: to ?? this.to,
      temperature: temperature ?? this.temperature,
      provider: provider ?? this.provider,
    );
  }
}

