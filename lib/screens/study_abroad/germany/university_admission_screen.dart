import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class UniversityAdmissionScreen extends StatefulWidget {
  const UniversityAdmissionScreen({super.key});

  @override
  State<UniversityAdmissionScreen> createState() => _UniversityAdmissionScreenState();
}

class _UniversityAdmissionScreenState extends State<UniversityAdmissionScreen> {
  bool _showUniversityInfo = true;
  bool _isGeneratingPDF = false;

  // List of popular universities
  final List<Map<String, dynamic>> popularUniversities = [
    {
      'name': 'Technical University of Munich (TUM)',
      'field': 'Engineering, Data Science, AI',
      'info': 'Ranked #1 in Germany for Engineering',
      'color': 'blue',
      'students': '42,000+',
      'founded': '1868',
      'location': 'Munich, Bavaria',
      'rank': '#1 in Germany',
      'icon': Icons.science,
    },
    {
      'name': 'Ludwig Maximilian University of Munich (LMU)',
      'field': 'Science, Management, Research',
      'info': 'One of Europe\'s premier academic institutions',
      'color': 'green',
      'students': '50,000+',
      'founded': '1472',
      'location': 'Munich, Bavaria',
      'rank': '#2 in Germany',
      'icon': Icons.psychology,
    },
    {
      'name': 'Heidelberg University',
      'field': 'Life Sciences, Medicine',
      'info': 'Germany\'s oldest university, world-class research',
      'color': 'purple',
      'students': '29,000+',
      'founded': '1386',
      'location': 'Heidelberg, Baden-Württemberg',
      'rank': '#3 in Germany',
      'icon': Icons.local_hospital,
    },
    {
      'name': 'RWTH Aachen University',
      'field': 'Mechanical, Automotive, Robotics',
      'info': 'Leading technical university in Europe',
      'color': 'orange',
      'students': '47,000+',
      'founded': '1870',
      'location': 'Aachen, North Rhine-Westphalia',
      'rank': '#4 in Germany',
      'icon': Icons.settings,
    },
  ];

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'green': return const Color(0xFF059669);
      case 'purple': return const Color(0xFF9333EA);
      case 'orange': return const Color(0xFFF97316);
      case 'red': return const Color(0xFFDC2626);
      case 'indigo': return const Color(0xFF4F46E5);
      default: return const Color(0xFF2563EB);
    }
  }

  // ================= PDF GENERATION =================
  Future<void> _generatePDF() async {
    setState(() => _isGeneratingPDF = true);

    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('dd MMM yyyy');
      final now = DateTime.now();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'GERMANY UNIVERSITY GUIDE',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo800,
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.indigo50,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      'Study in Germany',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.indigo800,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Complete Guide to Public Universities & Admission',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.indigo200, thickness: 1.5),
              pw.SizedBox(height: 20),

              // University Section
              pw.Text(
                '🏛️ TOP PUBLIC UNIVERSITIES',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.indigo800,
                ),
              ),
              pw.SizedBox(height: 15),

              // Universities List in PDF
              ...popularUniversities.map((uni) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  border: pw.Border.all(color: PdfColors.indigo100),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          uni['name'],
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo900,
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.indigo100,
                            borderRadius: pw.BorderRadius.circular(12),
                          ),
                          child: pw.Text(
                            uni['rank'],
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.indigo800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      '📍 ${uni['location']}',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '🔬 ${uni['field']}',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'ℹ️ ${uni['info']}',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                    ),
                  ],
                ),
              )).toList(),

              pw.SizedBox(height: 20),

              // Fees Section
              pw.Text(
                '💰 FEES & FINANCE',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.indigo800,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.green200),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'NO TUITION FEES',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green800,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Most public universities charge €0 tuition fees',
                      style: pw.TextStyle(fontSize: 11, color: PdfColors.green700),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Semester Fees', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text('€200 - €400', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('per semester', style: pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.purple50,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Living Costs', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text('€850 - €1,200', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('per month', style: pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  children: [
                    pw.Text('🔒 ', style: pw.TextStyle(fontSize: 14)),
                    pw.Expanded(
                      child: pw.Text(
                        'Blocked Account: €11,208 (2024) required for visa',
                        style: pw.TextStyle(fontSize: 11, color: PdfColors.orange900),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Important Notes Section
              pw.Text(
                '📌 IMPORTANT REQUIREMENTS',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.indigo800,
                ),
              ),
              pw.SizedBox(height: 10),
              
              // Checklist in PDF
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildPDFChecklistItem('APS Certificate', true),
                    _buildPDFChecklistItem('Bachelor\'s Degree', true),
                    _buildPDFChecklistItem('Transcript of Records', true),
                    _buildPDFChecklistItem('Language Certificate (IELTS/TOEFL/Goethe)', true),
                    _buildPDFChecklistItem('Statement of Purpose', true),
                    _buildPDFChecklistItem('Letters of Recommendation', true),
                    _buildPDFChecklistItem('CV/Resume', true),
                    _buildPDFChecklistItem('Passport Copy', true),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Application Strategy
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '🎯 Application Strategy',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text('• Apply to 3-5 universities', style: const pw.TextStyle(fontSize: 11)),
                    pw.Text('• 1-2 dream, 1-2 match, 1-2 safe universities', style: const pw.TextStyle(fontSize: 11)),
                    pw.Text('• Track deadlines carefully', style: const pw.TextStyle(fontSize: 11)),
                    pw.Text('• Apply through uni-assist if required', style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generated on: ${dateFormat.format(now)}',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'Germany Study Guide • Public Universities',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('PDF generated successfully!'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPDF = false);
      }
    }
  }

  pw.Widget _buildPDFChecklistItem(String title, bool isRequired) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.Container(
            width: 16,
            height: 16,
            decoration: pw.BoxDecoration(
              color: isRequired ? PdfColors.green600 : PdfColors.grey300,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: isRequired 
              ? pw.Icon(pw.IconData(0xE5CA), color: PdfColors.white, size: 12)
              : pw.SizedBox(),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 11,
                color: isRequired ? PdfColors.grey900 : PdfColors.grey500,
              ),
            ),
          ),
          if (isRequired)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: pw.BoxDecoration(
                color: PdfColors.red50,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Text(
                'Required',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.red700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUniStat(String emoji, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1E3A8A)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ================= UNIVERSITY INFO CARD =================
  Widget _buildUniversityInfoCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Top Public Universities in Germany",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Free Education • World Class Degrees",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _showUniversityInfo ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: const Color(0xFF1E3A8A),
                    ),
                    onPressed: () {
                      setState(() {
                        _showUniversityInfo = !_showUniversityInfo;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            if (_showUniversityInfo) ...[
              const SizedBox(height: 20),
              
              // Statistics Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('43+', 'Public Unis', Icons.account_balance),
                    _buildStatItem('1000+', 'English Programs', Icons.translate),
                    _buildStatItem('€0', 'Tuition Fee', Icons.euro),
                    _buildStatItem('300+', 'Courses', Icons.menu_book),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Universities List
              ...popularUniversities.map((uni) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getColor(uni['color']).withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _getColor(uni['color']).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getColor(uni['color']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(uni['icon'], color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  uni['name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getColor(uni['color']).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  uni['rank'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _getColor(uni['color']),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            uni['field'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                uni['location'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildUniStat('🎓', uni['students']),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
              
              // >>>>>>>>>>>> THE "VIEW ALL 40+ UNIVERSITIES" BUTTON HAS BEEN REMOVED FROM HERE <<<<<<<<<<<<
              
            ],
          ],
        ),
      ),
    );
  }

  // ================= COURSE DETAILS INFO CARD =================
  Widget _buildCourseDetailsCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.menu_book, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Course Details & Programs",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "What you can study in Germany",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Degree Types Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🎓 Degree Programs",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDegreeChip("Bachelor", "3-4 years", Icons.school, const Color(0xFF2563EB)),
                      _buildDegreeChip("Master", "2 years", Icons.psychology, const Color(0xFF059669)),
                      _buildDegreeChip("PhD", "3-5 years", Icons.science, const Color(0xFF9333EA)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDegreeChip("Diploma", "4-5 years", Icons.assignment, const Color(0xFFF97316)),
                      _buildDegreeChip("State Exam", "5 years", Icons.gavel, const Color(0xFFDC2626)),
                      _buildDegreeChip("MBA", "1-2 years", Icons.business_center, const Color(0xFF0D9488)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Popular Fields
            const Text(
              "🔥 Popular Fields of Study",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFieldChip("Engineering", Icons.engineering, Colors.blue),
                _buildFieldChip("Computer Science", Icons.computer, Colors.indigo),
                _buildFieldChip("Data Science", Icons.data_usage, Colors.cyan),
                _buildFieldChip("Automotive", Icons.directions_car, Colors.red),
                _buildFieldChip("Mechanical", Icons.settings, Colors.orange),
                _buildFieldChip("Medicine", Icons.local_hospital, Colors.green),
                _buildFieldChip("Business", Icons.attach_money, Colors.purple),
                _buildFieldChip("Physics", Icons.science, Colors.teal),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Intake Information
            Row(
              children: [
                Icon(Icons.calendar_month, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Intake Seasons",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Winter (Oct) - Application by July 15\nSummer (Apr) - Application by Jan 15",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Text(
                    "Winter is Main Intake",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF97316),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Study Mode - FIXED: Removed hybrid_connectivity
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildModeChip(Icons.business_center, "Full-time", "Most Common"),
                  _buildModeChip(Icons.access_time, "Part-time", "Limited"),
                  _buildModeChip(Icons.laptop, "Online", "Available"),
                  _buildModeChip(Icons.sync_alt, "Hybrid", "Growing"), // FIXED: Changed hybrid_connectivity to sync_alt
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Fact
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF97316).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Color(0xFFF97316), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Most Master's programs in Germany are taught in English!",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDegreeChip(String title, String duration, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              duration,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF1E3A8A)),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  // ================= FEES & FINANCE INFO CARD =================
  Widget _buildFeesFinanceCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF059669).withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.euro, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Fees & Cost of Living",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Study in Germany for free (almost)",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Main Highlight Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDCFCE7), Color(0xFFF0FDF4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "NO TUITION FEES",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF059669),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Most public universities charge €0 tuition fees",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      "🎉",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Semester Fees
            Row(
              children: [
                Expanded(
                  child: _buildFeeCard(
                    "Semester Fees",
                    "€200 - €400",
                    "per semester",
                    Icons.receipt,
                    const Color(0xFF2563EB),
                    "Includes semester ticket for public transport",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeeCard(
                    "Living Costs",
                    "€850 - €1,200",
                    "per month",
                    Icons.home,
                    const Color(0xFF9333EA),
                    "Rent, food, insurance, personal expenses",
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Blocked Account
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock, color: Color(0xFFF59E0B), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Blocked Account Required",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "€11,208 (2024) for visa - released monthly",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Health Insurance
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.health_and_safety, color: const Color(0xFF0D9488), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Health Insurance: ~€110/month (under 30) or ~€200/month (above 30)",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Scholarship Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFE0F2FE), const Color(0xFFE0E7FF)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard, color: Color(0xFF1E3A8A), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Scholarships available: DAAD, Deutschlandstipendium, Erasmus+",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeCard(String title, String amount, String period, IconData icon, Color color, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            period,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ================= ADDITIONAL NOTES INFO CARD =================
  Widget _buildAdditionalNotesCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.lightbulb, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Important Notes & Tips",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "What you should know before applying",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Key Points List
            _buildNoteItem(
              Icons.assignment_turned_in,
              "APS Certificate",
              "Mandatory for Indian, Chinese, Vietnamese students",
              const Color(0xFFDC2626),
            ),
            _buildNoteItem(
              Icons.translate,
              "Language Requirements",
              "German B2/C1 for German-taught, English B2/IELTS 6.5+ for English-taught",
              const Color(0xFF2563EB),
            ),
            _buildNoteItem(
              Icons.calendar_month,
              "Application Deadlines",
              "Winter: May-July • Summer: Nov-Jan",
              const Color(0xFFF97316),
            ),
            _buildNoteItem(
              Icons.grading,
              "uni-assist",
              "Many universities require application through uni-assist (VPD)",
              const Color(0xFF9333EA),
            ),
            _buildNoteItem(
              Icons.document_scanner,
              "Document Translation",
              "All documents must be translated to German by certified translators",
              const Color(0xFF059669),
            ),
            
            const SizedBox(height: 16),
            
            // Warning Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Color(0xFFEF4444), size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "⚠️ Beware of Fake Universities",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Only apply to state-recognized universities. Check Anabin database.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Application Strategy - FIXED: Removed strategy icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.assignment, color: Color(0xFF0284C7), size: 24), // FIXED: Changed strategy to assignment
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Application Strategy",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0369A1),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "• Apply to 3-5 universities\n• 1-2 dream, 1-2 match, 1-2 safe\n• Track deadlines carefully",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF075985),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Quick Checklist
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.checklist, color: Color(0xFF4F46E5), size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        "Quick Checklist",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3730A3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._buildChecklistItem("Bachelor's degree certificate", true),
                  ..._buildChecklistItem("Transcript of records", true),
                  ..._buildChecklistItem("Language certificate", true),
                  ..._buildChecklistItem("APS certificate", true),
                  ..._buildChecklistItem("Statement of Purpose", true),
                  ..._buildChecklistItem("Letters of Recommendation", true),
                  ..._buildChecklistItem("CV/Resume", true),
                  ..._buildChecklistItem("Passport copy", true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteItem(IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChecklistItem(String title, bool isRequired) {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isRequired ? const Color(0xFF10B981) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isRequired ? const Color(0xFF1F2937) : Colors.grey.shade500,
                  fontWeight: isRequired ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Required",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    ];
  }

  // ================= BUILD METHOD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Germany University Admission",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        // NO PDF BUTTON IN APPBAR
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // University Info Card
              _buildUniversityInfoCard(),
              
              // Course Details Info Card
              _buildCourseDetailsCard(),
              
              // Fees & Finance Info Card
              _buildFeesFinanceCard(),
              
              // Additional Notes Info Card
              _buildAdditionalNotesCard(),
              
              const SizedBox(height: 30),
              
              // ========== ONLY ONE PDF BUTTON AT BOTTOM ==========
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isGeneratingPDF ? null : _generatePDF,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isGeneratingPDF)
                            const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else
                            const Icon(Icons.picture_as_pdf, color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            _isGeneratingPDF ? "GENERATING PDF..." : "DOWNLOAD GUIDE PDF",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}