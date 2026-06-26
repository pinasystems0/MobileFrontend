import 'package:flutter/material.dart';

import '../config/widget_configs.dart';
import '../models/widget_model.dart';
import 'chat_screen.dart';
import 'form_screen.dart';
import 'study_screen.dart';
import 'upload_screen.dart';

class BaseWidgetScreen extends StatelessWidget {
  final WidgetModel widgetItem;
  final String userEmail;

  const BaseWidgetScreen({
    super.key,
    required this.widgetItem,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final config = resolveWidgetConfigForWidget(widgetItem);

    // Priority-based routing by action, then by screenType
    if (config.action == 'transcribe') {
      return UploadScreen(
        widgetItem: widgetItem,
        userEmail: userEmail,
      );
    }

    if (config.screenType == 'study') {
      return StudyScreen(
        userEmail: userEmail,
        widgetItem: widgetItem,
      );
    }

    if (config.screenType == 'upload') {
      return UploadScreen(
        widgetItem: widgetItem,
        userEmail: userEmail,
      );
    }

    if (config.screenType == 'form') {
      return FormScreen(
        widgetItem: widgetItem,
        userEmail: userEmail,
      );
    }

    // Default: unified chat screen
    return ChatScreen(
      widgetItem: widgetItem,
      userEmail: userEmail,
    );
  }
}
