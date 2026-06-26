/// ------------------------------------------------------------
/// 📁 File: chat_session.dart
/// 📂 Module: MyAI (Frontend)
///
/// 🧠 Purpose:
/// Data models for chat sessions and messages in MyAI widget chats.
///
/// ⚙️ Responsibilities:
/// - ChatMessage: stores role/text/timestamp for conversation history
/// - ChatSession: manages session with widget type and messages list
///
/// 🔗 Backend Connection:
/// - Endpoint: /myai/history (save/load)
/// - Method: POST/GET/DELETE
/// - Service Used: myai_api_service.dart (saveHistory/getHistory)
/// - Data Flow:
///   UI chat → toJson() → Service → /history → Backend DB → fromJson() → UI
///
/// 📦 Data Used:
/// - ChatMessage/JSON {role, text, timestamp}
/// - Sent: session data for persistence
/// - Received: history list for sidebar/loading past chats
///
/// 🔗 Connected Frontend Files:
/// - widget_chat_screen.dart → uses Message model (similar)
/// - history_sidebar.dart → displays HistoryModel (related)
/// - myai_api_service.dart → serializes/deserializes
///
/// 🔗 Connected Backend:
/// - myaiRoutes.js → /history routes
/// - myaiController.js → save/getHistory handlers
/// - myaiService.js → Conversion model persistence
///
/// 🧩 Type:
/// Model (Chat Data Structures)
///
/// ⚠️ Notes:
/// - Do NOT modify logic here
/// - Part of MyAI chat history flow
///
/// ------------------------------------------------------------
class ChatMessage {
  final String role; // 'user' or 'ai'
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ChatSession {
  final String sessionId;
  final String widgetType;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  String title;

  ChatSession({
    required this.sessionId,
    required this.widgetType,
    required this.messages,
    required this.createdAt,
    this.title = '',
  });

  factory ChatSession.fromHistory(Map<String, dynamic> history) {
    return ChatSession(
      sessionId: history['id'],
      widgetType: history['widgetType'],
      messages: [],
      createdAt: DateTime.parse(history['createdAt']),
      title: history['prompt'] ?? '',
    );
  }

  ChatSession copyWith({
    String? sessionId,
    String? widgetType,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    String? title,
  }) {
    return ChatSession(
      sessionId: sessionId ?? this.sessionId,
      widgetType: widgetType ?? this.widgetType,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
    );
  }
}

