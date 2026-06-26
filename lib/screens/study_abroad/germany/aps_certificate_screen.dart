import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ApsCertificateScreen extends StatelessWidget {
  const ApsCertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F5FA),

      appBar: AppBar(
        title: const Text("APS Certificate Guide"),
        backgroundColor: const Color(0xff4F46E5),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _header(),

          const SizedBox(height: 18),

          _section(
            icon: Icons.info_outline,
            color: Colors.indigo,
            title: "What is APS?",
            text:
                "APS (Akademische Prüfstelle) verifies Indian academic documents and confirms that your degrees are genuine and accepted by German universities.",
          ),

          _section(
            icon: Icons.verified,
            color: Colors.green,
            title: "Why is APS Mandatory?",
            text:
                "• Required before university admission\n"
                "• Mandatory for German student visa\n"
                "• Prevents fake documents\n"
                "• Confirms education authenticity",
          ),

          _section(
            icon: Icons.public,
            color: Colors.orange,
            title: "Who Needs APS?",
            text:
                "Students from India, China, Vietnam, Mongolia.\n\n"
                "Exceptions: DAAD scholars, Erasmus programs, German Abitur holders, some PhD candidates.",
          ),

          _section(
            icon: Icons.timeline,
            color: Colors.purple,
            title: "Step-by-Step Process",
            text:
                "1. Register on APS portal\n"
                "2. Upload documents\n"
                "3. Pay fee (~₹18,000)\n"
                "4. Verification\n"
                "5. Interview (if required)\n"
                "6. Receive certificate via email",
          ),

          _section(
            icon: Icons.timer,
            color: Colors.teal,
            title: "Timeline & Validity",
            text:
                "Processing: 3–6 weeks\n"
                "Apply 3–4 months early\n"
                "Validity: 3 years\n"
                "Digital certificate",
          ),

          _documentsSection(),

          _section(
            icon: Icons.flight_takeoff,
            color: Colors.redAccent,
            title: "Visa Important",
            text:
                "Without APS certificate you CANNOT apply for a German student visa.",
          ),

          const SizedBox(height: 28),

          _pdfButton(context),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xff667eea), Color(0xff764ba2)],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("APS Certificate (Germany)",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text("Complete step-by-step guide for Indian students",
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // ================= SECTION CARD =================

  Widget _section({
    required IconData icon,
    required String title,
    required String text,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black.withOpacity(0.05),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text("$title\n\n$text")),
        ],
      ),
    );
  }

  // ================= DOCUMENTS =================

  Widget _documentsSection() {
    return _section(
      icon: Icons.folder_copy,
      color: Colors.deepOrange,
      title: "Documents Required",
      text:
          "UG:\n• Passport\n• 10th\n• 12th\n\n"
          "PG:\n• Bachelor degree\n• Semester marksheets\n\n"
          "Common:\n• APS form\n• Fee receipt\n• Photos\n• Language certificate",
    );
  }

  // ================= PDF BUTTON =================

  Widget _pdfButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.picture_as_pdf),
      label: const Text("Download Complete Guide PDF"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff4F46E5),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: () async {

        final pdf = pw.Document();

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (_) => [

              _pdfTitle("APS Certificate Guide (Germany)"),

              _pdfSection("What is APS?",
                  "APS verifies Indian academic documents and confirms authenticity for German universities."),

              _pdfBullets("Why Mandatory", [
                "University admission required",
                "Student visa required",
                "Prevents fraud",
                "Authenticity check"
              ]),

              _pdfSection("Who Needs APS",
                  "Students from India, China, Vietnam, Mongolia"),

              _pdfBullets("Process Steps", [
                "Register",
                "Upload documents",
                "Pay fee",
                "Verification",
                "Receive certificate"
              ]),

              _pdfBullets("Timeline & Validity", [
                "3–6 weeks processing",
                "Apply early",
                "Valid for 3 years"
              ]),

              _pdfBullets("Documents Required", [
                "Passport",
                "Marksheets",
                "Degree",
                "Receipt",
                "Photos",
                "Language certificate"
              ]),

              _pdfSection("Visa Note",
                  "APS certificate is mandatory before visa application."),
            ],
          ),
        );

        Uint8List bytes = await pdf.save();

        await Printing.layoutPdf(onLayout: (_) => bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PDF downloaded successfully ✅")),
        );
      },
    );
  }

  // ================= PDF HELPERS =================

  pw.Widget _pdfTitle(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 20),
        child: pw.Text(text,
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
      );

  pw.Widget _pdfSection(String title, String body) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 16),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title,
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text(body),
          ],
        ),
      );

  pw.Widget _pdfBullets(String title, List<String> items) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 16),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title,
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ...items.map((e) => pw.Bullet(text: e))
          ],
        ),
      );
}
