import 'package:flutter/material.dart';

import '../models/widget_model.dart';
import 'chat_screen.dart';

class WidgetChatScreen extends StatelessWidget {
  final WidgetModel widgetItem;
  final String userEmail;

  const WidgetChatScreen({
    super.key,
    required this.widgetItem,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return ChatScreen(
      widgetItem: widgetItem,
      userEmail: userEmail,
    );
  }
}
