class VideoToTextParams {
  final String from;
  final String to;
  final double temperature;
  final String? provider;

  const VideoToTextParams({
    this.from = "Video",
    this.to = "Text",
    this.temperature = 0.7,
    this.provider,
  });

  /// Parameter configuration for Video to Text conversion
  static List<Map<String, dynamic>> get parametersConfig => [
    {'name': 'Language', 'key': 'language', 'type': 'dropdown', 
     'options': ['English', 'Hindi'], 'default': 'English'},
    {'name': 'Summary Length', 'key': 'summaryLength', 'type': 'dropdown', 
     'options': ['Short', 'Medium', 'Detailed'], 'default': 'Medium'},
    {'name': 'Transcript Style', 'key': 'transcriptStyle', 'type': 'dropdown', 
     'options': ['Simple', 'Detailed', 'Timestamped'], 'default': 'Detailed'},
    {'name': 'Speaker Detection', 'key': 'speakerDetection', 'type': 'dropdown', 
     'options': ['On', 'Off'], 'default': 'Off'},
    {'name': 'Case', 'key': 'case', 'type': 'dropdown', 
     'options': ['Normal', 'Uppercase', 'Lowercase'], 'default': 'Normal'},
    {'name': 'Max Tokens', 'key': 'maxTokens', 'type': 'number', 
     'min': 100, 'max': 4000, 'default': 1000},
  ];

  VideoToTextParams copyWith({
    String? from,
    String? to,
    double? temperature,
    String? provider,
  }) {
    return VideoToTextParams(
      from: from ?? this.from,
      to: to ?? this.to,
      temperature: temperature ?? this.temperature,
      provider: provider ?? this.provider,
    );
  }
}
