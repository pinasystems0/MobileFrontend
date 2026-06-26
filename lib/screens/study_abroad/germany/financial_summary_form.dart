import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class FinancialSummaryForm extends StatefulWidget {
  const FinancialSummaryForm({super.key});

  @override
  State<FinancialSummaryForm> createState() => _FinancialSummaryFormState();
}

class _FinancialSummaryFormState extends State<FinancialSummaryForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ==================== FINANCIAL SUPPORT DECLARATION TEMPLATE FIELDS ====================
  
  // Personal Information (from template)
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passportNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  // Course & University Details
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _universityNameController = TextEditingController();
  
  // Financial Details (as per template)
  final TextEditingController _blockedAmountController = TextEditingController();
  final TextEditingController _sponsorNameController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _additionalSavingsController = TextEditingController();
  
  // Living Cost (pre-filled as per Germany requirements)
  final TextEditingController _yearlyCostController = TextEditingController(text: '11904');

  @override
  void dispose() {
    _fullNameController.dispose();
    _passportNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _courseNameController.dispose();
    _universityNameController.dispose();
    _blockedAmountController.dispose();
    _sponsorNameController.dispose();
    _relationshipController.dispose();
    _additionalSavingsController.dispose();
    _yearlyCostController.dispose();
    super.dispose();
  }

  // ==================== FINANCIAL SUPPORT DECLARATION TEMPLATE ====================
  String _generateLetterContent() {
    final now = DateTime.now();
    final formattedDate = '${now.day} ${_getMonthName(now.month)} ${now.year}';
    
    return '''
FINANCIAL SUPPORT DECLARATION LETTER
(For Study in Germany)

Date: $formattedDate

To,
Visa Officer / Admissions Office
Germany

Subject: Proof of Financial Resources for Study in Germany

Respected Sir/Madam,

I, ${_fullNameController.text} (Full Name), passport number ${_passportNumberController.text},
have secured admission to pursue ${_courseNameController.text} (Course/Program Name)
at ${_universityNameController.text} (University Name), Germany.

I confirm that I have sufficient financial resources to cover all my expenses
during my stay in Germany, including tuition fees, accommodation, health
insurance, food, transportation, and other living costs.

The financial arrangements are as follows:

• Blocked Account Amount: € ${_blockedAmountController.text.isNotEmpty ? _blockedAmountController.text : '__________________'}
• Sponsor Name (if any): ${_sponsorNameController.text.isNotEmpty ? _sponsorNameController.text : '__________________'}
• Relationship with Sponsor: ${_relationshipController.text.isNotEmpty ? _relationshipController.text : '__________________'}
• Additional Savings/Support (if any): ${_additionalSavingsController.text.isNotEmpty ? _additionalSavingsController.text : '__________________'}

I understand that the estimated minimum living expense requirement in Germany
is approximately €${_yearlyCostController.text} per year, and I have arranged funds accordingly.

I assure you that all my educational and living expenses will be properly
managed without any financial burden to the German state.

Kindly consider this as my financial declaration.

Thanking you.

Sincerely,

Signature: __________________
Name: ${_fullNameController.text}
Phone: ${_phoneController.text.isNotEmpty ? _phoneController.text : '__________________'}
Email: ${_emailController.text.isNotEmpty ? _emailController.text : '__________________'}
Address: ${_addressController.text.isNotEmpty ? _addressController.text : '__________________'}
''';
  }

  Future<void> _generateLetter() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await SessionService.getAuthToken();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // ============= GENERATE LETTER =============
      final generatedLetter = _generateLetterContent();

      // ============= SAVE TO BACKEND =============
      final response = await http.post(
        Uri.parse('${ApiConstants.authUrl}/api/germany/financial-summary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'functionality': 'germany_diploma_12',
          'fullName': _fullNameController.text,
          'passportNumber': _passportNumberController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'courseName': _courseNameController.text,
          'universityName': _universityNameController.text,
          'blockedAmount': _blockedAmountController.text,
          'sponsorName': _sponsorNameController.text,
          'relationship': _relationshipController.text,
          'additionalSavings': _additionalSavingsController.text,
          'yearlyCost': _yearlyCostController.text,
          'generatedLetter': generatedLetter,
        }),
      );

      if (response.statusCode == 402) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Insufficient Balance! Required: ${data['requiredCredits']} | Current: ${data['currentBalance']}"
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (response.statusCode == 201) {
        await _generatePDF(generatedLetter);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Financial letter generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to save financial letter');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePDF(String letterContent) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Paragraph(
            text: letterContent,
            style: const pw.TextStyle(
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 44, 136, 212),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.account_balance, size: 40, color: Colors.white),
                            const SizedBox(height: 8),
                            const Text(
                              'FINANCIAL SUPPORT DECLARATION',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'For Germany Student Visa – Proof of Financial Resources',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ============= FORM SECTIONS =============
                      
                      // 1. PERSONAL INFORMATION (as per template)
                      _buildSectionHeader('1. Personal Information', Icons.person, const Color(0xFF0D9488)),
                      _buildTextField('Full Name *', _fullNameController, 
                        required: true, hint: 'As per passport'),
                      _buildTextField('Passport Number *', _passportNumberController, 
                        required: true, hint: 'e.g., P12345678'),
                      _buildTextField('Phone *', _phoneController, 
                        required: true, hint: 'e.g., +91 98765 43210', 
                        keyboardType: TextInputType.phone),
                      _buildTextField('Email *', _emailController, 
                        required: true, hint: 'e.g., name@email.com',
                        keyboardType: TextInputType.emailAddress),
                      _buildTextField('Address *', _addressController, 
                        required: true, hint: 'Your complete address', maxLines: 2),
                      const SizedBox(height: 16),

                      // 2. COURSE & UNIVERSITY DETAILS
                      _buildSectionHeader('2. Course & University Details', Icons.school, const Color(0xFF0D9488)),
                      _buildTextField('Course/Program Name *', _courseNameController, 
                        required: true, hint: 'e.g., M.Sc. Computer Science'),
                      _buildTextField('University Name *', _universityNameController, 
                        required: true, hint: 'e.g., Technical University of Munich'),
                      const SizedBox(height: 16),

                      // 3. FINANCIAL ARRANGEMENTS (as per template)
                      _buildSectionHeader('3. Financial Arrangements', Icons.euro, const Color(0xFF0D9488)),
                      
                      _buildNumberField('Blocked Account Amount (€)', _blockedAmountController,
                        hint: 'e.g., 11904', prefix: '€ '),
                      _buildTextField('Sponsor Name (if any)', _sponsorNameController,
                        hint: 'Leave blank if not applicable'),
                      _buildTextField('Relationship with Sponsor', _relationshipController,
                        hint: 'e.g., Father, Mother, etc.'),
                      _buildNumberField('Additional Savings/Support (€)', _additionalSavingsController,
                        hint: 'If any', prefix: '€ '),
                      
                      const SizedBox(height: 24),

                      // Generate Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _generateLetter,
                          icon: const Icon(Icons.picture_as_pdf, size: 20),
                          label: const Text(
                            'GENERATE FINANCIAL DECLARATION',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Generating your letter...', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    TextEditingController controller, {
    bool required = false,
    String? hint,
    String prefix = '',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
          prefixText: prefix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              }
            : null,
      ),
    );
  }
}
