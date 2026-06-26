class ImageToTextParams {
  final String from;
  final String to;
  final double temperature;
  final String? provider;

  const ImageToTextParams({
    this.from = "Image",
    this.to = "Text",
    this.temperature = 0.7,
    this.provider,
  });

  /// Parameter configuration for Image to Text conversion
  static List<Map<String, dynamic>> get parametersConfig => [
    {'name': 'Description Detail', 'key': 'descriptionDetail', 'type': 'dropdown', 
     'options': ['Short', 'Medium', 'Detailed'], 'default': 'Medium'},
    {'name': 'Language', 'key': 'language', 'type': 'dropdown', 
     'options': ['English', 'Hindi'], 'default': 'English'},
    {'name': 'Caption Style', 'key': 'captionStyle', 'type': 'dropdown', 
     'options': ['Simple', 'Technical', 'SEO'], 'default': 'Simple'},
    {'name': 'Focus Area', 'key': 'focusArea', 'type': 'dropdown', 
     'options': ['Objects', 'Scene', 'People'], 'default': 'Scene'},
    {'name': 'OCR Mode', 'key': 'ocrMode', 'type': 'toggle', 
     'options': ['Off', 'On'], 'default': 'Off'},
    {'name': 'Case', 'key': 'case', 'type': 'dropdown', 
     'options': ['Normal', 'Uppercase', 'Lowercase'], 'default': 'Normal'},
    {'name': 'Max Tokens', 'key': 'maxTokens', 'type': 'number', 
     'min': 100, 'max': 4000, 'default': 1000},
  ];

  ImageToTextParams copyWith({
    String? from,
    String? to,
    double? temperature,
    String? provider,
  }) {
    return ImageToTextParams(
      from: from ?? this.from,
      to: to ?? this.to,
      temperature: temperature ?? this.temperature,
      provider: provider ?? this.provider,
    );
  }
}
