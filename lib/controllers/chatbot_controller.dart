import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../services/chatbot_service.dart';

/// Controller for the Educational Chatbot.
///
/// - Sends questions to backend API
/// - Maintains message list
/// - Maintains typing indicator state
/// - Handles error messages gracefully
class ChatbotController extends ChangeNotifier {
  ChatbotController({List<ChatMessage>? initialMessages}) {
    if (initialMessages != null) {
      _messages = List<ChatMessage>.from(initialMessages);
    }
  }

  final ChatbotService _chatbotService = const ChatbotService();

  List<ChatMessage> _messages = <ChatMessage>[];
  bool _isBotTyping = false;

  /// Read-only view for UI.
  List<ChatMessage> get messages => List<ChatMessage>.unmodifiable(_messages);

  bool get isBotTyping => _isBotTyping;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  bool _canSend(String text) {
    return text.trim().isNotEmpty;
  }

  void _setBotTyping(bool value) {
    if (_isBotTyping == value) return;
    _isBotTyping = value;
    notifyListeners();
  }

  Future<void> sendMessage(String rawText) async {
    if (!_canSend(rawText)) return;
    if (_disposed) return;

    final text = rawText.trim();

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isUser: true,
      text: text,
    );

    // 1) User message immediately appears.
    _messages.add(userMessage);
    notifyListeners();

    // 2) Show typing indicator while backend request is in flight.
    _setBotTyping(true);

    String botText;
    try {
      botText = await _chatbotService.sendChatMessage(question: text);
      if (botText.trim().isEmpty) {
        botText = 'No response received from server. Please try again.';
      }
    } catch (error, stackTrace) {
      debugPrint('========== CHATBOT CONTROLLER ERROR ==========');
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
      botText = 'Sorry, I could not connect to the chatbot service. Please try again later.';
    }

    if (_disposed) return;
    _setBotTyping(false);

    final botMessage = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      isUser: false,
      text: botText,
    );

    _messages.add(botMessage);
    notifyListeners();
  }
}

