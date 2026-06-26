import 'package:flutter/material.dart';
import 'package:pina/screens/study_abroad/germany/academic_requirements_screen.dart';
import 'package:pina/screens/study_abroad/germany/aps_certificate_screen.dart';
import 'package:pina/screens/study_abroad/germany/language_requirements_screen.dart';
import 'package:pina/screens/study_abroad/germany/university_admission_screen.dart';
import 'package:pina/screens/study_abroad/germany/financial_proof_screen.dart'; // ✅ ADD THIS IMPORT
import 'package:pina/screens/study_abroad/germany/health_insurance_screen.dart';
import 'package:pina/screens/study_abroad/germany/documents_screen.dart';
import 'package:pina/screens/study_abroad/germany/germany_visa_info_screen.dart';
import 'package:pina/screens/study_abroad/germany/germany_accommodation_info_screen.dart';
import 'package:pina/screens/study_abroad/germany/germany_after_arrival_info_screen.dart'; 



class GermanyChecklistScreen extends StatelessWidget {
  const GermanyChecklistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Germany Preparation Checklist"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            "Complete each section to prepare for Germany 🇩🇪",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 20),

          _sectionCard(context,
              icon: Icons.school,
              title: "Academic Requirements",
              subtitle: "Education eligibility & qualification"),

          _sectionCard(context,
              icon: Icons.verified,
              title: "APS Certificate",
              subtitle: "Document verification (mandatory)"),

          _sectionCard(context,
              icon: Icons.language,
              title: "Language Requirements",
              subtitle: "IELTS / German certificate"),

          _sectionCard(context,
              icon: Icons.apartment,
              title: "University Admission",
              subtitle: "Offer letter & course details"),

          _sectionCard(context,
              icon: Icons.account_balance_wallet,
              title: "Financial Proof",
              subtitle: "Blocked account / funds"),

          _sectionCard(context,
              icon: Icons.health_and_safety,
              title: "Health Insurance",
              subtitle: "Mandatory student insurance"),

          _sectionCard(context,
              icon: Icons.folder,
              title: "Documents",
              subtitle: "Passport, SOP, CV, marksheets"),

          _sectionCard(context,
              icon: Icons.flight_takeoff,
              title: "Student Visa",
              subtitle: "Visa application & appointment"),

          _sectionCard(context,
              icon: Icons.home_work,
              title: "Accommodation",
              subtitle: "Stay proof in Germany"),

          _sectionCard(context,
              icon: Icons.info_outline,
              title: "After Arrival",
              subtitle: "Registration & legal steps"),
        ],
      ),
    );
  }

  // =============================
  // PREMIUM CHECKLIST CARD
  // =============================
  Widget _sectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () {
        // ✅ ONLY change added here
        if (title == "Academic Requirements") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AcademicRequirementsScreen(),
            ),
          );
          return;
        }
        if (title == "APS Certificate") {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ApsCertificateScreen(),
    ),
  );
  return;
}
       
     if (title == "Language Requirements") {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LanguageRequirementsScreen(),
      ),
    );
    return;
  }
  if (title == "University Admission") {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UniversityAdmissionScreen(),
      ),
    );
    return;
  }
       // ✅ FINANCIAL PROOF NAVIGATION ADDED
        if (title == "Financial Proof") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FinancialProofScreen(), // ✅ NEW SCREEN
            ),
          );
          return;
        }
        
        if (title == "Health Insurance") {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const HealthInsuranceScreen(),
          ),
        );
        return;
        }

        if (title == "Documents") {
   Navigator.push(
     context,
     MaterialPageRoute(
        builder: (_) => const GermanyDocumentsScreen(), 
    ),
  );
  return;
}

        
      if (title == "Student Visa") {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const GermanyVisaInfoScreen(),
    ),
  );
  return;
}
      if (title == "Accommodation") {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const GermanyAccommodationInfoScreen(),
    ),
  );
}
      if (title == "After Arrival") {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const GermanyAfterArrivalInfoScreen(),
    ),
  );
  return;
}
   


        // default snackbar for other sections
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title screen coming next")),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [

            // ICON CIRCLE
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.indigo),
            ),

            const SizedBox(width: 14),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // STATUS (default pending)
            const Icon(Icons.radio_button_unchecked,
                color: Colors.grey),

            const SizedBox(width: 6),

            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}
