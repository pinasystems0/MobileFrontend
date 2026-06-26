class VideoToAudioParams {
  final String from;
  final String to;
  final double temperature;
  final String? provider;

  const VideoToAudioParams({
    this.from = "Video",
    this.to = "Audio",
    this.temperature = 0.7,
    this.provider,
  });

  /// Parameter configuration for Video to Audio conversion
  static List<Map<String, dynamic>> get parametersConfig => [
    {'name': 'Audio Format', 'key': 'audioFormat', 'type': 'dropdown', 
     'options': ['MP3', 'WAV'], 'default': 'MP3'},
    {'name': 'Language', 'key': 'language', 'type': 'dropdown', 
     'options': ['English', 'Hindi'], 'default': 'English'},
    {'name': 'Noise Reduction', 'key': 'noiseReduction', 'type': 'dropdown', 
     'options': ['On', 'Off'], 'default': 'Off'},
    {'name': 'Voice Style', 'key': 'voiceStyle', 'type': 'dropdown', 
     'options': ['Male', 'Female'], 'default': 'Female'},
    {'name': 'Speed', 'key': 'speed', 'type': 'slider', 
     'min': 0.8, 'max': 1.2, 'default': 1.0},
    {'name': 'Volume Normalize', 'key': 'volumeNormalize', 'type': 'dropdown', 
     'options': ['On', 'Off'], 'default': 'Off'},
  ];

  VideoToAudioParams copyWith({
    String? from,
    String? to,
    double? temperature,
    String? provider,
  }) {
    return VideoToAudioParams(
      from: from ?? this.from,
      to: to ?? this.to,
      temperature: temperature ?? this.temperature,
      provider: provider ?? this.provider,
    );
  }
}
