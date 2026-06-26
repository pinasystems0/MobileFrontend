class WidgetModel {
  final String id;
  final String widgetId;
  final String widgetKey;
  final String widgetName;
  final String visitName;
  final String visitCategory;
  final String widgetVendor;
  final String widgetPaidOrFree;
  final double visitCostPerUnit;
  final String visitStatus;
  final String type;
  final String screenType;
  final String action;
  final String apiEndpoint;
  final String inputType;
  final String outputRenderer;
  final String outputTemplate;
  final String inputLabel;
  final String heading;
  final String description;
  final String outputTitle;
  final Map<String, dynamic> payload;
  final Map<String, dynamic> studyConfig;
  final Map<String, dynamic> uiConfig;
  final DateTime? addedAt;
  final bool missingCatalogEntry;

  const WidgetModel({
    required this.id,
    required this.widgetId,
    required this.widgetKey,
    required this.widgetName,
    required this.visitName,
    required this.visitCategory,
    required this.widgetVendor,
    required this.widgetPaidOrFree,
    required this.visitCostPerUnit,
    required this.visitStatus,
    required this.type,
    required this.screenType,
    required this.action,
    required this.apiEndpoint,
    required this.inputType,
    required this.outputRenderer,
    required this.outputTemplate,
    required this.inputLabel,
    required this.heading,
    required this.description,
    required this.outputTitle,
    this.payload = const {},
    this.studyConfig = const {},
    this.uiConfig = const {},
    this.addedAt,
    this.missingCatalogEntry = false,
  });

  bool get isStudy => type.trim().toLowerCase() == 'study';

  static String _normalizeWidgetKey(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const {};
  }

  factory WidgetModel.fromJson(Map<String, dynamic> json) {
    final rawCost = json['visitCostPerUnit'];
    final parsedCost = rawCost is num
        ? rawCost.toDouble()
        : double.tryParse(rawCost?.toString() ?? '') ?? 0;
    final widgetName = (json['widgetName'] ?? json['visitName'] ?? '').toString();

    return WidgetModel(
      id: (json['_id'] ?? json['id'] ?? json['widgetId'] ?? '').toString(),
      widgetId: (json['widgetId'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      widgetKey: (json['widgetKey'] ?? '').toString().trim().isNotEmpty
          ? json['widgetKey'].toString()
          : _normalizeWidgetKey(widgetName),
      widgetName: widgetName,
      visitName: (json['visitName'] ?? json['widgetName'] ?? '').toString(),
      visitCategory: (json['visitCategory'] ?? '').toString(),
      widgetVendor: (json['widgetVendor'] ?? '').toString(),
      widgetPaidOrFree: (json['widgetPaidOrFree'] ?? 'free').toString(),
      visitCostPerUnit: parsedCost,
      visitStatus: (json['visitStatus'] ?? 'active').toString(),
      type: (json['type'] ?? '').toString(),
      screenType: (json['screenType'] ?? '').toString(),
      action: (json['action'] ?? '').toString(),
      apiEndpoint: (json['apiEndpoint'] ?? '').toString(),
      inputType: (json['inputType'] ?? '').toString(),
      outputRenderer: (json['outputRenderer'] ?? '').toString(),
      outputTemplate: (json['outputTemplate'] ?? '').toString(),
      inputLabel: (json['inputLabel'] ?? '').toString(),
      heading: (json['heading'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      outputTitle: (json['outputTitle'] ?? '').toString(),
      payload: _readMap(json['payload']),
      studyConfig: _readMap(json['studyConfig']),
      uiConfig: _readMap(json['uiConfig']),
      addedAt: DateTime.tryParse((json['addedAt'] ?? '').toString()),
      missingCatalogEntry: json['missingCatalogEntry'] == true,
    );
  }
}

class HistoryModel {
  final String id;
  final String promptId;
  final String userEmail;
  final String widgetType;
  final String prompt;
  final String content;
  final String modelName;
  final DateTime createdAt;

  const HistoryModel({
    required this.id,
    required this.promptId,
    required this.userEmail,
    required this.widgetType,
    required this.prompt,
    required this.content,
    required this.modelName,
    required this.createdAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      promptId: (json['promptId'] ?? '').toString(),
      userEmail: (json['userEmail'] ?? '').toString(),
      widgetType: (json['widgetType'] ?? json['type'] ?? 'myai').toString(),
      prompt: (json['prompt'] ?? '').toString(),
      content: (json['content'] ?? json['response'] ?? '').toString(),
      modelName: (json['modelName'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
