import 'package:flutter/material.dart';
import 'package:pina/data/translation.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show compute;
import 'package:http/http.dart' as http;
import 'package:pina/screens/ai_checking_screen.dart';
import 'package:pina/screens/constants.dart';
import 'package:pina/screens/explicit_content_check_screen.dart';
import 'package:pina/screens/gdpr_scanner_screen.dart';
import 'package:pina/screens/plagarism_check.dart';
import 'package:pina/screens/reverse_search_screen.dart';
import 'package:pina/conversion/main_menu_screen.dart';
import 'package:pina/screens/my_account_screen.dart';
import 'package:pina/screens/study_abroad/study_abroad_screen.dart';
// import 'package:pina/screens/balance_report_screen.dart';
// import 'package:pina/screens/balance_history_screen.dart';
// import 'package:pina/screens/transaction_history_screen.dart';
// import 'package:pina/screens/pricing_menu_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pina/services/session_service.dart';
import '../services/role_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';
import 'package:pina/screens/generate_screen.dart';
import 'package:pina/screens/teacher_generate_screen.dart';
import 'package:pina/screens/question_answer_generator/question_bank_screen.dart';
import 'package:pina/screens/chatbot/chatbot_screen.dart';
import 'package:pina/screens/practice_questions/practice_questions_screen.dart';


class HamburgerMenu extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? userEmail;
  final VoidCallback? onLogout;
  final String selectedLanguage;
  final Function(String)? onLanguageChanged;

  const HamburgerMenu({
    super.key,
    this.userId,
    this.userName,
    this.userEmail,
    this.onLogout,
    this.selectedLanguage = 'English',
    this.onLanguageChanged,
  });

  @override
  State<HamburgerMenu> createState() => _HamburgerMenuState();
}

