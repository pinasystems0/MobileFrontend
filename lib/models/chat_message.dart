import 'package:flutter/foundation.dart';

/// A UI-only representation of a chat message.
///
/// This model is intentionally simple because the Educational Chatbot
/// feature is currently UI-only (no backend / no AI logic).
@immutable
class ChatMessage {
  /// Unique id for rendering/stable ordering.
  final String id;

  /// True if the message is from the user; false if from the bot.
  final bool isUser;

  /// Message content.
  final String text;

  const ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
  });
}

