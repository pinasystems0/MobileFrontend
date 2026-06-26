import 'package:flutter/material.dart';
import 'package:pina/screens/study_abroad/germany/germany_overview_screen.dart';
import '../../../services/role_guard.dart';

class StudyAbroadScreen extends StatelessWidget {
  const StudyAbroadScreen({super.key});

@override
  Widget build(BuildContext context) {
    return RoleGuard(
      feature: 'STUDY_ABROAD',
      child: Scaffold(
        appBar: AppBar(
  title: Row(
    children: [
      Image.asset(
        'assets/template/icons/arthum_logo.png',
        height: 28,
        width: 28,
      ),
      const SizedBox(width: 8),
      const Text(
        "Study Abroad",
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  ),
),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= TITLE =================
              const Text(
                "🌍 Select Your Study Destination",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================= CARDS =================
              Expanded(
                child: ListView(
                  children: [

                    // 🇩🇪 GERMANY CARD (ACTIVE)
                    _countryCard(
                      context,
                      flag: "🇩🇪",
                      name: "Germany",
                      subtitle: "Free education • Top universities • EU jobs",
                      active: true,
                      onTap: () {
                        Navigator.push(
                                     context,
                                     MaterialPageRoute(
                                       builder: (_) => GermanyOverviewScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // FUTURE COUNTRIES
                    _countryCard(
                      context,
                      flag: "🇫🇷",
                      name: "France",
                      subtitle: "Coming Soon",
                      active: false,
                    ),

                    const SizedBox(height: 16),

                    _countryCard(
                      context,
                      flag: "🇮🇪",
                      name: "Ireland",
                      subtitle: "Coming Soon",
                      active: false,
                    ),

                    const SizedBox(height: 16),

                    _countryCard(
                      context,
                      flag: "🇳🇱",
                      name: "Netherlands",
                      subtitle: "Coming Soon",
                      active: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // PREMIUM COUNTRY CARD
  // =========================
  Widget _countryCard(
    BuildContext context, {
    required String flag,
    required String name,
    required String subtitle,
    bool active = true,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: active ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),

          // active = blue gradient
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xff5B86E5), Color(0xff36D1DC)],
                )
              : null,

          color: active ? null : Colors.grey.shade200,

          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [

            // FLAG
            Text(flag, style: const TextStyle(fontSize: 28)),

            const SizedBox(width: 14),

            // TEXTS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: active ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: active ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // ARROW
            if (active)
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 16)
            else
              const Text("Soon"),
          ],
        ),
      ),
    );
  }
}
