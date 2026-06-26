import 'package:flutter/material.dart';
import 'package:pina/screens/loginscreen.dart';
import 'package:pina/ui_template/utils/template_layout.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Function to handle navigation
  void _handleSearch(BuildContext context, String value) {
    if (value.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // Optional: Show a snackbar if input is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter something to search")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Local controller keeps widget stateless while capturing input.
    final TextEditingController _searchController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TemplateLayout(
       brandTitle: "Arthum AI",
        brandSubtitle: "Search the platform with the template shell applied.",
        sectionTitle: "Home",
        sectionSubtitle: "Find the tools and content you need",
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Find what\nyou need",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: TemplateTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  decoration: TemplateTheme.glassPanel(
                    color: Colors.white,
                    opacity: 0.82,
                    radius: 24,
                  ),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) => _handleSearch(context, value),
                    decoration: InputDecoration(
                      hintText: "Search anything...",
                      hintStyle: const TextStyle(
                        color: TemplateTheme.textMuted,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: TemplateTheme.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          color: TemplateTheme.primary,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
