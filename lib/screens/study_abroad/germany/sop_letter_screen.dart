import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SOPLetterScreen extends StatefulWidget {
  const SOPLetterScreen({Key? key}) : super(key: key);

  @override
  State<SOPLetterScreen> createState() => _SOPLetterScreenState();
}

class _SOPLetterScreenState extends State<SOPLetterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ==================== UNIVERSAL SOP TEMPLATE FIELDS ====================
  
  // Personal Information
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _applicationIdController = TextEditingController();
  
  // Program & University
  final TextEditingController _programNameController = TextEditingController();
  final TextEditingController _universityNameController = TextEditingController();
  
  // Academic Background
  final TextEditingController _previousQualificationController = TextEditingController();
  final TextEditingController _specificAreaController = TextEditingController(); // Specific Academic/Research/Professional Area
  final TextEditingController _relevantSubject1Controller = TextEditingController();
  final TextEditingController _relevantSubject2Controller = TextEditingController();
  final TextEditingController _relevantSubject3Controller = TextEditingController();
  final TextEditingController _projectTitleController = TextEditingController();
  final TextEditingController _methodConceptController = TextEditingController(); // Method/Technology/Concept
  
  // Professional Experience
  final TextEditingController _internshipTrainingController = TextEditingController(); // Internship/Professional Experience/Research Work/Training
  final TextEditingController _keyResponsibilitiesController = TextEditingController();
  final TextEditingController _technicalSkillSoftwareController = TextEditingController(); // Technical Skill/Software/Methodology
  
  // Course Modules & Focus
  final TextEditingController _curriculumFocusController = TextEditingController(); // Research/Innovation/Practical Application/Industry Integration
  final TextEditingController _module1Controller = TextEditingController();
  final TextEditingController _module2Controller = TextEditingController();
  final TextEditingController _opportunityController = TextEditingController(); // Research Projects/Laboratory Work/Industry Training
  
  // Why Germany - Field Name
  final TextEditingController _fieldNameController = TextEditingController();
  
  // Career Goals
  final TextEditingController _specificAreaFocusController = TextEditingController(); // Specific Area of Focus
  final TextEditingController _technicalResearchSkillController = TextEditingController(); // Technical/Research/Professional Skill
  final TextEditingController _longTermAspirationController = TextEditingController(); // Industry/Research/Academia/Entrepreneurship
  
  // Skills
  final TextEditingController _skill1Controller = TextEditingController();
  final TextEditingController _skill2Controller = TextEditingController();
  final TextEditingController _skill3Controller = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _applicationIdController.dispose();
    _programNameController.dispose();
    _universityNameController.dispose();
    _previousQualificationController.dispose();
    _specificAreaController.dispose();
    _relevantSubject1Controller.dispose();
    _relevantSubject2Controller.dispose();
    _relevantSubject3Controller.dispose();
    _projectTitleController.dispose();
    _methodConceptController.dispose();
    _internshipTrainingController.dispose();
    _keyResponsibilitiesController.dispose();
    _technicalSkillSoftwareController.dispose();
    _curriculumFocusController.dispose();
    _module1Controller.dispose();
    _module2Controller.dispose();
    _opportunityController.dispose();
    _fieldNameController.dispose();
    _specificAreaFocusController.dispose();
    _technicalResearchSkillController.dispose();
    _longTermAspirationController.dispose();
    _skill1Controller.dispose();
    _skill2Controller.dispose();
    _skill3Controller.dispose();
    super.dispose();
  }

  // ==================== UNIVERSAL SOP TEMPLATE (HARDCODED) ====================
  String _generateSOPContent() {
    return '''
Subject: Application for ${_programNameController.text} at ${_universityNameController.text}

Dear Admissions Committee,

I am writing to express my sincere interest in the ${_programNameController.text} at ${_universityNameController.text}. With an academic background in ${_previousQualificationController.text}, I have developed a strong interest in ${_specificAreaController.text}, which has motivated me to pursue further studies in this discipline.

Throughout my academic journey, I have built a solid foundation in ${_relevantSubject1Controller.text}, ${_relevantSubject2Controller.text.isNotEmpty ? _relevantSubject2Controller.text : 'and'} ${_relevantSubject3Controller.text.isNotEmpty ? _relevantSubject3Controller.text : _relevantSubject2Controller.text.isNotEmpty ? 'related subjects' : 'other relevant subjects'}. My academic training has strengthened my analytical thinking, research aptitude, and problem-solving abilities. I have engaged in projects such as ${_projectTitleController.text.isNotEmpty ? _projectTitleController.text : 'academic projects'}, where I applied concepts of ${_methodConceptController.text.isNotEmpty ? _methodConceptController.text : 'theoretical and practical approaches'} to address practical challenges. These experiences enhanced both my theoretical understanding and practical competence.

In addition to academics, I have gained exposure through ${_internshipTrainingController.text.isNotEmpty ? _internshipTrainingController.text : 'professional training and internships'}, where I was involved in ${_keyResponsibilitiesController.text.isNotEmpty ? _keyResponsibilitiesController.text : 'key technical and collaborative tasks'}. This experience enabled me to develop skills in ${_technicalSkillSoftwareController.text.isNotEmpty ? _technicalSkillSoftwareController.text : 'modern tools and technologies'} and strengthened my ability to work independently as well as collaboratively in structured environments.

The ${_programNameController.text} at ${_universityNameController.text} particularly attracts me due to its comprehensive curriculum and focus on ${_curriculumFocusController.text.isNotEmpty ? _curriculumFocusController.text : 'research and innovation'}. Modules such as ${_module1Controller.text} and ${_module2Controller.text.isNotEmpty ? _module2Controller.text : 'advanced specialized courses'}, along with the opportunity to engage in ${_opportunityController.text.isNotEmpty ? _opportunityController.text : 'research projects and laboratory work'}, align closely with my academic interests and long-term objectives. The academic environment and research-oriented approach of your institution make it an ideal place for intellectual and professional growth.

Germany's globally recognized education system, emphasis on innovation, and strong connection between academia and industry provide an excellent platform for advanced learning. The structured yet practical orientation of higher education in Germany aligns with my aspiration to gain in-depth knowledge along with applied expertise in ${_fieldNameController.text.isNotEmpty ? _fieldNameController.text : 'my chosen field'}.

In the short term, I aim to deepen my knowledge in ${_specificAreaFocusController.text.isNotEmpty ? _specificAreaFocusController.text : 'specialized areas of my field'} and refine my competencies in ${_technicalResearchSkillController.text.isNotEmpty ? _technicalResearchSkillController.text : 'advanced technical and research skills'}. In the long term, I aspire to contribute meaningfully to ${_longTermAspirationController.text.isNotEmpty ? _longTermAspirationController.text : 'research and development'} by applying advanced knowledge and innovative thinking in the field of ${_fieldNameController.text.isNotEmpty ? _fieldNameController.text : 'my discipline'}.

I consider myself a disciplined, adaptable, and motivated individual with strong skills in ${_skill1Controller.text}, ${_skill2Controller.text}, and ${_skill3Controller.text.isNotEmpty ? _skill3Controller.text : 'continuous learning'}. I am confident that my academic preparation, professional exposure, and determination will enable me to contribute positively to the academic community at ${_universityNameController.text}.

I sincerely look forward to the opportunity to pursue my studies at your esteemed institution and further develop my academic and professional capabilities.

Thank you for considering my application.

Yours sincerely,
${_fullNameController.text}
${_applicationIdController.text.isNotEmpty ? _applicationIdController.text : ''}
${_emailController.text} | ${_phoneController.text}
''';
  }

  Future<void> _generateSOP() async {
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

      // ============= GENERATE SOP DIRECTLY =============
      final generatedSOP = _generateSOPContent();

      // ============= SAVE TO BACKEND =============
      final response = await http.post(
        Uri.parse('${ApiConstants.authUrl}/api/germany/save-sop'), // New endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'functionality': 'germany_pg',
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'applicationId': _applicationIdController.text,
          'programName': _programNameController.text,
          'universityName': _universityNameController.text,
          'previousQualification': _previousQualificationController.text,
          'specificArea': _specificAreaController.text,
          'relevantSubject1': _relevantSubject1Controller.text,
          'relevantSubject2': _relevantSubject2Controller.text,
          'relevantSubject3': _relevantSubject3Controller.text,
          'projectTitle': _projectTitleController.text,
          'methodConcept': _methodConceptController.text,
          'internshipTraining': _internshipTrainingController.text,
          'keyResponsibilities': _keyResponsibilitiesController.text,
          'technicalSkillSoftware': _technicalSkillSoftwareController.text,
          'curriculumFocus': _curriculumFocusController.text,
          'module1': _module1Controller.text,
          'module2': _module2Controller.text,
          'opportunity': _opportunityController.text,
          'fieldName': _fieldNameController.text,
          'specificAreaFocus': _specificAreaFocusController.text,
          'technicalResearchSkill': _technicalResearchSkillController.text,
          'longTermAspiration': _longTermAspirationController.text,
          'skill1': _skill1Controller.text,
          'skill2': _skill2Controller.text,
          'skill3': _skill3Controller.text,
          'generatedSOP': generatedSOP,
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
        await _generatePDF(generatedSOP);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOP generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to save SOP');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePDF(String sopContent) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Paragraph(
            text: sopContent,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Universal SOP Generator'),
        backgroundColor: const Color(0xFF1E3A8A),
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
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.description, size: 40, color: Colors.white),
                            const SizedBox(height: 8),
                            const Text(
                              'UNIVERSAL SOP / MOTIVATION LETTER',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Bachelor | Master | PhD | Diploma – All Levels Compatible',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ============= FORM SECTIONS =============
                      
                      // 1. PERSONAL INFORMATION
                      _buildSectionHeader('1. Personal Information', Icons.person, const Color(0xFF2563EB)),
                      _buildTextField('Full Name *', _fullNameController, required: true),
                      _buildTextField('Email *', _emailController, keyboardType: TextInputType.emailAddress, required: true),
                      _buildTextField('Phone *', _phoneController, keyboardType: TextInputType.phone, required: true),
                      _buildTextField('Application ID (if any)', _applicationIdController),
                      const SizedBox(height: 16),

                      // 2. PROGRAM & UNIVERSITY
                      _buildSectionHeader('2. Program & University', Icons.school, const Color(0xFF059669)),
                      _buildTextField('Program Name *', _programNameController, 
                        required: true, hint: 'e.g., M.Sc. Computer Science'),
                      _buildTextField('University Name *', _universityNameController, 
                        required: true, hint: 'e.g., Technical University of Munich'),
                      const SizedBox(height: 16),

                      // 3. ACADEMIC BACKGROUND
                      _buildSectionHeader('3. Academic Background', Icons.auto_stories, const Color(0xFF7C3AED)),
                      _buildTextField('Previous Qualification *', _previousQualificationController, 
                        required: true, hint: 'e.g., B.Tech in Computer Science'),
                      _buildTextField('Specific Academic/Research Area *', _specificAreaController, 
                        required: true, hint: 'e.g., Artificial Intelligence, Renewable Energy'),
                      _buildTextField('Relevant Subject 1 *', _relevantSubject1Controller, 
                        required: true, hint: 'e.g., Data Structures'),
                      _buildTextField('Relevant Subject 2', _relevantSubject2Controller, 
                        hint: 'e.g., Algorithms'),
                      _buildTextField('Relevant Subject 3', _relevantSubject3Controller, 
                        hint: 'e.g., Database Systems'),
                      _buildTextField('Project / Thesis Title', _projectTitleController,
                        hint: 'e.g., AI-based Chatbot'),
                      _buildTextField('Method/Technology/Concept Used', _methodConceptController,
                        hint: 'e.g., Machine Learning, Python'),
                      const SizedBox(height: 16),

                      // 4. PROFESSIONAL EXPERIENCE
                      _buildSectionHeader('4. Professional Experience', Icons.work, const Color(0xFFEA580C)),
                      _buildTextField('Internship/Work/Training Details', _internshipTrainingController,
                        hint: 'e.g., Software Engineer Intern at Google'),
                      _buildTextField('Key Responsibilities', _keyResponsibilitiesController,
                        maxLines: 2, hint: 'What did you work on?'),
                      _buildTextField('Technical Skills/Software/Methodology', _technicalSkillSoftwareController,
                        hint: 'e.g., Agile, TensorFlow, Flutter'),
                      const SizedBox(height: 16),

                      // 5. COURSE DETAILS
                      _buildSectionHeader('5. Course Curriculum Interest', Icons.class_, const Color(0xFFDC2626)),
                      _buildTextField('Curriculum Focus *', _curriculumFocusController,
                        required: true, hint: 'e.g., Research, Innovation, Industry Integration'),
                      _buildTextField('Module 1 *', _module1Controller,
                        required: true, hint: 'Module from your program'),
                      _buildTextField('Module 2', _module2Controller,
                        hint: 'Another module that interests you'),
                      _buildTextField('Opportunity Type', _opportunityController,
                        hint: 'e.g., Research Projects, Laboratory Work, Industry Training'),
                      const SizedBox(height: 16),

                      // 6. WHY GERMANY
                      _buildSectionHeader('6. Why Germany?', Icons.public, const Color(0xFF4F46E5)),
                      _buildTextField('Your Field of Study *', _fieldNameController,
                        required: true, hint: 'e.g., Artificial Intelligence, Renewable Energy'),
                      const SizedBox(height: 16),

                      // 7. CAREER GOALS
                      _buildSectionHeader('7. Career Goals', Icons.flag, const Color(0xFFF59E0B)),
                      _buildTextField('Specific Area of Focus *', _specificAreaFocusController,
                        required: true, hint: 'What specialization?'),
                      _buildTextField('Technical/Research Skill *', _technicalResearchSkillController,
                        required: true, hint: 'e.g., Advanced Machine Learning'),
                      _buildTextField('Long-term Aspiration *', _longTermAspirationController,
                        required: true, hint: 'e.g., R&D, Academia, Entrepreneurship'),
                      const SizedBox(height: 16),

                      // 8. SKILLS
                      _buildSectionHeader('8. Your Key Skills', Icons.star, const Color(0xFF10B981)),
                      _buildTextField('Skill 1 *', _skill1Controller,
                        required: true, hint: 'e.g., Analytical Thinking'),
                      _buildTextField('Skill 2 *', _skill2Controller,
                        required: true, hint: 'e.g., Team Collaboration'),
                      _buildTextField('Skill 3', _skill3Controller,
                        hint: 'e.g., Time Management'),
                      const SizedBox(height: 24),

                      // Generate Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _generateSOP,
                          icon: const Icon(Icons.picture_as_pdf, size: 20),
                          label: const Text(
                            'GENERATE SOP / MOTIVATION LETTER',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
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
                        Text('Generating your SOP...', style: TextStyle(fontSize: 16)),
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
}
