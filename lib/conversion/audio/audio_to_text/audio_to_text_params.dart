class AudioToTextParams {
  final String from;
  final String to;
  final double temperature;
  final String? provider;

  const AudioToTextParams({
    this.from = "Audio",
    this.to = "Text",
    this.temperature = 0.7,
    this.provider,
  });

  /// Parameter configuration for Audio to Text conversion
  static List<Map<String, dynamic>> get parametersConfig => [
    {'name': 'Language', 'key': 'language', 'type': 'dropdown', 
     'options': ['English', 'Hindi'], 'default': 'English'},
    {'name': 'Speaker Detection', 'key': 'speakerDetection', 'type': 'toggle', 
     'options': ['Off', 'On'], 'default': 'Off'},
    {'name': 'Noise Reduction', 'key': 'noiseReduction', 'type': 'toggle', 
     'options': ['Off', 'On'], 'default': 'Off'},
    {'name': 'Transcript Style', 'key': 'transcriptStyle', 'type': 'dropdown', 
     'options': ['Simple', 'Detailed', 'Timestamped'], 'default': 'Simple'},
    {'name': 'Case', 'key': 'case', 'type': 'dropdown', 
     'options': ['Normal', 'Uppercase', 'Lowercase'], 'default': 'Normal'},
    {'name': 'Max Tokens', 'key': 'maxTokens', 'type': 'number', 
     'min': 100, 'max': 4000, 'default': 1000},
  ];

  AudioToTextParams copyWith({
    String? from,
    String? to,
    double? temperature,
    String? provider,
  }) {
    return AudioToTextParams(
      from: from ?? this.from,
      to: to ?? this.to,
      temperature: temperature ?? this.temperature,
      provider: provider ?? this.provider,
    );
  }
}
