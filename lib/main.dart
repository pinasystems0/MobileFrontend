import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pina/services/generation_notification_service.dart';
import 'package:pina/screens/generate_screen.dart';
import 'package:pina/screens/teacher_generate_screen.dart';

// ================= REGISTRATION SCREENS =================

import 'package:pina/screens/registration/registration.dart';
import 'package:pina/screens/registration/registration_step2.dart';
import 'package:pina/screens/registration/affiliate_library_profile.dart';
import 'package:pina/screens/registration/affiliate_final_profile.dart';
import 'package:pina/screens/registration/student_step1_profile.dart';
import 'package:pina/screens/registration/student_step2_parent.dart';
import 'package:pina/screens/registration/student_step3_timetable.dart';
import 'package:pina/screens/registration/student_step4_exam.dart';
import 'package:pina/screens/registration/registration_done.dart';

// ================= MAIN APP =================
import 'package:pina/screens/trial.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/services/role_service.dart';
import 'package:pina/theme/theme.dart';

// ================= FIREBASE BACKGROUND HANDLER =================
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔥 Background message: id=${message.messageId}, title=${message.notification?.title}, data=${message.data}");
}

Future<void> _setupFirebaseMessageDebugLogs(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  Future<void> _persistPendingPayload(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();

    final outputId = message.data['outputId']?.toString();
    final requestType = message.data['requestType']?.toString();
    final screen = message.data['screen']?.toString();

    print('🚀 NOTIFICATION TAP RECEIVED');
    print('🚀 SAVING PENDING PAYLOAD');

    await prefs.setString('pending_output_id', outputId ?? '');
    await prefs.setString('pending_request_type', requestType ?? '');
    await prefs.setString('pending_screen', screen ?? '');
  }

  // Foreground notifications (local show)
  FirebaseMessaging.onMessage.listen((message) async {
    print("📩 Foreground message: id=${message.messageId}, title=${message.notification?.title}, data=${message.data}");

    final title = message.notification?.title ?? message.data['title'];
    final body = message.notification?.body ?? message.data['body'];

    if (title == null && body == null) return;

    const channelId = 'arthum_notifications';

    try {
      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title ?? '',
        body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'Registration Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e, st) {
      print("❌ LOCAL NOTIFICATION ERROR: $e");
      print(st);
    }
  });

  // Tap from background
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    await _persistPendingPayload(message);
  });

  // Tap from terminated
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    await _persistPendingPayload(initialMessage);
  }
}



Future<void> main() async {


  // ✅ SABSE PEHLE - WidgetsFlutterBinding
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ SECOND - .env load
  await dotenv.load(fileName: ".env");

  // ✅ THIRD - Notifications Plugin Init
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (details) async {
      try {
        // Used for generation notifications.
        await GenerationNotificationService.markPendingTapAndReturnPayload();
      } catch (_) {
        // ignore
      }
    },
  );


  const androidChannel = AndroidNotificationChannel(
    'arthum_notifications',
    'Registration Notifications',
    description: 'Notifications for registration events',
    importance: Importance.max,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);

  // ✅ FOURTH - Firebase Init
  await Firebase.initializeApp();

  // ✅ Notification permission (Android 13+ / iOS)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  await _setupFirebaseMessageDebugLogs(flutterLocalNotificationsPlugin);




  // ✅ FIFTH - Supabase Init
  await Supabase.initialize(
    url: "https://scihfxzgyofkjkffjhnd.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjaWhmeHpneW9ma2prZmZqaG5kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzczNjAzNDMsImV4cCI6MjA5MjkzNjM0M30.mBkOLz3HHPHuMSrv52u_j6Zi0I_Hc1J7FS03n3p3maw",
  );

  // ✅ SIXTH - Storage Init
  await Hive.initFlutter();
  await Hive.openBox('chat_storage_v2');
  await RoleService.refreshRole();

  final prefs = await SharedPreferences.getInstance();

  // ✅ SEVENTH - Session Data
  final String? userEmail = await SessionService.getUserEmail();
  final String? userName = await SessionService.getUserName();
  String? userRole = await SessionService.getUserRole();
  final String? userType = await SessionService.getUserType();

  RoleService.hydrate(
    category: userRole,
    userType: userType,
  );

  if (userEmail != null) {
    await RoleService.refreshRole();
    if (RoleService.category != 'unknown') {
      userRole = RoleService.category;
    }
  }

  final bool completedStep1 = prefs.getBool('completedStep1') ?? false;
  final bool completedStep2 = prefs.getBool('completedStep2') ?? false;
  final bool completedStep3 = prefs.getBool('completedStep3') ?? false;

  Widget startScreen;

  final bool isAffiliateUser = {
    'Library',
    'Stationary',
    'Photo Copy & Printer',
    'School Uniform',
    'School Uniform / Bag / Bus',
  }.contains(userRole);

  // ================= DECISION TREE =================
  if (userEmail == null) {
    startScreen = const Registration();
  } 
  else if (!completedStep1) {
    startScreen = const Registration();
  } 
  else if (isAffiliateUser) {
    if (!completedStep2 && userRole == 'Library') {
      startScreen = const AffiliateLibraryProfile();
    } else if (!completedStep3) {
      startScreen = const AffiliateFinalProfile();
    } else {
      startScreen = Trial(
        userEmail: userEmail,
        userName: userName ?? "User",
      );
    }
  }
  else if (!completedStep2) {
    startScreen = RegistrationStep2(
      email: userEmail,
      category: userRole ?? "",
    );
  } 
  else if (userRole == "Student" && !completedStep3) {
    startScreen = StudentStep1Profile(email: userEmail);
  } 
  else {
    startScreen = Trial(
      userEmail: userEmail,
      userName: userName ?? "User",
    );
  }

  runApp(MainApp(startScreen: startScreen));
}

// ========================================================
// ======================= APP ROOT ========================
// ========================================================

class MainApp extends StatelessWidget {
  final Widget startScreen;

  const MainApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: startScreen,
      routes: {

        "/register": (_) => const Registration(),
        "/register-step2": (_) => const RegistrationStep2(
              email: "",
              category: "",
            ),
        "/student-profile": (_) => const StudentStep1Profile(email: ""),
        "/student-parent": (_) => const StudentStep2Parent(email: ""),
        "/student-timetable": (_) => const StudentStep3Timetable(),
        "/student-exam": (_) => const StudentStep4Exam(),
        "/registration-done": (_) => const RegistrationDone(),
        "/home": (_) => Trial(
              userEmail: "",
              userName: "User",
            ),
      },
    );
  }
}