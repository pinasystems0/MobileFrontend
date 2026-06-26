import 'package:flutter/material.dart';
import 'package:pina/screens/loginscreen.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';


/// ✅ REGISTRATION DONE SCREEN
/// Shows success message after completing registration
/// Navigates to home screen
class RegistrationDone extends StatelessWidget {
  const RegistrationDone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TemplateBackdrop(
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ Logo + Arthum AI Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/template/icons/arthum_logo.png',
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Arthum AI",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: TemplateTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),

                    // ✅ Success Icon
                    Icon(
                      Icons.check_circle,
                      color: TemplateTheme.primary,
                      size: 70,
                    ),
                    
                    const SizedBox(height: 14),

                    // ✅ Main Title
                    const Text(
                      "Registration Completed!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: TemplateTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // (Intentionally removed generic welcome text for email verification flow)


                    const SizedBox(height: 20),

// ✅ Registration Complete -> Email Verification required
                    const SizedBox(height: 8),
                    const Text(
                      "Please verify your email. A verification link has been sent to your email address.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: TemplateTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ✅ Go to Login Button (clear temporary session)
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Clear temporary registration/session data
                          await SessionService.clearAuthOnly();


                          if (!context.mounted) return;

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: TemplateTheme.primaryButtonStyle(),
                        child: const Text(
                          "Go to Login",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}