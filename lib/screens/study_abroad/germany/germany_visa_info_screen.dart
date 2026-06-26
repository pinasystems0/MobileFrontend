import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GermanyVisaInfoScreen extends StatelessWidget {
  const GermanyVisaInfoScreen({super.key});

  // =========================
  // PDF GENERATOR
  // =========================
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              "Germany Student Visa Guide 🇩🇪",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          _pdfSection("Who Needs Visa?", [
            "Non-EU/EEA students must apply for visa",
            "Indian students – visa mandatory",
            "Without visa entry not allowed",
            "Type: National Student Visa (Type D)"
          ]),
          _pdfSection("Types of Study Visas", [
            "Student Visa – Full degree studies (most common)",
            "Language Course Visa – German language course only",
            "Applicant Visa – For job seekers / admission seekers"
          ]),
          _pdfSection("📄 Mandatory Documents", [
            "Valid passport (at least 1 year validity)",
            "2 fully completed visa application forms",
            "3 biometric passport photos (35x45mm, white bg)",
            "University admission letter (Zulassungsbescheid)",
            "APS certificate – mandatory for Indian students",
            "All academic transcripts (10th, 12th, Bachelor)",
            "German language certificate (Goethe, TestDaF, etc.)",
            "English proficiency (IELTS/TOEFL if course in English)",
            "Statement of Purpose (SOP) & CV",
            "German health insurance – public or private",
            "Financial proof – Blocked account (€11,904)",
            "Embassy appointment confirmation & fee receipt"
          ]),
          _pdfSection("💰 Financial Proof – CRITICAL", [
            "Minimum required: €11,904 per year (€992/month)",
            "Accepted methods:",
            "  • Blocked account (Fintiba, Expatrio, Coracle)",
            "  • Scholarship award letter (DAAD, etc.)",
            "  • German national sponsor (Verpflichtungserklärung)",
            "⚠️ Insufficient funds = 100% rejection"
          ]),
          _pdfSection("🔄 Visa Process – Step by Step", [
            "1. Get university admission",
            "2. Open blocked account & deposit funds",
            "3. Buy health insurance (travel + statutory)",
            "4. Book appointment at German embassy (VFS/consulate)",
            "5. Prepare document checklist",
            "6. Attend visa interview (biometrics + questions)",
            "7. Wait for processing (3-12 weeks)",
            "8. Collect visa & travel to Germany"
          ]),
          _pdfSection("⏱ Processing Time", [
            "Standard: 3–12 weeks",
            "Peak season (July-Sept): up to 12 weeks",
            "Apply at least 3 months before intake",
            "⚠️ Late application = semester delay"
          ]),
          _pdfSection("🇩🇪 After Arrival in Germany", [
            "Register address (Anmeldung) – within 14 days",
            "Apply for residence permit at Ausländerbehörde",
            "Open German bank account",
            "Activate health insurance",
            "Get SIM card & internet",
            "Enroll at university (Immatrikulation)"
          ]),
          _pdfSection("❌ Common Rejection Reasons", [
            "Insufficient or unverified funds",
            "APS certificate missing",
            "Course not matching previous studies",
            "Weak SOP / unclear study plans",
            "Health insurance not valid for Germany"
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
        pw.SizedBox(height: 14),
        pw.Text(title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        ...items.map((e) => pw.Bullet(text: e)),
      ],
    );
  }

  // =========================
  // MAIN UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          // ========== SMALLER HEADER - LENGTH KAM KIYA ==========
          SliverAppBar(
            expandedHeight: 90, // ✅ REDUCED from 140 to 90
            pinned: true,
            floating: true,
            backgroundColor: const Color(0xFF0B2F66),
            foregroundColor: Colors.white,
            elevation: 2,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0B2F66),
                      const Color(0xFF1E4A7A),
                      const Color(0xFF2A5F8A),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // German flag pattern overlay
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 80, // ✅ SMALLER
                        height: 80, // ✅ SMALLER
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
                        width: 100, // ✅ SMALLER
                        height: 100, // ✅ SMALLER
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.03),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // German flag colors stripe
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3, // ✅ SLIGHTLY SMALLER
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40), // ✅ ADJUSTED
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8), // ✅ SMALLER
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.flight_takeoff,
                                  color: Colors.white,
                                  size: 22, // ✅ SMALLER
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '🇩🇪 GERMANY STUDENT VISA',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16, // ✅ SMALLER (was 20)
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'NATIONAL VISA • TYPE D',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10, // ✅ SMALLER
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
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
                // ========== VISA STICKER CARD ==========
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B2F66),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              '🇩🇪 GERMAN NATIONAL VISA - TYPE D',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // ========== LOCAL ASSET VISA IMAGE ==========
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/study_abroad/visa.png',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.contact_mail,
                                    size: 48,
                                    color: const Color(0xFF0B2F66).withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Visa Sticker Preview',
                                    style: TextStyle(
                                      color: const Color(0xFF0B2F66).withOpacity(0.7),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // ========== VISA INFO GRID ==========
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildVisaInfoChip(
                                    Icons.verified,
                                    'Type D',
                                    'National Visa',
                                    Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildVisaInfoChip(
                                    Icons.calendar_month,
                                    'Validity',
                                    '90 Days - 1 Year',
                                    Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildVisaInfoChip(
                                    Icons.school,
                                    'Purpose',
                                    'Full Time Studies',
                                    Colors.purple,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildVisaInfoChip(
                                    Icons.work,
                                    'Work Permit',
                                    '120 Full Days',
                                    Colors.orange,
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

                const SizedBox(height: 20),

                // ========== INFO CARDS - CLEAN & COLORFUL ==========
                _buildInfoCard(
                  icon: Icons.person_outline,
                  title: 'WHO NEEDS VISA?',
                  color: const Color(0xFF2563EB),
                  items: const [
                    '🎓 Non-EU/EEA students - Mandatory',
                    '🇮🇳 Indian passport holders - MUST apply',
                    '🚫 No visa = No entry at German border',
                    '📌 Schengen Visa (Type C) not valid for studies',
                  ],
                ),

                _buildInfoCard(
                  icon: Icons.school_outlined,
                  title: 'STUDY VISA TYPES',
                  color: const Color(0xFF0891B2),
                  items: const [
                    '📘 Student Visa - Full degree (Bachelor/Master/PhD)',
                    '🗣 Language Course Visa - German language only',
                    '🔍 Applicant Visa - Seek admission in Germany',
                    '💡 Most Indian students apply for Student Visa',
                    '✅ Part-time work: 120 full/240 half days',
                  ],
                ),

                _buildInfoCard(
                  icon: Icons.description_outlined,
                  title: 'DOCUMENTS CHECKLIST',
                  color: const Color(0xFF4F46E5),
                  items: const [
                    '✅ Passport - 1+ year validity, 2+ blank pages',
                    '✅ VIDEX form - 2 sets + declaration',
                    '✅ Biometric photos - 3 copies (35x45mm)',
                    '✅ University admission letter (Zulassung)',
                    '✅ APS certificate - ORIGINAL - Indians MUST',
                    '✅ Academic transcripts - 10th, 12th, Bachelor',
                    '✅ German/English certificate - A1/B1 or IELTS',
                    '✅ SOP (1-2 pages) + Tabular CV',
                    '✅ Health insurance - Valid for Germany',
                    '✅ Blocked account - €11,904 confirmation',
                    '✅ Appointment confirmation + fee receipt (€75)',
                  ],
                ),

                _buildInfoCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'FINANCIAL PROOF',
                  color: const Color(0xFFEA580C),
                  items: const [
                    '💰 MINIMUM: €11,904 per year (2024)',
                    '🏦 Blocked account: Fintiba, Expatrio, Coracle',
                    '🎓 DAAD scholarship - Minimum €11,904',
                    '👪 German sponsor (Verpflichtungserklärung)',
                    '⚠️ Insufficient funds = 100% REJECTION',
                    '📌 Open account BEFORE visa appointment',
                    '💳 Processing: 3-7 days for confirmation',
                  ],
                ),

                _buildInfoCard(
                  icon: Icons.timeline_outlined,
                  title: 'VISA PROCESS',
                  color: const Color(0xFF7E22CE),
                  items: const [
                    '1️⃣ Get university admission letter',
                    '2️⃣ Open blocked account - Deposit €11,904',
                    '3️⃣ Buy travel + statutory health insurance',
                    '4️⃣ Fill VIDEX form online',
                    '5️⃣ Book VFS/Embassy appointment',
                    '6️⃣ Prepare 3 sets of documents',
                    '7️⃣ Attend visa interview - Biometrics',
                    '8️⃣ Wait for processing (3-12 weeks)',
                    '9️⃣ Collect passport with visa sticker',
                    '🔟 Fly to Germany within validity',
                  ],
                ),

                _buildInfoCard(
                  icon: Icons.hourglass_empty,
                  title: 'PROCESSING TIME',
                  color: const Color(0xFFB91C1C),
                  items: const [
                    '⏳ Standard processing: 3-12 weeks',
                    '📆 Peak season (July-Sept): 10-12 weeks',
                    '🕐 Apply minimum 3 months before intake',
                    '⚠️ Late application = Semester delay',
                    '✅ Chennai: 3-6 weeks (fastest)',
                    '✅ Delhi/Mumbai: 6-10 weeks',
                    '✅ Bangalore: 4-8 weeks',
                  ],
                ),

                _buildInfoCard(
                  icon: Icons.home_outlined,
                  title: 'AFTER ARRIVAL',
                  color: const Color(0xFF0D9488),
                  items: const [
                    '🏠 Anmeldung - Address registration (14 days)',
                    '🪪 Residence permit - Ausländerbehörde (€100)',
                    '🏦 German bank account - N26, Deutsche Bank',
                    '🩺 Activate health insurance - TK, AOK',
                    '📱 Get German SIM card - Telekom, Vodafone',
                    '🎓 University enrollment - Pay semester fee',
                    '💳 Blocked account release - €992/month',
                  ],
                ),

                _buildInfoCard(
                  icon: Icons.warning_outlined,
                  title: 'REJECTION REASONS',
                  color: const Color(0xFFB45309),
                  items: const [
                    '🔴 Insufficient funds - #1 reason',
                    '🔴 APS certificate missing/invalid',
                    '🔴 Course mismatch with previous degree',
                    '🔴 Weak SOP - No academic motivation',
                    '🔴 Invalid health insurance',
                    '🔴 Fake or incomplete documents',
                    '🔴 Insufficient language skills',
                    '🔴 Previous visa rejection - No explanation',
                  ],
                ),

                _buildInfoCard(
                  icon: Icons.tips_and_updates_outlined,
                  title: 'EXPERT TIPS',
                  color: const Color(0xFF6B21A8),
                  items: const [
                    '🎯 Winter intake - More university options',
                    '📅 Book VFS 4-6 months in advance',
                    '💬 Learn A1 German - 80% higher success',
                    '📧 Professional email for embassy',
                    '✅ Public universities - Higher acceptance',
                    '💰 Show extra funds - €12,000+ recommended',
                    '📋 APS - Apply 4-5 months before intake',
                  ],
                ),

                const SizedBox(height: 24),

                // ========== PDF BUTTON ==========
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B2F66).withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _generatePdf,
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text(
                      "📥 DOWNLOAD COMPLETE VISA GUIDE",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B2F66),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
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

  // ========== VISA INFO CHIP ==========
  Widget _buildVisaInfoChip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
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
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEF2F6)),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 5,
                      color: color.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                        height: 1.45,
                        fontWeight: FontWeight.w400,
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