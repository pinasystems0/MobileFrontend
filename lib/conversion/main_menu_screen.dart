import 'package:flutter/material.dart';
import 'package:pina/conversion/shared/conversion_router.dart';
import 'package:pina/conversion/shared/submission_service.dart';
import 'package:pina/screens/loginscreen.dart';
import 'package:pina/services/role_service.dart';
import 'package:pina/services/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainMenuScreen extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? userEmail;

  const MainMenuScreen({
    super.key,
    this.userId,
    this.userName,
    this.userEmail,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final SubmissionService _submissionService = SubmissionService();
  bool _isLoading = false;

  final Map<String, List<String>> menu = const {
    "Text": [
      "Text to Text",
      "Text to Image",
      "Text to Audio",
      "Text to Video",
    ],
    "Image": [
      "Image to Text",
      "Image to Image",
      "Image to Audio",
      "Image to Video",
    ],
    "Audio": [
      "Audio to Text",
      "Audio to Image",
      "Audio to Audio",
      "Audio to Video",
    ],
    "Video": [
      "Video to Text",
      "Video to Image",
      "Video to Audio",
      "Video to Video",
    ],
  };

  bool _canShowOption(String optionTitle) {
    return RoleService.canAccessConversionOptionSync(optionTitle);
  }

  Map<String, List<String>> get _visibleMenu {
    final filtered = <String, List<String>>{};

    for (final entry in menu.entries) {
      final visibleOptions =
          entry.value.where(_canShowOption).toList(growable: false);
      if (visibleOptions.isNotEmpty) {
        filtered[entry.key] = visibleOptions;
      }
    }

    return filtered;
  }

  // ✅ FINAL FIXED FUNCTION
  Future<void> _handleOptionClick(String optionTitle) async {
    final String? userId = widget.userId;
    final String userEmail = widget.userEmail ?? "";

    if (userEmail.isEmpty || userId == null || userId.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("postLoginFeature", optionTitle);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _submissionService.checkUserEligibility(
      userEmail: userEmail,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.success) {
      final screen = buildConversionScreen(
        optionTitle: optionTitle,
        userId: userId,
        userEmail: userEmail,
      );

      if (screen == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Conversion type is not available yet."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
      return;
    }

    if (result.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("postLoginFeature", optionTitle);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.errorMessage ?? "Access Denied"),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userName != null ? "Hi, ${widget.userName}" : "Main Menu",
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: _visibleMenu.entries.map((entry) {
              return ExpansionTile(
                title: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: entry.value.map((sub) {
                  return ListTile(
                    title: Text(sub),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _handleOptionClick(sub),
                  );
                }).toList(),
              );
            }).toList(),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}