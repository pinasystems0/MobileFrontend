class ImageToAudioParams {
  final String from;
  final String to;
  final double temperature;
  final String? provider;

  const ImageToAudioParams({
    this.from = "Image",
    this.to = "Audio",
    this.temperature = 0.7,
    this.provider,
  });

  /// Parameter configuration for Image to Audio conversion
  static List<Map<String, dynamic>> get parametersConfig => [
    {'name': 'Voice', 'key': 'voice', 'type': 'dropdown', 
     'options': ['Male', 'Female'], 'default': 'Female'},
    {'name': 'Language', 'key': 'language', 'type': 'dropdown', 
     'options': ['English', 'Hindi'], 'default': 'English'},
    {'name': 'Speed', 'key': 'speed', 'type': 'slider', 
     'min': 0.8, 'max': 1.2, 'default': 1.0},
    {'name': 'Emotion', 'key': 'emotion', 'type': 'dropdown', 
     'options': ['Neutral', 'Happy', 'Dramatic'], 'default': 'Neutral'},
    {'name': 'Audio Format', 'key': 'audioFormat', 'type': 'dropdown', 
     'options': ['MP3', 'WAV'], 'default': 'MP3'},
    {'name': 'Description Style', 'key': 'descriptionStyle', 'type': 'dropdown', 
     'options': ['Story', 'Caption', 'Technical'], 'default': 'Story'},
  ];

  ImageToAudioParams copyWith({
    String? from,
    String? to,
    double? temperature,
    String? provider,
  }) {
    return ImageToAudioParams(
      from: from ?? this.from,
      to: to ?? this.to,
      temperature: temperature ?? this.temperature,
      provider: provider ?? this.provider,
    );
  }
}
