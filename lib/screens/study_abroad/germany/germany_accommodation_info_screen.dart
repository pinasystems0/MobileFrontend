import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GermanyAccommodationInfoScreen extends StatelessWidget {
  const GermanyAccommodationInfoScreen({super.key});

  // ================= PDF GENERATOR =================
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Header(
            child: pw.Text(
              "Germany Student Accommodation Guide 🏠",
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
              ),
            ),
          ),

          _pdfSection("🎓 WHY ACCOMMODATION MATTERS", [
            "• Daily Life & Stability – Required for Anmeldung, bank account, residence permit",
            "• Focus on studies without housing stress",
            "• Mandatory for all official registrations in Germany",
          ]),

          _pdfSection("🏛 VISA & EMBASSY REQUIREMENTS", [
            "• Proof of accommodation is recommended for visa application",
            "• Some consulates list it under required documents",
            "• Best practice: Always be ready to provide proof",
            "• Residence permit AFTER arrival REQUIRES registered address",
          ]),

          _pdfSection("🏡 STUDENT ACCOMMODATION TYPES", [
            "• Student Dormitories (Studentenwerk) – €250–€400/month",
            "  - Cheapest option, student-oriented",
            "  - Apply early – very high demand",
            "",
            "• Shared Flats (WG - Wohngemeinschaft) – €350–€600/month",
            "  - Most popular for international students",
            "  - Private bedroom + shared kitchen/bathroom",
            "",
            "• Private Apartments – €600–€1000+/month",
            "  - More privacy, often furnished",
            "  - Closer to university areas",
            "",
            "• Temporary Housing – €50–€100/night",
            "  - Hostels, Airbnb for initial arrival",
            "  - Use while finding long-term housing",
          ]),

          _pdfSection("💡 HOUSING EXAMPLES BY CITY", [
            "• Berlin – Student rooms: €550–€900/month",
            "• Munich – Student apartments: €450–€900/month",
            "• Frankfurt – Shared flats: €600–€900/month",
            "• Smaller cities – €350–€700/month",
            "",
            "✓ All include: Wi-Fi, Laundry, Furnished, Near transport",
          ]),

          _pdfSection("📄 ACCEPTED PROOF DOCUMENTS", [
            "✓ Rental agreement (Mietvertrag)",
            "✓ Dormitory booking confirmation",
            "✓ University housing office letter",
            "✓ Hotel/Hostel booking (temporary)",
            "✓ Room offer from shared flat",
            "✓ Amberstudent booking confirmation",
          ]),

          _pdfSection("📊 MONTHLY BUDGET BREAKDOWN", [
            "City Average Rent:",
            "  Berlin        → €550–€900",
            "  Munich        → €600–€1,200",
            "  Frankfurt     → €600–€900",
            "  Smaller cities→ €350–€700",
            "",
            "Additional Monthly Costs:",
            "  Utilities     → €50–€120",
            "  Internet      → €20–€30",
            "  Transport pass→ €30–€60",
            "",
            "💶 TOTAL: €600–€900/month (average)",
          ]),

          _pdfSection("🧭 HOW TO FIND ACCOMMODATION", [
            "✨ Amberstudent Platform:",
            "  • Search, shortlist & book in few steps",
            "  • Dedicated support throughout process",
            "",
            "🏫 University Housing Office:",
            "  • On-campus dorm options",
            "  • Assistance with nearby housing",
            "",
            "📱 Apps & Websites:",
            "  • WG-Gesucht – shared apartments",
            "  • Facebook housing groups",
            "  • Apply 2–3 months before arrival",
          ]),

          _pdfSection("🔑 AFTER ARRIVAL – STEP BY STEP", [
            "1. Move into your accommodation",
            "2. Sign rental contract (Mietvertrag)",
            "3. Register address (Anmeldung) – within 14 days",
            "4. Use address for:",
            "   • Bank account opening",
            "   • Health insurance activation",
            "   • SIM card registration",
            "   • Residence permit application",
          ]),

          _pdfSection("✅ KEY TAKEAWAYS", [
            "• Visa: Proof not always mandatory, but keep ready",
            "• Apply early – reduces stress & helps registration",
            "• Budget wisely – rent is biggest monthly expense",
            "• Keep all contracts and documents safe",
            "• Right accommodation = smooth student life in Germany",
          ]),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  static pw.Widget _pdfSection(String title, List<String> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 18),
        pw.Text(title,
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            )),
        pw.SizedBox(height: 6),
        ...items.map((e) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8),
              child: pw.Text(e, style: const pw.TextStyle(fontSize: 10.5)),
            )),
      ],
    );
  }

  // ================= MAIN UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      
      body: CustomScrollView(
        slivers: [
          // ========== CLEAN HEADER ==========
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFF0B5E42),
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0B5E42),
                      const Color(0xFF1A7B5A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.home_work_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'GERMANY ACCOMMODATION',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Student Housing Guide',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ========== MAIN CONTENT ==========
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ========== WHY ACCOMMODATION MATTERS ==========
                _buildInfoCard(
                  icon: Icons.school_outlined,
                  title: "🎓 WHY ACCOMMODATION MATTERS",
                  color: const Color(0xFF2563EB),
                  items: const [
                    "📌 Required for Anmeldung (address registration)",
                    "📌 Needed for bank account & residence permit",
                    "📌 Focus on studies without housing stress",
                    "📌 Mandatory for all official registrations",
                  ],
                ),

                const SizedBox(height: 12),

                // ========== VISA REQUIREMENTS ==========
                _buildInfoCard(
                  icon: Icons.contact_mail_outlined,
                  title: "🏛 VISA & EMBASSY REQUIREMENTS",
                  color: const Color(0xFF7C3AED),
                  items: const [
                    "📋 Recommended for visa application",
                    "📋 Some consulates require it",
                    "📋 Always keep proof ready",
                    "📋 Residence permit needs registered address",
                  ],
                ),

                const SizedBox(height: 12),

                // ========== ACCOMMODATION TYPES ==========
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0891B2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.apartment,
                              color: Color(0xFF0891B2),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "🏡 ACCOMMODATION TYPES",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0891B2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildSimpleTypeTile(
                        title: "Student Dormitories",
                        sub: "Studentenwerk",
                        price: "€250–€400",
                        desc: "Cheapest option, apply early",
                        color: const Color(0xFF0891B2),
                      ),
                      
                      _buildSimpleTypeTile(
                        title: "Shared Flats",
                        sub: "WG - Wohngemeinschaft",
                        price: "€350–€600",
                        desc: "Most popular, private room",
                        color: const Color(0xFF0D9488),
                      ),
                      
                      _buildSimpleTypeTile(
                        title: "Private Apartments",
                        sub: "Studio / 1-room",
                        price: "€600–€1000+",
                        desc: "More privacy, furnished",
                        color: const Color(0xFFB45309),
                      ),
                      
                      _buildSimpleTypeTile(
                        title: "Temporary Housing",
                        sub: "Hostels/Airbnb",
                        price: "€50–€100/night",
                        desc: "For initial arrival",
                        color: const Color(0xFF6B7280),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ========== HOUSING EXAMPLES ==========
                _buildInfoCard(
                  icon: Icons.location_city,
                  title: "💡 HOUSING EXAMPLES BY CITY",
                  color: const Color(0xFF9D174D),
                  items: const [
                    "📍 Berlin: €550–€900/month",
                    "📍 Munich: €450–€900/month",
                    "📍 Frankfurt: €600–€900/month",
                    "📍 Smaller cities: €350–€700/month",
                    "✓ Wi-Fi • Laundry • Furnished • Near transport",
                  ],
                ),

                const SizedBox(height: 12),

                // ========== PROOF DOCUMENTS ==========
                _buildInfoCard(
                  icon: Icons.description_outlined,
                  title: "📄 ACCEPTED PROOF DOCUMENTS",
                  color: const Color(0xFF4F46E5),
                  items: const [
                    "✓ Rental agreement (Mietvertrag)",
                    "✓ Dormitory booking confirmation",
                    "✓ University housing letter",
                    "✓ Hotel/Hostel booking",
                    "✓ Room offer from shared flat",
                    "✓ Amberstudent confirmation",
                  ],
                ),

                const SizedBox(height: 12),

                // ========== BUDGET CARD - LIGHT THEME ==========
                _buildBudgetCardLight(),

                const SizedBox(height: 12),

                // ========== HOW TO FIND ==========
                _buildInfoCard(
                  icon: Icons.search,
                  title: "🧭 HOW TO FIND ACCOMMODATION",
                  color: const Color(0xFFEA580C),
                  items: const [
                    "✨ Amberstudent: Book online, dedicated support",
                    "🏫 University Housing: On-campus dorms",
                    "📱 WG-Gesucht: Shared apartments",
                    "📘 Facebook: Student housing groups",
                    "⏰ Apply 2–3 months before arrival",
                  ],
                ),

                const SizedBox(height: 12),

                // ========== AFTER ARRIVAL STEPS ==========
                _buildStepsCardSimple(),

                const SizedBox(height: 12),

                // ========== KEY TAKEAWAYS ==========
                _buildInfoCard(
                  icon: Icons.key,
                  title: "✅ KEY TAKEAWAYS",
                  color: const Color(0xFF7E22CE),
                  items: const [
                    "• Keep accommodation proof ready for visa",
                    "• Apply early – avoid last minute stress",
                    "• Rent is your biggest monthly expense",
                    "• Save all contracts and documents",
                    "• Good housing = smooth student life",
                  ],
                ),

                const SizedBox(height: 24),

                // ========== PDF BUTTON - FIXED OVERFLOW ==========
                Container(
                  width: double.infinity,
                  height: 52,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B5E42), Color(0xFF1A7B5A)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B5E42).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _generatePdf,
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18),
                    label: const Text(
                      "DOWNLOAD ACCOMMODATION GUIDE",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ========== SIMPLE TYPE TILE ==========
  Widget _buildSimpleTypeTile({
    required String title,
    required String sub,
    required String price,
    required String desc,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "($sub)",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== BUDGET CARD - LIGHT THEME (FIXED) ==========
  Widget _buildBudgetCardLight() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFF1E3A5F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "📊 MONTHLY BUDGET",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A5F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // City rents
          _buildBudgetRowLight("Berlin", "€550–€900"),
          _buildBudgetRowLight("Munich", "€600–€1,200"),
          _buildBudgetRowLight("Frankfurt", "€600–€900"),
          _buildBudgetRowLight("Smaller cities", "€350–€700"),
          
          const Divider(height: 24),
          
          const Text(
            "Additional monthly costs:",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          
          _buildCostRowLight(Icons.electric_bolt, "Utilities", "€50–€120"),
          _buildCostRowLight(Icons.wifi, "Internet", "€20–€30"),
          _buildCostRowLight(Icons.directions_bus, "Transport pass", "€30–€60"),
          
          const Divider(height: 24),
          
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F).withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "💰 TOTAL AVERAGE:",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                Text(
                  "€600–€900/month",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRowLight(String city, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            city,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF1E3A5F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRowLight(IconData icon, String label, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Color(0xFF1E3A5F),
            ),
          ),
        ],
      ),
    );
  }

  // ========== SIMPLE STEPS CARD ==========
  Widget _buildStepsCardSimple() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.checklist_rtl,
                  color: Color(0xFF0D9488),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "🔑 AFTER ARRIVAL STEPS",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0D9488),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildStepSimple(1, "Move into your accommodation"),
          _buildStepSimple(2, "Sign rental contract (Mietvertrag)"),
          _buildStepSimple(3, "Register address - Anmeldung (within 14 days)"),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "📍 Use address for:",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF0D9488),
                  ),
                ),
                const SizedBox(height: 10),
                _buildUseItemSimple("Bank account opening"),
                _buildUseItemSimple("Health insurance activation"),
                _buildUseItemSimple("SIM card registration"),
                _buildUseItemSimple("Residence permit application"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepSimple(int step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$step",
                style: const TextStyle(
                  color: Color(0xFF0D9488),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUseItemSimple(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 14, color: const Color(0xFF0D9488).withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  // ========== CLEAN INFO CARD ==========
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle, size: 5, color: color.withOpacity(0.6)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}