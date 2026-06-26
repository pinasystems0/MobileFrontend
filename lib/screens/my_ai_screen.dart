import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../my_ai/screens/myai_home_screen.dart';

class MyAiScreen extends StatelessWidget {
  const MyAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        SessionService.getUserName(),
        SessionService.getUserEmail(),
      ]).then((results) => {
        'user': {
          'name': results[0] ?? 'User',
          'email': results[1] ?? '',
        },
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(child: Text('Error loading user data')),
          );
        }

        final user = snapshot.data!['user'] as Map<String, dynamic>? ?? {};

        return MyAiHomeScreen(
          userEmail: user['email']?.toString() ?? '',
        );
      },
    );
  }
}
