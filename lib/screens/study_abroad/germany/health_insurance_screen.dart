import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class HealthInsuranceScreen extends StatelessWidget {
  const HealthInsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Health Insurance - Germany",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section with Dark Overlay
            Container(
              height: 180,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage("assets/study_abroad/health.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.6),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.health_and_safety,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "German Health Insurance",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Complete guide for international students",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Mandatory Requirement Card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFDC2626).withOpacity(0.9),
                    const Color(0xFF991B1B),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC2626).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.gavel,
                      color: Color(0xFFDC2626),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Legal Requirement",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Mandatory for all residents. Required for visa, university enrollment, and residence permit.",
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.warning,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Without insurance → Visa Rejected",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Types of Insurance Section
            _buildSection(
              icon: Icons.category,
              title: "Insurance Types",
              content:
                  "Choose the right insurance based on your age, course, and duration of stay.",
              children: [
                const SizedBox(height: 15),
                // Public Insurance
                _insuranceTypeCard(
                  icon: Icons.people,
                  title: "Public Insurance (GKV)",
                  color: const Color(0xFF10B981),
                  features: [
                    "Students under 30 years",
                    "Degree program students",
                    "Fixed monthly premium",
                    "Full medical coverage",
                    "Includes long-term care",
                  ],
                  price: "€145/month",
                  isRecommended: true,
                ),
                const SizedBox(height: 12),
                // Private Insurance
                _insuranceTypeCard(
                  icon: Icons.privacy_tip,
                  title: "Private Insurance (PHI)",
                  color: const Color(0xFF3B82F6),
                  features: [
                    "Students aged 30+",
                    "Language course students",
                    "Variable premium",
                    "Additional benefits",
                    "Hard to switch back",
                  ],
                  price: "€130-190/month",
                ),
                const SizedBox(height: 12),
                // Travel Insurance
                _insuranceTypeCard(
                  icon: Icons.flight,
                  title: "Travel Insurance",
                  color: const Color(0xFFF59E0B),
                  features: [
                    "Short stays (max 90 days)",
                    "Visa application only",
                    "Emergency coverage",
                    "Not for long-term",
                    "Convert after arrival",
                  ],
                  price: "€40-100 total",
                  isWarning: true,
                ),
              ],
            ),

            // Cost Comparison for 2026
            _buildSection(
              icon: Icons.euro,
              title: "Cost Comparison 2026",
              content:
                  "Expected monthly premiums for different insurance types (estimated for 2026):",
              children: [
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF1F5F9),
                        const Color(0xFFE2E8F0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _costRow("Public Insurance (Under 30)", "€148 - €155"),
                      _divider(),
                      _costRow("Public Insurance (Over 30)", "€205 - €260"),
                      _divider(),
                      _costRow("Private Insurance (Basic)", "€135 - €195"),
                      _divider(),
                      _costRow("Private Insurance (Comprehensive)", "€180 - €280"),
                      _divider(),
                      _costRow("Travel Insurance (90 days)", "€45 - €110"),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 14,
                        color: Color(0xFF1D4ED8),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Prices increase 3-5% annually. Public insurance for under-30 students is most economical.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Insurance Providers Section
            _buildSection(
              icon: Icons.business,
              title: "Top Insurance Providers",
              content:
                  "Recommended companies for international students in Germany:",
              children: [
                const SizedBox(height: 15),
                _providerRow(
                  "TK - Techniker Krankenkasse",
                  "Largest public insurer, excellent English support",
                  const Color(0xFF0EA5E9),
                ),
                const SizedBox(height: 10),
                _providerRow(
                  "AOK - Allgemeine Ortskrankenkasse",
                  "Nationwide network, student-friendly services",
                  const Color(0xFF10B981),
                ),
                const SizedBox(height: 10),
                _providerRow(
                  "DAK-Gesundheit",
                  "Comprehensive coverage, digital health services",
                  const Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 10),
                _providerRow(
                  "Mawista",
                  "Specialized for international students",
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 10),
                _providerRow(
                  "Care Concept",
                  "Popular for language course students",
                  const Color(0xFFEC4899),
                ),
              ],
            ),

            // Visa Requirements Section
            _buildSection(
              icon: Icons.assignment,
              title: "Visa Documentation",
              content:
                  "Required documents for German student visa application:",
              children: [
                const SizedBox(height: 15),
                _documentItem("Insurance certificate from provider"),
                _documentItem("Coverage for entire study duration"),
                _documentItem("Minimum €30,000 medical coverage"),
                _documentItem("Hospitalization & emergency coverage"),
                _documentItem("Policy details in English/German"),
                _documentItem("Validity from date of entry"),
              ],
            ),

            const SizedBox(height: 24),

            // Download Button - SIMPLE STYLE like After Arrival
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 30),
              child: ElevatedButton.icon(
                onPressed: () => _generateAndSavePDF(context),
                icon: const Icon(Icons.picture_as_pdf, size: 20),
                label: const Text(
                  'DOWNLOAD COMPLETE GUIDE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    List<Widget>? children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF0369A1),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF64748B).withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
                if (children != null) ...children,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _insuranceTypeCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<String> features,
    required String price,
    bool isRecommended = false,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    if (isRecommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "RECOMMENDED",
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                    if (isWarning) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "TEMPORARY",
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF92400E),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Text(
                    "Approximate Cost: $price",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
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

  Widget _costRow(String item, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            item,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 1,
      color: const Color(0xFFCBD5E1),
    );
  }

  Widget _providerRow(String name, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.business,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PDF Generation Function
  Future<void> _generateAndSavePDF(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 12),
            Text("Generating PDF..."),
          ],
        ),
      ),
    );

    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final formattedDate = '${now.day} ${_getMonthName(now.month)} ${now.year}';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text(
                      'GERMAN HEALTH INSURANCE GUIDE',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Center(
                    child: pw.Text(
                      'For International Students - Complete Summary',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Center(
                    child: pw.Text(
                      'Generated on: $formattedDate',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                    ),
                  ),
                  
                  pw.SizedBox(height: 30),
                  
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.red50,
                      border: pw.Border.all(color: PdfColors.red),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '⚠ IMPORTANT LEGAL REQUIREMENT',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Health insurance is mandatory for all residents in Germany. Required for visa, university enrollment, and residence permit applications.',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  
                  pw.SizedBox(height: 25),
                  
                  pw.Text(
                    '1. INSURANCE TYPES (2026 Estimates)',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  
                  _buildPDFSection(
                    title: 'PUBLIC INSURANCE (GKV) - RECOMMENDED',
                    points: [
                      'Students under 30 years in degree programs',
                      'Monthly premium: €148-€155',
                      'Comprehensive medical coverage',
                      'Includes long-term care insurance',
                      'Easy to switch providers',
                      'Accepted by all universities',
                    ],
                  ),
                  
                  pw.SizedBox(height: 15),
                  
                  _buildPDFSection(
                    title: 'PRIVATE INSURANCE (PHI)',
                    points: [
                      'Students aged 30+ years',
                      'Language course students',
                      'Monthly premium: €135-€195',
                      'Additional benefits available',
                      'Difficult to switch back to public',
                    ],
                  ),
                  
                  pw.SizedBox(height: 15),
                  
                  _buildPDFSection(
                    title: 'TRAVEL INSURANCE - TEMPORARY',
                    points: [
                      'Short stays only (maximum 90 days)',
                      'For visa application purposes only',
                      'Cost: €45-€110 for 90 days',
                      'Must convert after arrival',
                      'Not valid for long-term studies',
                    ],
                  ),
                  
                  pw.SizedBox(height: 25),
                  
                  pw.Text(
                    '2. COST COMPARISON 2026',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  
                  _buildPDFCostRow('Public Insurance (Under 30)', '€148 - €155'),
                  _buildPDFCostRow('Public Insurance (Over 30)', '€205 - €260'),
                  _buildPDFCostRow('Private Insurance (Basic)', '€135 - €195'),
                  _buildPDFCostRow('Private Insurance (Comprehensive)', '€180 - €280'),
                  _buildPDFCostRow('Travel Insurance (90 days)', '€45 - €110'),
                  
                  pw.SizedBox(height: 25),
                  
                  pw.Text(
                    '3. TOP INSURANCE PROVIDERS',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  
                  pw.Text('• TK (Techniker Krankenkasse) - Largest public insurer, English support'),
                  pw.Text('• AOK - Nationwide network, student-friendly services'),
                  pw.Text('• DAK-Gesundheit - Comprehensive coverage, digital services'),
                  pw.Text('• Mawista - Specialized for international students'),
                  pw.Text('• Care Concept - Popular for language courses'),
                  
                  pw.SizedBox(height: 25),
                  
                  pw.Text(
                    '4. VISA DOCUMENT REQUIREMENTS',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  
                  _buildPDFChecklist('Insurance certificate from provider'),
                  _buildPDFChecklist('Coverage for entire study duration'),
                  _buildPDFChecklist('Minimum €30,000 medical coverage'),
                  _buildPDFChecklist('Hospitalization & emergency coverage'),
                  _buildPDFChecklist('Policy in English or German'),
                  _buildPDFChecklist('Validity from date of entry'),
                  
                  pw.SizedBox(height: 30),
                  
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Important Notes:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          '• Prices increase 3-5% annually',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                        pw.Text(
                          '• Public insurance is most economical for under-30 students',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                        pw.Text(
                          '• Verify current requirements with official sources',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                        pw.Text(
                          '• Keep insurance documents safe at all times',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                  
                  pw.SizedBox(height: 30),
                  
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'This document is for reference only.',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final bytes = await pdf.save();

final downloadDir = await getApplicationDocumentsDirectory();

final filePath =
    '${downloadDir.path}/Health_Insurance_Guide_${DateTime.now().millisecondsSinceEpoch}.pdf';

final file = File(filePath);

await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("✅ PDF Generated"),
          content: const Text("Your PDF has been saved successfully!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
            ElevatedButton(
              onPressed: () async {
                await OpenFile.open(filePath);
                Navigator.pop(context);
              },
              child: const Text("Open PDF"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Could not generate PDF: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }
  
  pw.Widget _buildPDFSection({required String title, required List<String> points}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          ...points.map((point) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• ', style: const pw.TextStyle(fontSize: 10)),
                    pw.Expanded(
                      child: pw.Text(
                        point,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
  
  pw.Widget _buildPDFCostRow(String item, String price) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              item,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Text(
            price,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  pw.Widget _buildPDFChecklist(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('✓ ', style: pw.TextStyle(fontSize: 10, color: PdfColors.green)),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}