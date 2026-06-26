import 'package:flutter/material.dart';
import 'package:pina/screens/study_abroad/germany/germany_checklist_screen.dart';
import '../../../../services/role_guard.dart';


class GermanyOverviewScreen extends StatefulWidget {
  const GermanyOverviewScreen({Key? key}) : super(key: key);

  @override
  State<GermanyOverviewScreen> createState() =>
      _GermanyOverviewScreenState();
}

class _GermanyOverviewScreenState extends State<GermanyOverviewScreen> {
  int _currentIndex = 0;

  final List<String> germanyImages = [
    "assets/study_abroad/germany1.jpg",
    "assets/study_abroad/germany2.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Germany Study Guide"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= IMAGE SLIDER =================
            SizedBox(
              height: 230,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      itemCount: germanyImages.length,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      itemBuilder: (_, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            germanyImages[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      germanyImages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin:
                            const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 14 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _currentIndex == index
                              ? Colors.indigo
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= INFO CARD =================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.06),
                  )
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🇩🇪 Study in Germany",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Germany is one of the best destinations for international students because of affordable education and strong career opportunities.",
                    style: TextStyle(height: 1.5),
                  ),
                  SizedBox(height: 14),

                  Text("• Very low or zero tuition fees"),
                  Text("• Top-ranked public universities"),
                  Text("• Strong job market in Europe"),
                  Text("• Part-time work allowed"),
                  Text("• UG / PG / Diploma / PhD programs"),
                  Text("• High quality of life & safety"),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ================= NEXT STEP CARD (NEW UI) =================
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.indigo),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Next: Complete your Germany study requirements checklist and track your preparation.",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ================= CONTINUE BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                   Navigator.push(
                      context,
                      MaterialPageRoute(
                         builder: (_) => const GermanyChecklistScreen(),
                        ),
                  );
                },
                child: const Text(
                  "Continue →",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
