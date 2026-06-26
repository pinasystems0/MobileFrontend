import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GermanyAfterArrivalInfoScreen extends StatelessWidget {
  const GermanyAfterArrivalInfoScreen({super.key});

  // ================= PDF GENERATOR =================
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Header(
            child: pw.Text(
              "🇩🇪 Germany After Arrival - Complete Guide",
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
          ),

          _pdfSection("📌 IMMEDIATE STEPS (Day 1-3)", [
            "• Move into your accommodation",
            "• Sign & collect rental contract (Mietvertrag)",
            "• Take photos of all documents",
            "• Buy groceries & essentials",
            "• Get local SIM card (Prepaid)",
          ]),

          _pdfSection("🏛 CITY REGISTRATION (Anmeldung)", [
            "• Mandatory within 14 days of arrival",
            "• Visit Bürgeramt/City Registration Office",
            "• Documents needed:",
            "  - Valid passport with visa",
            "  - Rental contract (Mietvertrag)",
            "  - Wohnungsgeberbestätigung (landlord confirmation)",
            "  - Registration form",
            "• Get Meldebescheinigung (registration certificate)",
            "• Fee: Free",
          ]),

          _pdfSection("🪪 RESIDENCE PERMIT (Aufenthaltstitel)", [
            "• Apply at Ausländerbehörde (Foreigners Office)",
            "• Convert your visa to residence permit",
            "• Documents required:",
            "  - Anmeldung certificate",
            "  - Passport + biometric photos",
            "  - Health insurance confirmation",
            "  - Blocked account proof",
            "  - University enrollment certificate",
            "  - €100-110 fee",
            "• Processing: 4-8 weeks",
          ]),

          _pdfSection("🏦 BANK ACCOUNT OPENING", [
            "• Why needed: Blocked account release, salary, rent",
            "• Popular banks:",
            "  - N26 (100% digital, English app)",
            "  - Deutsche Bank (university合作)",
            "  - Sparkasse (local branches)",
            "  - Commerzbank",
            "• Documents: Passport, Anmeldung, enrollment letter",
            "• Blocked account: €992/month released",
          ]),

          _pdfSection("🩺 HEALTH INSURANCE ACTIVATION", [
            "• Public insurance (Gesetzliche Krankenkasse):",
            "  - TK (Techniker Krankenkasse)",
            "  - AOK",
            "  - Barmer",
            "  - DAK",
            "• Monthly cost: €120-130 (students under 30)",
            "• Documents: Passport, enrollment letter, bank details",
            "• Submit insurance certificate to university",
          ]),

          _pdfSection("🎓 UNIVERSITY ENROLLMENT (Immatrikulation)", [
            "• Pay semester fee (€300-€400/semester)",
            "• Submit documents:",
            "  - Admission letter",
            "  - Health insurance certificate",
            "  - Passport copy",
            "  - Previous degree certificates",
            "  - Semester fee payment proof",
            "• Get student ID card",
            "• Benefits: Semester ticket (free transport), student discounts",
          ]),

          _pdfSection("📱 SIM CARD & INTERNET", [
            "• Prepaid SIM: €10-20 (Aldi Talk, Lidl Connect, Congstar)",
            "• Postpaid plans: €20-40/month (Telekom, Vodafone, O2)",
            "• Documents: Passport, Anmeldung",
            "• Home internet: €30-50/month",
          ]),

          _pdfSection("💼 WORK RULES FOR STUDENTS", [
            "• 120 full days OR 240 half days per year",
            "• Student assistant (HiWi): €12-15/hour",
            "• Internship: often unlimited if mandatory",
            "• Freelance: allowed with restrictions",
            "• Minijob: €520/month tax-free",
          ]),

          _pdfSection("❌ COMMON MISTAKES TO AVOID", [
            "• Missing Anmeldung deadline (14 days)",
            "• Not booking Ausländerbehörde appointment early",
            "• Forgetting to activate health insurance",
            "• Not keeping copies of all documents",
            "• Ignoring semester fee payment deadline",
            "• Working more than allowed hours",
          ]),

          _pdfSection("✅ COMPLETE CHECKLIST", [
            "Week 1:",
            "  ✓ Move into accommodation",
            "  ✓ Do Anmeldung",
            "  ✓ Buy SIM card",
            "  ✓ Open bank account",
            "",
            "Week 2-3:",
            "  ✓ Activate health insurance",
            "  ✓ Enroll at university",
            "  ✓ Apply for residence permit",
            "",
            "Week 4+:",
            "  ✓ Get student ID",
            "  ✓ Receive blocked account money",
            "  ✓ Explore city",
            "  ✓ Start studies",
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
        pw.SizedBox(height: 16),
        pw.Text(title,
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
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
          // ========== PREMIUM HEADER ==========
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E3A8A),
                      const Color(0xFF2563EB),
                      const Color(0xFF3B82F6),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative elements
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.03),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // German flag stripe
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF000000), // Black
                              Color(0xFFFF0000), // Red
                              Color(0xFFFFCC00), // Gold
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Header content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 45),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      '🇩🇪 AFTER ARRIVAL',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'First Steps in Germany',
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ========== MAIN CONTENT ==========
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ========== IMMEDIATE STEPS ==========
                _buildInfoCard(
                  icon: Icons.home_work_outlined,
                  title: "📌 IMMEDIATE STEPS (Day 1-3)",
                  color: const Color(0xFF2563EB),
                  items: const [
                    "🏠 Move into accommodation",
                    "📝 Sign rental contract (Mietvertrag)",
                    "📸 Take photos of all documents",
                    "🛒 Buy groceries & essentials",
                    "📱 Get local SIM card - Prepaid",
                  ],
                ),

                const SizedBox(height: 12),

                // ========== ANMELDUNG ==========
                _buildInfoCard(
                  icon: Icons.location_city,
                  title: "🏛 ANMELDUNG (City Registration)",
                  color: const Color(0xFF4F46E5),
                  items: const [
                    "⏰ Mandatory within 14 days of arrival",
                    "📍 Visit Bürgeramt/City Registration Office",
                    "📄 Documents needed:",
                    "   • Valid passport with visa",
                    "   • Rental contract (Mietvertrag)",
                    "   • Wohnungsgeberbestätigung",
                    "   • Registration form",
                    "✅ Get Meldebescheinigung (certificate)",
                    "💰 Fee: Free",
                  ],
                ),

                const SizedBox(height: 12),

                // ========== RESIDENCE PERMIT ==========
                _buildInfoCard(
                  icon: Icons.badge_outlined,
                  title: "🪪 RESIDENCE PERMIT (Aufenthaltstitel)",
                  color: const Color(0xFF7C3AED),
                  items: const [
                    "🏢 Apply at Ausländerbehörde",
                    "🔄 Convert visa to residence permit",
                    "📋 Documents required:",
                    "   • Anmeldung certificate",
                    "   • Passport + biometric photos",
                    "   • Health insurance confirmation",
                    "   • Blocked account proof",
                    "   • University enrollment",
                    "   • €100-110 fee",
                    "⏳ Processing: 4-8 weeks",
                  ],
                ),

                const SizedBox(height: 12),

                // ========== BANK ACCOUNT ==========
                _buildBankCard(),

                const SizedBox(height: 12),

                // ========== HEALTH INSURANCE ==========
                _buildInfoCard(
                  icon: Icons.health_and_safety_outlined,
                  title: "🩺 HEALTH INSURANCE ACTIVATION",
                  color: const Color(0xFFDC2626),
                  items: const [
                    "🏥 Public insurance options:",
                    "   • TK (Techniker Krankenkasse)",
                    "   • AOK",
                    "   • Barmer",
                    "   • DAK",
                    "💰 Monthly cost: €120-130 (under 30)",
                    "📄 Documents: Passport, enrollment, bank details",
                    "✅ Submit certificate to university",
                  ],
                ),

                const SizedBox(height: 12),

                // ========== UNIVERSITY ENROLLMENT ==========
                _buildInfoCard(
                  icon: Icons.school_outlined,
                  title: "🎓 UNIVERSITY ENROLLMENT (Immatrikulation)",
                  color: const Color(0xFFEA580C),
                  items: const [
                    "💰 Pay semester fee (€300-€400)",
                    "📑 Submit documents:",
                    "   • Admission letter",
                    "   • Health insurance certificate",
                    "   • Passport copy",
                    "   • Previous degree certificates",
                    "   • Semester fee payment proof",
                    "🪪 Get student ID card",
                    "🎫 Benefits: Semester ticket, student discounts",
                  ],
                ),

                const SizedBox(height: 12),

                // ========== SIM CARD ==========
                _buildInfoCard(
                  icon: Icons.sim_card_outlined,
                  title: "📱 SIM CARD & INTERNET",
                  color: const Color(0xFF0891B2),
                  items: const [
                    "📞 Prepaid SIM: €10-20",
                    "   • Aldi Talk, Lidl Connect, Congstar",
                    "📱 Postpaid plans: €20-40/month",
                    "   • Telekom, Vodafone, O2",
                    "📄 Documents: Passport, Anmeldung",
                    "🏠 Home internet: €30-50/month",
                  ],
                ),

                const SizedBox(height: 12),

                // ========== WORK RULES ==========
                _buildInfoCard(
                  icon: Icons.work_outline,
                  title: "💼 WORK RULES FOR STUDENTS",
                  color: const Color(0xFF0D9488),
                  items: const [
                    "📊 120 full days OR 240 half days/year",
                    "👨‍🏫 Student assistant (HiWi): €12-15/hour",
                    "💼 Internship: unlimited if mandatory",
                    "💰 Minijob: €520/month tax-free",
                    "⚠️ Don't exceed allowed hours",
                  ],
                ),

                const SizedBox(height: 12),

                // ========== COMMON MISTAKES ==========
                _buildInfoCard(
                  icon: Icons.warning_amber_outlined,
                  title: "❌ COMMON MISTAKES TO AVOID",
                  color: const Color(0xFFB45309),
                  items: const [
                    "⚠️ Missing Anmeldung deadline (14 days)",
                    "⚠️ Not booking Ausländerbehörde early",
                    "⚠️ Forgetting health insurance activation",
                    "⚠️ No copies of documents",
                    "⚠️ Missing semester fee deadline",
                    "⚠️ Working more than allowed hours",
                  ],
                ),

                const SizedBox(height: 12),

                // ========== COMPLETE CHECKLIST ==========
                _buildChecklistCard(),

                const SizedBox(height: 24),

                // ========== PDF BUTTON ==========
                Container(
                  width: double.infinity,
                  height: 54,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E3A8A).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _generatePdf,
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                    label: const Text(
                      "📥 DOWNLOAD COMPLETE AFTER ARRIVAL GUIDE",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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

  // ========== BANK CARD - SPECIAL DESIGN ==========
  Widget _buildBankCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F2C4E),
            const Color(0xFF1A3A5F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2C4E).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "🏦 BANK ACCOUNT OPENING",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _buildBankRow("N26", "100% digital, English app", Icons.phone_android),
                const SizedBox(height: 10),
                _buildBankRow("Deutsche Bank", "University cooperation", Icons.account_balance),
                const SizedBox(height: 10),
                _buildBankRow("Sparkasse", "Local branches", Icons.location_on),
                const SizedBox(height: 10),
                _buildBankRow("Commerzbank", "Student accounts", Icons.credit_card),
                
                const Divider(color: Colors.white30, height: 20),
                
                Row(
                  children: [
                    Icon(Icons.description, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Documents: Passport, Anmeldung, Enrollment",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.euro, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Blocked account: €992/month released",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankRow(String bank, String desc, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 8),
        Text(
          bank,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            "• $desc",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // ========== CHECKLIST CARD ==========
  Widget _buildChecklistCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.checklist_rtl,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "✅ COMPLETE CHECKLIST",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChecklistSection("Week 1", [
                  "✓ Move into accommodation",
                  "✓ Do Anmeldung",
                  "✓ Buy SIM card",
                  "✓ Open bank account",
                ]),
                const SizedBox(height: 12),
                _buildChecklistSection("Week 2-3", [
                  "✓ Activate health insurance",
                  "✓ Enroll at university",
                  "✓ Apply for residence permit",
                ]),
                const SizedBox(height: 12),
                _buildChecklistSection("Week 4+", [
                  "✓ Get student ID",
                  "✓ Receive blocked account money",
                  "✓ Explore city",
                  "✓ Start studies",
                ]),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF10B981), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Keep all documents organized! You'll need them for residence permit and future applications.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF065F46),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: const Color(0xFF10B981).withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ),
      ],
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: color,
                  ),
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
                    child: Icon(
                      Icons.circle,
                      size: 5,
                      color: color.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        color: item.startsWith('   •') 
                            ? Colors.grey.shade700
                            : const Color(0xFF334155),
                        fontWeight: item.startsWith('   •') 
                            ? FontWeight.w400
                            : FontWeight.w500,
                        height: 1.35,
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