class _HamburgerMenuState extends State<HamburgerMenu> {
  String? _storedUserName;
  ImageProvider? _profileImage;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    RoleService.refreshRole();
    _loadDrawerData();
  }

  Future<void> _loadDrawerData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await SessionService.getAuthToken();
    final storedName = prefs.getString('userName');

    if (mounted) {
      setState(() {
        _storedUserName = storedName;
      });
    }

    if (token != null) {
      await _loadProfileImageAsync(token);
    }
  }

  Future<void> _loadProfileImageAsync(String token) async {
    if (_isLoadingImage) return;
    
    setState(() => _isLoadingImage = true);

    try {
      final res = await http.get(
        Uri.parse("${ApiConstants.authUrl}/api/auth/profile"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        final user = data['user'];

        if (user['profilePicture'] != null &&
            user['profilePicture'].toString().isNotEmpty) {
          try {
            final base64String = user['profilePicture'].toString();
            
            final estimatedSize = base64String.length * 0.75;
            const maxSize = 500 * 1024;
            
            if (estimatedSize > maxSize) {
              if (mounted) {
                setState(() {
                  _profileImage = null;
                  _isLoadingImage = false;
                });
              }
              return;
            }
            
            final bytes = await _decodeBase64Async(base64String);
            
            if (bytes != null && mounted) {
              final resizedImage = await _resizeImage(bytes);
              
              if (mounted) {
                setState(() {
                  _profileImage = resizedImage;
                });
              }
            }
          } catch (e) {
            if (mounted) {
              setState(() => _profileImage = null);
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _profileImage = null);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingImage = false);
      }
    }
  }

  Future<Uint8List?> _decodeBase64Async(String base64String) async {
    return await compute(_decodeBase64, base64String);
  }
  
  static Uint8List _decodeBase64(String base64String) {
    return base64Decode(base64String);
  }

  Future<ImageProvider> _resizeImage(Uint8List bytes) async {
    if (bytes.length < 100 * 1024) {
      return MemoryImage(bytes);
    }
    
    final completer = Completer<ImageProvider>();
    
    try {
      final image = await decodeImageFromList(bytes);
      
      final targetWidth = 150;
      final targetHeight = 150;
      
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint();
      
      final scaleX = targetWidth / image.width;
      final scaleY = targetHeight / image.height;
      final scale = scaleX < scaleY ? scaleX : scaleY;
      
      final newWidth = (image.width * scale).toInt();
      final newHeight = (image.height * scale).toInt();
      
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble()),
        paint,
      );
      
      final picture = recorder.endRecording();
      final resizedImage = await picture.toImage(newWidth, newHeight);
      final byteData = await resizedImage.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        completer.complete(MemoryImage(byteData.buffer.asUint8List()));
      } else {
        completer.complete(MemoryImage(bytes));
      }
    } catch (e) {
      completer.complete(MemoryImage(bytes));
    }
    
    return completer.future;
  }

  String get displayUserName {
    return _storedUserName ?? widget.userName ?? "User";
  }

  String getLabel(String id) {
    return AppLocale.translations[id]?[widget.selectedLanguage] ?? id;
  }



  @override
  Widget build(BuildContext context) {
  print("===============");
  print("ROLE = ${RoleService.category}");
  print("USER TYPE = ${RoleService.userType}");
  print("IS STUDENT = ${RoleService.isStudent()}");
  print("IS TEACHER = ${RoleService.isTeacher()}");
  print("===============");
    final canSeeStudyAbroad = RoleService.canAccessSync('STUDY_ABROAD');

    final toolTiles = <Widget>[
      if (RoleService.canAccessSync('DEEPFAKE'))
        ListTile(
          leading:
              const Icon(Icons.privacy_tip_outlined, color: Colors.deepPurple),
          title: const Text("AI Checking (Deepfake)"),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AiCheckingScreen(userId: widget.userId ?? ''),
              ),
            );
          },
        ),
      if (RoleService.canAccessSync('IP_VIOLATION'))
        ListTile(
          leading: const Icon(Icons.copyright, color: Colors.orange),
          title: const Text("IP Infringement Check"),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ReverseSearchScreen()),
            );
          },
        ),
      if (RoleService.canAccessSync('EXPLICIT'))
        ListTile(
          leading: const Icon(Icons.explicit, color: Colors.redAccent),
          title: const Text("Explicit Content Check"),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ExplicitContentCheckScreen()),
            );
          },
        ),
      if (RoleService.canAccessSync('PLAGIARISM'))
        ListTile(
          leading: const Icon(Icons.copy_all, color: Colors.blueGrey),
          title: const Text("Plagiarism Check"),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CopyleaksScanScreen()),
            );
          },
        ),
      if (RoleService.canAccessSync('GDPR'))
        ListTile(
          leading: const Icon(Icons.security, color: Colors.green),
          title: const Text("GDPR Compliance Check"),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const GDPRScannerScreen()),
            );
          },
        ),
    ];

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: TemplateTheme.heroGradient,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Header with REPLACED CONTENT ─────────────────────────
            DrawerHeader(
              decoration: TemplateTheme.glassPanel(
                color: Colors.white,
                opacity: 0.72,
                radius: 0,
              ),
              child: displayUserName != "User"
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Arthum AI Logo Row
                        Row(
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
                                color: TemplateTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // REPLACED SECTION START
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: _buildProfileAvatar(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Hi, $displayUserName",
                                style: const TextStyle(
                                  color: TemplateTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // REPLACED SECTION END
                      ],
                    )
                  : const Center(
                      child: Text(
                        "Menu",
                        style: TextStyle(
                          color: TemplateTheme.textPrimary,
                          fontSize: 24,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),

            // ── Home ───────────────────────────────────
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),

            // ── Education ──────────────────────────────
            ExpansionTile(
              leading: const Icon(Icons.school),
              title: const Text("Education"),
              childrenPadding: const EdgeInsets.only(left: 20),
              children: [
                if (canSeeStudyAbroad)
                  ListTile(
                    leading: const Icon(Icons.public, color: Colors.blue),
                    title: const Text("Study Abroad"),
                    subtitle: const Text("Your future is here!",
                        style: TextStyle(fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StudyAbroadScreen()),
                      );
                    },
                  ),
                // 1. Govt School block commented
                // ExpansionTile(
                //   leading: const Icon(Icons.account_balance),
                //   title: const Text("Govt School"),
                //   childrenPadding: const EdgeInsets.only(left: 20),
                //   children: [
                //     ListTile(
                //       leading: const Icon(Icons.computer),
                //       title: const Text("Microsoft NCS"),
                //       onTap: () =>
                //           _showComingSoon(context, "Microsoft NCS"),
                //     ),
                //   ],
                // ),
                // ── GENERATE (UNDER EDUCATION) - WITH ROLE-BASED ROUTING ✅
                if (RoleService.isStudent() || RoleService.isTeacher())
                  ListTile(
                    leading: const Icon(Icons.auto_awesome),
                    title: const Text("Generate"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            if (RoleService.isTeacher()) {
                              return const TeacherGenerateScreen();
                            }
                            return const GenerateScreen();
                          },
                        ),
                      );
                    },
                  ),
                // ── PRACTICE QUESTIONS ───────────────────────
                if (RoleService.isStudent() || RoleService.isTeacher())
                  ListTile(
                    leading: const Icon(Icons.quiz_outlined),
                    title: const Text("Practice Questions"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PracticeQuestionsScreen(),
                        ),
                      );
                    },
                  ),
              ],
            ),
            // ── QUESTION BANK ──────────────────────────
            if (RoleService.isStudent() || RoleService.isTeacher())
              ListTile(
                leading: const Icon(Icons.quiz_rounded),
                title: const Text("Question Bank"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const QuestionBankScreen(),
                    ),
                  );
                },
              ),


            // ── Chatbot ─────────────────────────────────
            ListTile(
              leading: const Icon(Icons.chat_rounded),
              title: const Text("Chatbot"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatbotScreen(),
                  ),
                );
              },
            ),

            // ── Conversion ─────────────────────────────

            ListTile(
              leading: const Icon(Icons.transform),
              title: const Text("Conversion"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainMenuScreen(
                      userId: widget.userId,
                      userName: displayUserName,
                      userEmail: widget.userEmail,
                    ),
                  ),
                );
              },
            ),

            // 2. Enterprise AI menu completely hidden/commented
            // ExpansionTile(
            //   leading: const Icon(Icons.business),
            //   title: const Text("Enterprise AI"),
            //   childrenPadding: const EdgeInsets.only(left: 20),
            //   children: [
            //     ListTile(
            //       leading: const Icon(Icons.storage),
            //       title: const Text("Sovereign Data"),
            //       onTap: () =>
            //           _showComingSoon(context, "Sovereign Data"),
            //     ),
            //   ],
            // ),

            // ── Tools ──────────────────────────────────
            if (toolTiles.isNotEmpty)
              ExpansionTile(
                leading: const Icon(Icons.handyman_outlined),
                title: const Text("Tools"),
                childrenPadding: const EdgeInsets.only(left: 20),
                children: toolTiles,
              ),

            // ── Pricing ────────────────────────────────
            // ListTile(
            //   leading: const Icon(Icons.price_change),
            //   title: const Text("Pricing"),
            //   onTap: () {
            //     Navigator.pop(context);
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => const PricingMenuScreen(),
            //       ),
            //     );
            //   },
            // ),

            // // ── Reports ────────────────────────────────
            // ExpansionTile(
            //   leading: const Icon(Icons.bar_chart),
            //   title: const Text("Reports"),
            //   childrenPadding: const EdgeInsets.only(left: 20),
            //   children: [
            //     ListTile(
            //       leading:
            //           const Icon(Icons.account_balance_wallet),
            //       title: const Text("Balance Report"),
            //       onTap: () {
            //         Navigator.pop(context);
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (_) => BalanceReportScreen()),
            //         );
            //       },
            //     ),
            //     ListTile(
            //       leading: const Icon(Icons.history),
            //       title: const Text("Balance History"),
            //       onTap: () {
            //         Navigator.pop(context);
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (_) => BalanceHistoryScreen()),
            //         );
            //       },
            //     ),
            //     ListTile(
            //       leading: const Icon(Icons.receipt_long),
            //       title: const Text("Transaction History"),
            //       onTap: () {
            //         Navigator.pop(context);
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (_) =>
            //                   TransactionHistoryScreen()),
            //         );
            //       },
            //     ),
            //   ],
            // ),

            // const Divider(color: TemplateTheme.border),

            // ── About Us ───────────────────────────────
            ExpansionTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About Us"),
              childrenPadding: const EdgeInsets.only(left: 20),
              children: [
                // 3. Legal ListTile commented
                // ListTile(
                //   leading: const Icon(Icons.gavel),
                //   title: const Text("Legal"),
                //   onTap: () =>
                //       _showComingSoon(context, "Legal Information"),
                // ),
                // 4. Contact Us replaced with new version (no dialog)
                ListTile(
                  leading: const Icon(Icons.contact_support_outlined),
                  title: const Text("Contact Us"),
                  subtitle: const Text(
                    "support@arthumai.com",
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "For any query please email support@arthumai.com",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const Divider(color: TemplateTheme.border),

            // ── My Profile ─────────────────────────────
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("My profile",
                  style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MyAccountScreen()),
                );
              },
            ),

            // ── Logout ─────────────────────────────────
            if (widget.onLogout != null) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout,
                    color: TemplateTheme.accent),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                      color: TemplateTheme.accent,
                      fontWeight: FontWeight.bold),
                ),
                onTap: widget.onLogout,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: TemplateTheme.primary.withOpacity(0.2),
      ),
      child: ClipOval(
        child: _isLoadingImage
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: TemplateTheme.primary,
                  ),
                ),
              )
            : (_profileImage != null
                ? Image(
                    image: _profileImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                  )
                : _buildDefaultAvatar()),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: TemplateTheme.primary.withOpacity(0.3),
      child: const Icon(
        Icons.person,
        size: 24,
        color: Colors.white,
      ),
    );
  }
}