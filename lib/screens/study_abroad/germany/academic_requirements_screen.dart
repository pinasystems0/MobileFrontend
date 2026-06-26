import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AcademicRequirementsScreen extends StatelessWidget {
  const AcademicRequirementsScreen({super.key});

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
                  "Germany Academic Requirements Guide 🎓",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  "Complete Eligibility & Document Checklist",
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
          _pdfSection("🎓 WHO CAN APPLY?", [
            "• After 12th → Bachelor (UG) programmes",
            "• After Bachelor → Master (PG) programmes",
            "• After Master → PhD programmes",
            "• Qualification must be recognized in Germany",
          ]),
          _pdfSection("📊 MINIMUM MARKS REQUIRED", [
            "• UG: 60–70% recommended in 12th",
            "• PG: 60%+ or 2.5 German GPA equivalent",
            "• Top universities may need higher scores",
            "• Backlogs should be minimal",
          ]),
          _pdfSection("🏫 STUDIENKOLLEG (FOUNDATION YEAR)", [
            "• Needed if 12th certificate is not equivalent to German Abitur",
            "• 1-year preparatory course",
            "• Includes subject + German language training",
            "• You must pass final exam (Feststellungsprüfung)",
          ]),
          _pdfSection("🗣 LANGUAGE REQUIREMENTS", [
            "• English courses → IELTS / TOEFL",
            "• German courses → TestDaF / DSH / Goethe",
            "• B2–C1 level commonly required",
          ]),
          _pdfSection("📄 REQUIRED ACADEMIC DOCUMENTS", [
            "• 10th & 12th marksheets",
            "• Degree certificate (Bachelor/Master)",
            "• Transcripts",
            "• Passport copy",
            "• Resume (CV)",
            "• Statement of Purpose (SOP)",
            "• Letters of Recommendation (LOR)",
            "• APS certificate (mandatory for Indian students)",
          ]),
          _pdfSection("💶 FINANCIAL REQUIREMENT (VISA)", [
            "• Blocked account proof required",
            "• Approx €11,904 per year",
            "• Health insurance mandatory",
            "• Admission letter required for visa",
          ]),
          _pdfSection("✅ QUICK TIPS", [
            "• Apply 6–8 months early",
            "• Prepare documents in PDF format",
            "• Keep notarized copies ready",
            "• Check each university's website carefully",
            "• Maintain good GPA + strong SOP",
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
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1E3A8A), // Deep Indigo
                      Color(0xFF2563EB), // Bright Blue
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
                                Icons.school_rounded,
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
                                    'Academic Requirements',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Complete eligibility guide for Germany',
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
                    color: const Color(0xFF1E3A8A).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF1E3A8A).withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A),
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
                          "Check your eligibility before applying to German universities",
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A8A),
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
                    'Requirement Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                // 1️⃣ Who can apply
                _buildModernCard(
                  icon: Icons.person_outline_rounded,
                  title: "Who Can Apply?",
                  emoji: "🎓",
                  color: const Color(0xFF2563EB),
                  items: const [
                    "After 12th → Bachelor (UG) programmes",
                    "After Bachelor → Master (PG) programmes",
                    "After Master → PhD programmes",
                    "Qualification must be recognized in Germany",
                  ],
                ),

                const SizedBox(height: 14),

                // 2️⃣ Minimum marks
                _buildModernCard(
                  icon: Icons.grade_rounded,
                  title: "Minimum Marks Required",
                  emoji: "📊",
                  color: const Color(0xFF7C3AED),
                  items: const [
                    "UG: 60–70% recommended in 12th",
                    "PG: 60%+ or 2.5 German GPA equivalent",
                    "Top universities may need higher scores",
                    "Backlogs should be minimal",
                  ],
                ),

                const SizedBox(height: 14),

                // 3️⃣ Foundation course
                _buildModernCard(
                  icon: Icons.school_rounded,
                  title: "Studienkolleg (Foundation Year)",
                  emoji: "🏫",
                  color: const Color(0xFFDB2777),
                  items: const [
                    "Needed if 12th is not equivalent to German Abitur",
                    "1-year preparatory course",
                    "Includes subject + German language training",
                    "Must pass final exam (Feststellungsprüfung)",
                  ],
                ),

                const SizedBox(height: 14),

                // 4️⃣ Language
                _buildModernCard(
                  icon: Icons.translate_rounded,
                  title: "Language Requirements",
                  emoji: "🗣",
                  color: const Color(0xFFEA580C),
                  items: const [
                    "English courses → IELTS / TOEFL",
                    "German courses → TestDaF / DSH / Goethe",
                    "B2–C1 level commonly required",
                  ],
                ),

                const SizedBox(height: 14),

                // 5️⃣ Documents
                _buildModernCard(
                  icon: Icons.description_rounded,
                  title: "Required Academic Documents",
                  emoji: "📄",
                  color: const Color(0xFF0891B2),
                  items: const [
                    "10th & 12th marksheets",
                    "Degree certificate (Bachelor/Master)",
                    "Transcripts",
                    "Passport copy",
                    "Resume (CV)",
                    "Statement of Purpose (SOP)",
                    "Letters of Recommendation (LOR)",
                    "APS certificate (mandatory for Indian students)",
                  ],
                ),

                const SizedBox(height: 14),

                // 6️⃣ Financial
                _buildModernCard(
                  icon: Icons.account_balance_wallet_rounded,
                  title: "Financial Requirement (Visa)",
                  emoji: "💶",
                  color: const Color(0xFF059669),
                  items: const [
                    "Blocked account proof required",
                    "Approx €11,904 per year",
                    "Health insurance mandatory",
                    "Admission letter required for visa",
                  ],
                ),

                const SizedBox(height: 14),

                // 7️⃣ Tips
                _buildModernCard(
                  icon: Icons.lightbulb_outline_rounded,
                  title: "Quick Tips",
                  emoji: "✅",
                  color: const Color(0xFFF59E0B),
                  items: const [
                    "Apply 6–8 months early",
                    "Prepare documents in PDF format",
                    "Keep notarized copies ready",
                    "Check each university's website carefully",
                    "Maintain good GPA + strong SOP",
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
                    'DOWNLOAD COMPLETE GUIDE',
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