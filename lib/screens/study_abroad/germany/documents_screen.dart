import 'package:flutter/material.dart';
import 'package:pina/screens/study_abroad/germany/sop_letter_screen.dart';

class GermanyDocumentsScreen extends StatelessWidget {
  const GermanyDocumentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Required Documents Guide'),
        backgroundColor: const Color(0xFF006994),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header - NORMAL SIZE
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF006994), Color(0xFF0891B2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF006994).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.description, size: 40, color: Colors.white),
                const SizedBox(height: 8),
                const Text(
                  'Required Documents Guide 🇩🇪',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Complete checklist for Germany study visa',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Introduction
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF0891B2).withOpacity(0.3)),
            ),
            child: const Text(
              'Below is the complete list of documents generally required for studying in Germany. Read the information carefully and prepare your documents before applying.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          const SizedBox(height: 16),

          // 1. Academic Documents
          _buildDocumentSection(
            title: 'Academic & Admission Documents',
            subtitle: 'Required for university admission',
            icon: Icons.school_rounded,
            color: const Color(0xFF2563EB),
            number: '1',
            subsections: [
              _DocumentSubsection(
                title: '📌 Core Academic Documents',
                items: [
                  '10th grade / Secondary school certificate (if required)',
                  '12th / Intermediate certificate (for Bachelor\'s entry)',
                  'Bachelor\'s degree & transcript (for Master\'s applications)',
                  'Official transcripts of grades',
                  'Course descriptions (if requested)',
                  'Certified copies & translations (if not in English/German)',
                ],
              ),
              _DocumentSubsection(
                title: '💬 Personal Support Documents',
                items: [
                  'Curriculum Vitae (CV / Resume)',
                  'Statement of Purpose (SOP / Motivation Letter)',
                  'Letter(s) of Recommendation (LOR)',
                  'Work experience certificates (if applicable)',
                  'Research proposal / portfolio (for some courses)',
                ],
              ),
              _DocumentSubsection(
                title: '🗂 University Forms',
                items: [
                  'Completed university application form',
                  'Uni-assist VPD (if applying through uni-assist)',
                  'Hope Certificate (for final-year students)',
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 2. Language Proficiency
          _buildDocumentSection(
            title: 'Language Proficiency Documents',
            subtitle: 'Required depending on course language',
            icon: Icons.translate_rounded,
            color: const Color(0xFF059669),
            number: '2',
            subsections: [
              _DocumentSubsection(
                title: '🇬🇧 English-taught Programs',
                items: [
                  'IELTS (International English Language Testing System)',
                  'TOEFL (Test of English as a Foreign Language)',
                  'Medium of Instruction (MOI) certificate (sometimes accepted)',
                ],
              ),
              _DocumentSubsection(
                title: '🇩🇪 German-taught Programs',
                items: [
                  'TestDaF (Test Deutsch als Fremdsprache)',
                  'DSH (Deutsche Sprachprüfung für den Hochschulzugang)',
                  'Goethe-Institut certificates (A1 to C2 levels)',
                  'telc German certificates',
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 3. Personal Identity
          _buildDocumentSection(
            title: 'Personal Identity Documents',
            subtitle: 'Essential for both university and visa',
            icon: Icons.badge_rounded,
            color: const Color(0xFF7C3AED),
            number: '3',
            subsections: [
              _DocumentSubsection(
                title: '',
                items: [
                  'Valid passport (with at least 6 months validity)',
                  'Passport copies (2-3 copies recommended)',
                  'Biometric passport photos (as per German visa specifications)',
                  'Address proof and identity proof from home country',
                  'Translations of documents (if not in English/German)',
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 4. Financial Documents
          _buildDocumentSection(
            title: 'Financial Documents',
            subtitle: 'Proof of Funds - Required for visa approval',
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFFEA580C),
            number: '4',
            subsections: [
              _DocumentSubsection(
                title: '',
                items: [
                  'Blocked account confirmation (Sperrkonto) - €11,904 per year',
                  'Scholarship letter (if applicable) - with financial coverage details',
                  'Sponsor affidavit / support letter with sponsor\'s financial documents',
                  'Bank statements showing sufficient funds (last 6 months)',
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 5. Health Insurance
          _buildDocumentSection(
            title: 'Health Insurance Documents',
            subtitle: 'Mandatory for enrollment and visa',
            icon: Icons.local_hospital_rounded,
            color: const Color(0xFFDC2626),
            number: '5',
            subsections: [
              _DocumentSubsection(
                title: '',
                items: [
                  'Travel insurance (valid for initial visa period)',
                  'Student health insurance (statutory or private - after arrival)',
                  'Insurance confirmation document or policy letter',
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 6. Visa Documents
          _buildDocumentSection(
            title: 'Visa & Immigration Documents',
            subtitle: 'Required for German Student Visa',
            icon: Icons.flight_takeoff_rounded,
            color: const Color(0xFF4F46E5),
            number: '6',
            subsections: [
              _DocumentSubsection(
                title: '',
                items: [
                  'Completed visa application form (Schengen Visa Application)',
                  'University admission letter / Conditional offer letter',
                  'Passport & photocopies',
                  'Biometric passport-size photos',
                  'Proof of financial resources',
                  'Health insurance confirmation',
                  'Language proficiency certificate',
                  'Statement of Purpose (SOP) / Motivation Letter',
                  'Academic documents (certificates, transcripts)',
                  'Curriculum Vitae (CV)',
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Optional Documents
          _buildDocumentSection(
            title: 'Optional or Helpful Documents',
            subtitle: 'These improve your application',
            icon: Icons.star_rounded,
            color: const Color(0xFFF59E0B),
            number: '7',
            subsections: [
              _DocumentSubsection(
                title: '',
                items: [
                  'Internship certificates (relevant to your field)',
                  'Work experience letters',
                  'Research papers or publications',
                  'GRE/GMAT scores (if required by university)',
                  'Extra-curricular certificates and achievements',
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // SOP Generator Section - NORMAL SIZE LIKE FINANCIAL CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
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
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, size: 28, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'SOP Generator',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Generate a professional Statement of Purpose instantly by filling simple details. Our AI-powered tool creates a well-structured SOP ready for university applications and visa interviews.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SOPLetterScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_document, size: 20),
                    label: const Text(
                      'Generate SOP Letter',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E3A8A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDocumentSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String number,
    required List<_DocumentSubsection> subsections,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subsections.map((subsection) => _buildSubsection(subsection)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsection(_DocumentSubsection subsection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subsection.title.isNotEmpty) ...[
          Text(
            subsection.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
        ],
        ...subsection.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF006994),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _DocumentSubsection {
  final String title;
  final List<String> items;

  _DocumentSubsection({
    required this.title,
    required this.items,
  });
}