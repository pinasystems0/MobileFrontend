class TextToAudioParams {
  final String from;
  final String to;
  final double temperature;
  final String? provider;

  const TextToAudioParams({
    this.from = "Text",
    this.to = "Audio",
    this.temperature = 0.7,
    this.provider,
  });

  /// Parameter configuration for Text to Audio conversion
  static List<Map<String, dynamic>> get parametersConfig => [
    {'name': 'Voice', 'key': 'voice', 'type': 'dropdown', 
     'options': ['Male', 'Female'], 'default': 'Female'},
    {'name': 'Language', 'key': 'language', 'type': 'dropdown', 
     'options': ['English', 'Hindi'], 'default': 'English'},
    {'name': 'Speed', 'key': 'speed', 'type': 'slider', 
     'min': 0.8, 'max': 1.2, 'default': 1.0},
    {'name': 'Pitch', 'key': 'pitch', 'type': 'dropdown', 
     'options': ['Low', 'Normal', 'High'], 'default': 'Normal'},
    {'name': 'Emotion', 'key': 'emotion', 'type': 'dropdown', 
     'options': ['Neutral', 'Happy', 'Sad'], 'default': 'Neutral'},
    {'name': 'Audio Format', 'key': 'audioFormat', 'type': 'dropdown', 
     'options': ['MP3', 'WAV'], 'default': 'MP3'},
  ];

  TextToAudioParams copyWith({
    String? from,
    String? to,
    double? temperature,
    String? provider,
  }) {
    return TextToAudioParams(
      from: from ?? this.from,
      to: to ?? this.to,
      temperature: temperature ?? this.temperature,
      provider: provider ?? this.provider,
    );
  }
}
