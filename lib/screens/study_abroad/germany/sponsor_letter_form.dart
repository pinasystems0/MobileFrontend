import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SponsorLetterForm extends StatefulWidget {
  const SponsorLetterForm({super.key});

  @override
  State<SponsorLetterForm> createState() => _SponsorLetterFormState();
}

class _SponsorLetterFormState extends State<SponsorLetterForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ==================== SPONSORSHIP LETTER TEMPLATE FIELDS ====================
  
  // Student Details
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _universityNameController = TextEditingController();
  
  // Sponsor Details (as per template)
  final TextEditingController _sponsorFullNameController = TextEditingController();
  final TextEditingController _sponsorPassportController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  
  // Financial Details (as per template)
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _monthlyIncomeController = TextEditingController();
  final TextEditingController _bankBalanceController = TextEditingController();
  final TextEditingController _blockedFundsController = TextEditingController();
  
  // Contact Details (as per template)
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  // Living Cost (pre-filled)
  final TextEditingController _yearlyCostController = TextEditingController(text: '11904');

  @override
  void dispose() {
    _studentNameController.dispose();
    _courseNameController.dispose();
    _universityNameController.dispose();
    _sponsorFullNameController.dispose();
    _sponsorPassportController.dispose();
    _relationshipController.dispose();
    _occupationController.dispose();
    _monthlyIncomeController.dispose();
    _bankBalanceController.dispose();
    _blockedFundsController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _yearlyCostController.dispose();
    super.dispose();
  }

  // ==================== SPONSORSHIP LETTER TEMPLATE ====================
  String _generateLetterContent() {
    final now = DateTime.now();
    final formattedDate = '${now.day} ${_getMonthName(now.month)} ${now.year}';
    
    return '''
SPONSORSHIP LETTER
(Financial Support for Study in Germany)

Date: $formattedDate

To,
Visa Officer / Admissions Office
Germany

Subject: Financial Sponsorship for Higher Studies in Germany

Respected Sir/Madam,

I, ${_sponsorFullNameController.text} (Sponsor Full Name), holding passport number
${_sponsorPassportController.text.isNotEmpty ? _sponsorPassportController.text : '__________________________'}, hereby confirm that I am the ${_relationshipController.text}
(Relationship – Father/Mother/Guardian/Relative) of ${_studentNameController.text}
(Student Full Name).

I fully agree to sponsor and financially support the student's education and
living expenses during their stay in Germany for the purpose of pursuing
${_courseNameController.text} (Course/Program Name) at
${_universityNameController.text} (University Name).

I will bear all expenses including:

• Tuition fees (if applicable)
• Accommodation
• Food and daily expenses
• Health insurance
• Travel and miscellaneous costs

Financial Details:

• Sponsor Occupation: ${_occupationController.text.isNotEmpty ? _occupationController.text : '__________________'}
• Monthly/Annual Income: ${_monthlyIncomeController.text.isNotEmpty ? _monthlyIncomeController.text : '__________________'}
• Bank Balance / Savings: ${_bankBalanceController.text.isNotEmpty ? _bankBalanceController.text : '__________________'}
• Blocked Account / Funds Provided: ${_blockedFundsController.text.isNotEmpty ? _blockedFundsController.text : '__________________'}

I confirm that sufficient funds are available to cover the required minimum
living expenses in Germany (approx. €${_yearlyCostController.text} per year or as per visa guidelines).

I assure that the student will not require any public financial assistance
during their stay in Germany.

Kindly consider this letter as my official financial sponsorship declaration.

Thank you.

Sincerely,

Sponsor Signature: __________________
Sponsor Name: ${_sponsorFullNameController.text}
Relationship: ${_relationshipController.text}
Phone Number: ${_phoneController.text.isNotEmpty ? _phoneController.text : '__________________'}
Email Address: ${_emailController.text.isNotEmpty ? _emailController.text : '__________________'}
Residential Address: ${_addressController.text.isNotEmpty ? _addressController.text : '__________________'}
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // ============= GENERATE LETTER =============
      final generatedLetter = _generateLetterContent();

      // ============= SAVE TO BACKEND =============
      final response = await http.post(
        Uri.parse('${ApiConstants.authUrl}/api/germany/sponsorship'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'studentName': _studentNameController.text,
          'courseName': _courseNameController.text,
          'universityName': _universityNameController.text,
          'sponsorFullName': _sponsorFullNameController.text,
          'sponsorPassport': _sponsorPassportController.text,
          'relationship': _relationshipController.text,
          'occupation': _occupationController.text,
          'monthlyIncome': _monthlyIncomeController.text,
          'bankBalance': _bankBalanceController.text,
          'blockedFunds': _blockedFundsController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'yearlyCost': _yearlyCostController.text,
          'functionality': 'germany_ug',
          'generatedLetter': generatedLetter,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 402) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
"Insufficient Balance! Required: ${data['requiredCredits']} | Current: ${data['currentBalance']}"
            ),
            backgroundColor: Colors.red,
          ),
        );

        setState(() => _isLoading = false);
        return;
      }

      if (response.statusCode == 201) {
        await _generatePDF(generatedLetter);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sponsorship letter generated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to save sponsorship letter');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        backgroundColor: const Color(0xFF1E40AF),
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
                          color: const Color(0xFF1E40AF),
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
                            const Icon(Icons.volunteer_activism, size: 40, color: Colors.white),
                            const SizedBox(height: 8),
                            const Text(
                              'SPONSORSHIP LETTER',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Financial Support Declaration for Germany Visa',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ============= FORM SECTIONS =============
                      
                      // 1. STUDENT DETAILS
                      _buildSectionHeader('1. Student Details', Icons.person, const Color(0xFF1E40AF)),
                      _buildTextField('Student Full Name *', _studentNameController, 
                        required: true, hint: 'As per passport'),
                      _buildTextField('Course/Program Name *', _courseNameController, 
                        required: true, hint: 'e.g., M.Sc. Computer Science'),
                      _buildTextField('University Name *', _universityNameController, 
                        required: true, hint: 'e.g., Technical University of Munich'),
                      const SizedBox(height: 16),

                      // 2. SPONSOR DETAILS
                      _buildSectionHeader('2. Sponsor Details', Icons.family_restroom, const Color(0xFF1E40AF)),
                      _buildTextField('Sponsor Full Name *', _sponsorFullNameController, 
                        required: true, hint: 'As per passport'),
                      _buildTextField('Sponsor Passport Number', _sponsorPassportController,
                        hint: 'If applicable'),
                      _buildTextField('Relationship with Student *', _relationshipController, 
                        required: true, hint: 'e.g., Father, Mother, Guardian'),
                      const SizedBox(height: 16),

                      // 3. FINANCIAL DETAILS
                      _buildSectionHeader('3. Financial Details', Icons.account_balance, const Color(0xFF1E40AF)),
                      
                      _buildTextField('Sponsor Occupation', _occupationController,
                        hint: 'e.g., Business, Engineer, Doctor'),
                      _buildNumberField('Monthly/Annual Income', _monthlyIncomeController,
                        hint: 'e.g., 50000 per year', prefix: '€ '),
                      _buildNumberField('Bank Balance / Savings', _bankBalanceController,
                        hint: 'Total savings available', prefix: '€ '),
                      _buildNumberField('Blocked Account / Funds Provided', _blockedFundsController,
                        hint: 'Amount in blocked account', prefix: '€ '),
                      const SizedBox(height: 16),

                      // 4. CONTACT DETAILS
                      _buildSectionHeader('4. Contact Details', Icons.contact_mail, const Color(0xFF1E40AF)),
                      _buildTextField('Phone Number *', _phoneController, 
                        required: true, hint: 'e.g., +91 98765 43210',
                        keyboardType: TextInputType.phone),
                      _buildTextField('Email Address *', _emailController, 
                        required: true, hint: 'e.g., name@email.com',
                        keyboardType: TextInputType.emailAddress),
                      _buildTextField('Residential Address *', _addressController, 
                        required: true, hint: 'Complete address', maxLines: 2),
                      const SizedBox(height: 24),

                      // Generate Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _generateLetter,
                          icon: const Icon(Icons.picture_as_pdf, size: 20),
                          label: const Text(
                            'GENERATE SPONSORSHIP LETTER',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E40AF),
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
