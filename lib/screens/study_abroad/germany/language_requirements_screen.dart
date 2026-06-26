import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LanguageRequirementsScreen extends StatelessWidget {
  const LanguageRequirementsScreen({super.key});

  // ================= PDF GENERATOR =================
  Future<void> _generatePdf(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (_) => [
          pw.Header(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Language Requirements for Germany 🇩🇪",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  "Complete Guide for English & German Programs",
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Divider(color: PdfColors.indigo200, thickness: 2),
              ],
            ),
          ),
          _pdfSection("🗣 LANGUAGE DEPENDS ON PROGRAM", [
            "• English-taught courses → English proficiency certificate required",
            "• German-taught courses → German language certificate mandatory",
            "• Some programs may require both languages",
          ]),
          _pdfSection("📘 ENGLISH LANGUAGE REQUIREMENTS", [
            "• IELTS: Usually 6.0–6.5+ bands required",
            "• Higher scores (6.5+) preferred for top universities",
            "• TOEFL: Score varies by university (often 90+ overall)",
            "• Cambridge certificates accepted by some universities",
            "• Medium of instruction certificate may be accepted",
          ]),
          _pdfSection("🇩🇪 GERMAN LANGUAGE REQUIREMENTS", [
            "• TestDaF: Often requires level TDN4 (all sections)",
            "• DSH: German language exam (DSH-2 or above required)",
            "• Goethe-Institut: B2/C1/C2 certificates recognized",
            "• telc Deutsch C1 Hochschule accepted",
            "• DSD II (Deutsches Sprachdiplom) valid",
          ]),
          _pdfSection("📊 WHY LANGUAGE CERTIFICATE MATTERS", [
            "• Required for university admission",
            "• Mandatory for German student visa application",
            "• Needed to handle academic lectures & assignments",
            "• Helps in social & academic integration in Germany",
          ]),
          _pdfSection("✅ QUICK TIPS", [
            "• English programs: IELTS 6.5+ recommended",
            "• German programs: Start preparing early (B2/C1 takes time)",
            "• Check specific university requirements on their website",
            "• Keep original certificates ready for visa",
            "• Some universities offer German language courses",
          ]),
          pw.SizedBox(height: 20),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          pw.Text(
            "Generated from Germany Study Guide App",
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    try {
      await Printing.layoutPdf(onLayout: (format) => pdf.save());
      Navigator.pop(context); // Close loading
      
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF generated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static pw.Widget _pdfSection(String title, List<String> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 20),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.indigo800,
          ),
        ),
        pw.SizedBox(height: 8),
        ...items.map((e) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
              child: pw.Text(
                e,
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.4),
              ),
            )),
      ],
    );
  }

  // ================= MAIN UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      
      body: CustomScrollView(
        slivers: [
          // ========== MODERN HEADER ==========
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6366F1), // Indigo
                      Color(0xFF8B5CF6), // Purple
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.language_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Language Requirements',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'English & German proficiency guide',
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
                ),
              ),
            ),
          ),

          // ========== MAIN CONTENT ==========
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ========== INFO ALERT ==========
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Language certificate is mandatory for German student visa",
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6366F1),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ========== SECTION TITLE ==========
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    'Language Guide',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                // 1️⃣ Program Language
                _buildModernCard(
                  icon: Icons.school_rounded,
                  title: "Language Depends on Program",
                  emoji: "🗣",
                  color: const Color(0xFF6366F1),
                  items: const [
                    "English-taught courses → English proficiency required",
                    "German-taught courses → German certificate mandatory",
                    "Some programs may require both languages",
                  ],
                ),

                const SizedBox(height: 14),

                // 2️⃣ English Requirements
                _buildModernCard(
                  icon: Icons.public_rounded,
                  title: "English Language Requirements",
                  emoji: "📘",
                  color: const Color(0xFF2563EB),
                  items: const [
                    "IELTS: Usually 6.0–6.5+ bands required",
                    "Higher scores (6.5+) preferred for top universities",
                    "TOEFL: Score varies by university (often 90+ overall)",
                    "Cambridge certificates accepted by some universities",
                    "Medium of instruction certificate may be accepted",
                  ],
                ),

                const SizedBox(height: 14),

                // 3️⃣ German Requirements
                _buildModernCard(
                  icon: Icons.translate_rounded,
                  title: "German Language Requirements",
                  emoji: "🇩🇪",
                  color: const Color(0xFF059669),
                  items: const [
                    "TestDaF: Often requires level TDN4 (all sections)",
                    "DSH: German language exam (DSH-2 or above required)",
                    "Goethe-Institut: B2/C1/C2 certificates recognized",
                    "telc Deutsch C1 Hochschule accepted",
                    "DSD II (Deutsches Sprachdiplom) valid",
                  ],
                ),

                const SizedBox(height: 14),

                // 4️⃣ Why it Matters
                _buildModernCard(
                  icon: Icons.stars_rounded,
                  title: "Why Language Certificate Matters",
                  emoji: "📊",
                  color: const Color(0xFFDB2777),
                  items: const [
                    "Required for university admission",
                    "Mandatory for German student visa application",
                    "Needed to handle academic lectures & assignments",
                    "Helps in social & academic integration in Germany",
                  ],
                ),

                const SizedBox(height: 14),

                // 5️⃣ Quick Tips
                _buildModernCard(
                  icon: Icons.lightbulb_outline_rounded,
                  title: "Quick Tips",
                  emoji: "✅",
                  color: const Color(0xFFF59E0B),
                  items: const [
                    "English programs: IELTS 6.5+ recommended",
                    "German programs: Start preparing early (B2/C1 takes time)",
                    "Check specific university requirements on their website",
                    "Keep original certificates ready for visa",
                    "Some universities offer German language courses",
                  ],
                ),

                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),

      // ========== BOTTOM DOWNLOAD BUTTON (FIXED) ==========
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A), // Dark Blue
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _generatePdf(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'DOWNLOAD LANGUAGE GUIDE PDF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========== MODERN CARD DESIGN ==========
  Widget _buildModernCard({
    required IconData icon,
    required String title,
    required String emoji,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$emoji $title',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: color,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF334155),
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}