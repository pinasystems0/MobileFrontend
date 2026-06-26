import 'package:flutter/material.dart';
import 'package:pina/screens/study_abroad/germany/financial_summary_form.dart';
import 'package:pina/screens/study_abroad/germany/sponsor_letter_form.dart';

class FinancialProofScreen extends StatelessWidget {
  const FinancialProofScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Proof Preparation'),
      ),
      
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // STEP 1: BIG Information Card
                  _buildInfoCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Information line
                  Center(
                    child: Text(
                      '👇 Generate your documents below 👇',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // STEP 2: Financial Summary Letter Section
                  _buildFinancialSummarySection(context),
                  
                  const SizedBox(height: 24),
                  
                  // STEP 3: Sponsor Letter Section
                  _buildSponsorLetterSection(context),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= INFORMATION CARD (BIG) =================
  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade800, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🇩🇪 Germany – Proof of Financial Resources',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Main Info
            Text(
              'To get a Germany student visa, you must prove that you have enough money to support yourself for one year.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Amount Cards
            Row(
              children: [
                Expanded(
                  child: _buildAmountCard(
                    icon: Icons.euro,
                    amount: '€992',
                    period: 'per month',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAmountCard(
                    icon: Icons.euro,
                    amount: '€11,904',
                    period: 'per year',
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Covers text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'This covers: Rent • Food • Health insurance • Travel • Daily expenses',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // ✅ Accepted ways to show funds - BIGGER
            Text(
              '✅ Accepted ways to show funds:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Funding Methods Grid
            Column(
              children: [
                // Blocked Account
                _buildFundingMethodCard(
                  color: Colors.amber,
                  title: '🟡 Blocked Account (Sperrkonto)',
                  description: 'Deposit money in a special blocked account. You can withdraw monthly after arriving in Germany.',
                ),
                
                const SizedBox(height: 10),
                
                // Scholarship
                _buildFundingMethodCard(
                  color: Colors.green,
                  title: '🟢 Scholarship Letter',
                  description: 'Official scholarship covering living costs.',
                ),
                
                const SizedBox(height: 10),
                
                // Sponsor
                _buildFundingMethodCard(
                  color: Colors.blue,
                  title: '🔵 Sponsor (Commitment Letter)',
                  description: 'A person in Germany legally supports your expenses.',
                ),
                
                const SizedBox(height: 10),
                
                // Other
                _buildFundingMethodCard(
                  color: Colors.purple,
                  title: '🟣 Other (Loan/Bank/Parents)',
                  description: 'Bank statements or loan approval (may vary by embassy).',
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📌 How to use this tool:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Click on any letter below to open form\n'
                    '• Fill required details in the form\n'
                    '• Generate PDF instantly\n'
                    '• Download and use for visa application\n'
                    '• No document uploads needed',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
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

  // ================= FINANCIAL SUMMARY LETTER SECTION =================
  Widget _buildFinancialSummarySection(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.summarize, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '1. Financial Summary Letter',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              'A professional summary of your financial preparations for Germany visa application.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // What's included - PARAGRAPH (not bullets)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ What this letter includes:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This letter includes student personal details, course and university information, funding type and amount details, living cost calculations, health insurance status, and a professional summary statement.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // When to use
            Wrap(
              children: [
                Icon(Icons.access_time, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Use this for: Visa application, University admission, Embassy interviews',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade800,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _openFinancialSummaryForm(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_document, size: 24),
                    SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Fill Form & Generate Letter',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Center(
              child: Text(
                'Click to open form, fill details, get PDF',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SPONSOR LETTER SECTION =================
  Widget _buildSponsorLetterSection(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.description, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '2. Sponsor Declaration Letter',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              'A formal declaration letter from your sponsor for visa application.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // What's included - PARAGRAPH (not bullets)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ What this letter includes:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This letter includes sponsor personal details, relationship to student, occupation and country, yearly support amount, formal declaration statement, and signature placeholder.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // When to use
            Wrap(
              children: [
                Icon(Icons.access_time, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Use this if: You have a sponsor funding your studies',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade800,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _openSponsorLetterForm(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_document, size: 24),
                    SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Fill Form & Generate Letter',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Center(
              child: Text(
                'Click to open form, fill details, get PDF',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPER WIDGETS =================
  Widget _buildAmountCard({
    required IconData icon,
    required String amount,
    required String period,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            period,
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundingMethodCard({
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ================= FORM OPENING METHODS =================
  void _openFinancialSummaryForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FinancialSummaryForm(),
    );
  }

  void _openSponsorLetterForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SponsorLetterForm(),
    );
  }
}