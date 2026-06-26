class StudyChapterSelection {
  final String board;
  final String standard;
  final String subjectName;
  final String chapterName;

  const StudyChapterSelection({
    this.board = '',
    this.standard = '',
    this.subjectName = '',
    this.chapterName = '',
  });

  bool get isComplete =>
      board.trim().isNotEmpty &&
      standard.trim().isNotEmpty &&
      subjectName.trim().isNotEmpty &&
      chapterName.trim().isNotEmpty;

  StudyChapterSelection copyWith({
    String? board,
    String? standard,
    String? subjectName,
    String? chapterName,
    bool resetStandard = false,
    bool resetSubject = false,
    bool resetChapter = false,
  }) {
    return StudyChapterSelection(
      board: board ?? this.board,
      standard: resetStandard ? '' : (standard ?? this.standard),
      subjectName: resetSubject ? '' : (subjectName ?? this.subjectName),
      chapterName: resetChapter ? '' : (chapterName ?? this.chapterName),
    );
  }
}

class StudyContentModel {
  final String id;
  final String board;
  final String standard;
  final String stream;
  final String subjectName;
  final String unitName;
  final String chapterName;
  final String contentType;
  final String title;
  final String content;
  final String pdfUrl;
  final String status;
  final DateTime? createdAt;

  const StudyContentModel({
    required this.id,
    required this.board,
    required this.standard,
    required this.stream,
    required this.subjectName,
    required this.unitName,
    required this.chapterName,
    required this.contentType,
    required this.title,
    required this.content,
    required this.pdfUrl,
    required this.status,
    this.createdAt,
  });

  factory StudyContentModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] is Map
        ? Map<String, dynamic>.from(json['metadata'] as Map)
        : const <String, dynamic>{};

    return StudyContentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      board: (json['board'] ?? '').toString(),
      standard: (json['standard'] ?? '').toString(),
      stream: (json['stream'] ?? '').toString(),
      subjectName: (json['subjectName'] ?? '').toString(),
      unitName: (json['unitName'] ?? '').toString(),
      chapterName: (json['chapterName'] ?? '').toString(),
      contentType: (json['contentType'] ?? '').toString(),
      title: (json['title'] ?? json['chapterName'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      pdfUrl: (json['pdfUrl'] ?? metadata['pdfUrl'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }

  bool get hasPdf => pdfUrl.trim().isNotEmpty;

  String get sectionKey {
    switch (contentType.trim().toLowerCase()) {
      case 'chapter_summary':
        return 'summary';
      case 'short_notes':
        return 'notes';
      case 'mcq_test':
        return 'mcq';
      case 'practice_questions':
        return 'test';
      default:
        return contentType.trim().toLowerCase();
    }
  }
}

class StudyOutlineModel {
  final int totalRecords;
  final List<StudyBoardNode> boards;

  const StudyOutlineModel({
    required this.totalRecords,
    required this.boards,
  });

  factory StudyOutlineModel.fromJson(Map<String, dynamic> json) {
    final rawBoards = json['boards'];
    return StudyOutlineModel(
      totalRecords: int.tryParse((json['totalRecords'] ?? '0').toString()) ?? 0,
      boards: rawBoards is List
          ? rawBoards
              .whereType<Map>()
              .map((item) => StudyBoardNode.fromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false)
          : const [],
    );
  }
}

class StudyBoardNode {
  final String board;
  final List<StudyStandardNode> standards;

  const StudyBoardNode({
    required this.board,
    required this.standards,
  });

  factory StudyBoardNode.fromJson(Map<String, dynamic> json) {
    final rawStandards = json['standards'];
    return StudyBoardNode(
      board: (json['board'] ?? '').toString(),
      standards: rawStandards is List
          ? rawStandards
              .whereType<Map>()
              .map((item) => StudyStandardNode.fromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false)
          : const [],
    );
  }
}

class StudyStandardNode {
  final String standard;
  final List<StudySubjectNode> subjects;

  const StudyStandardNode({
    required this.standard,
    required this.subjects,
  });

  factory StudyStandardNode.fromJson(Map<String, dynamic> json) {
    final rawSubjects = json['subjects'];
    return StudyStandardNode(
      standard: (json['standard'] ?? '').toString(),
      subjects: rawSubjects is List
          ? rawSubjects
              .whereType<Map>()
              .map((item) => StudySubjectNode.fromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false)
          : const [],
    );
  }
}

class StudySubjectNode {
  final String subjectName;
  final List<String> chapters;

  const StudySubjectNode({
    required this.subjectName,
    required this.chapters,
  });

  factory StudySubjectNode.fromJson(Map<String, dynamic> json) {
    final rawChapters = json['chapters'];
    return StudySubjectNode(
      subjectName: (json['subjectName'] ?? '').toString(),
      chapters: rawChapters is List
          ? rawChapters.map((item) => item.toString()).toList(growable: false)
          : const [],
    );
  }
}
