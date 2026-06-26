import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pina/models/news_article.dart';
import 'package:pina/screens/constants.dart';
import 'package:pina/screens/my_ai_screen.dart';
import 'package:pina/screens/notification_screen.dart';
import 'package:pina/services/news_service.dart';
import 'package:pina/services/role_service.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/screens/loginscreen.dart';
import 'package:pina/ui_template/utils/template_layout.dart';
import 'package:pina/ui_template/utils/template_theme.dart';
import 'package:pina/widgets/hamburger_menu.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pina/services/supabase_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';




// --- ENUM FOR ACCORDION LOGIC ---
enum ActiveSection { none, title, desc, impact, action }

class Trial extends StatefulWidget {
  final String userName;
  final String userEmail;

  const Trial({super.key, this.userName = "User", required this.userEmail});

  @override
  State<Trial> createState() => _TrialState();
}

class _TrialState extends State<Trial> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _welcomeNotificationQueued = false;

  List<NewsArticle> articles = [];
  bool isLoading = true;
  String _currentLanguage = 'English';
  
  // Store channel reference for cleanup
  RealtimeChannel? _notificationsChannel;

  // For refreshing unread count
  int _unreadCount = 0;
  
  // Track the last token we successfully synced
  String? _lastSyncedToken;
  StreamSubscription<String>? _tokenRefreshSubscription;

  // --- GLOBAL ACCORDION STATE ---
  String? _expandedArticleUrl;
  ActiveSection _expandedSection = ActiveSection.none;

  String get _normalizedUserEmail => widget.userEmail.trim().toLowerCase();

  // 🟢 STEP 2: Function to send token to backend
  Future<void> sendTokenToBackend(String? token) async {
    final normalizedToken = token?.trim();
    if (normalizedToken == null || normalizedToken.isEmpty) return;
    if (_lastSyncedToken == normalizedToken) return;

    final url = "${ApiConstants.authUrl}/save-token";

    if (kDebugMode) {
      print("🌐 Saving FCM token to: $url");
      print("📱 User email: $_normalizedUserEmail");
      print("🔥 Token preview: ${normalizedToken.substring(0, normalizedToken.length > 12 ? 12 : normalizedToken.length)}...");
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": _normalizedUserEmail,
          "fcmToken": normalizedToken,
          "platform": "flutter_mobile",
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("✅ Token sent to backend successfully: ${response.body}");
        }
        _lastSyncedToken = normalizedToken;
      } else {
        if (kDebugMode) {
          print("❌ Failed to send token: ${response.statusCode} - ${response.body}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error sending token to backend: $e");
      }
    }
  }

  // 🟢 STEP 3: Updated getFCMToken with token sending
  void getFCMToken() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      
      String? token = await FirebaseMessaging.instance.getToken();
      if (kDebugMode) {
        print("🔥 FCM TOKEN: $token");
      }

      // 🔥 MOST IMPORTANT LINE - Send token to backend
      await sendTokenToBackend(token);
      
      // Also listen for token refresh
      _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        if (kDebugMode) {
          print("🔥 FCM TOKEN REFRESHED: $newToken");
        }
        sendTokenToBackend(newToken);
      });
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error getting FCM token: $e");
      }
    }
  }

  Future<void> _showWelcomeNotificationOncePerLoginSession() async {
    if (_welcomeNotificationQueued) return;
    _welcomeNotificationQueued = true;

    const prefKey = 'welcome_notification_shown_for_login_session';

    try {
      print('🚀 WELCOME NOTIFICATION TRIGGERED');

      final prefs = await SharedPreferences.getInstance();
      final alreadyShown = prefs.getBool(prefKey) ?? false;
      if (alreadyShown) {
        return;
      }

      print('🚀 ABOUT TO SHOW WELCOME NOTIFICATION');

      // Replace manual local notification with centralized backend template.
      // The backend will fetch title/body from notification_templates where code = 'WELCOME'.
      print('📩 REQUESTING CENTRALIZED WELCOME NOTIFICATION');

      // Use the same identifier format currently used by registration success notifications.
      // In this app Trial receives userEmail, and existing backend integration uses `userId` as provided.
      final userId = _normalizedUserEmail;
      print('🚀 WELCOME TEMPLATE REQUESTED');
print({
  'code': 'WELCOME',
  'userId': userId,
});

      try {
        final res = await http.post(
          Uri.parse('${ApiConstants.authUrl}/api/notifications/registration-success'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': userId,'templateCode': 'WELCOME',}),
        );

        // Note: backend route currently named /registration-success; it uses NotificationService.sendTemplate.
        // This request relies on the backend template code already configured for that endpoint.
        if (res.statusCode >= 200 && res.statusCode < 300) {
          print('✅ WELCOME NOTIFICATION REQUESTED');
          await prefs.setBool(prefKey, true);
          return;
        }

        throw Exception('Backend responded with ${res.statusCode}: ${res.body}');
      } catch (e) {
        print('❌ WELCOME NOTIFICATION FAILED');
        rethrow;
      }
    } catch (e, st) {
      print('❌ WELCOME NOTIFICATION ERROR: $e');
      print(st);
    }
  }

  @override
  void initState() {
    super.initState();

    fetchNewsData();
    _refreshUnreadCount();

    // 🔥 GET FCM TOKEN AND SEND TO BACKEND
    getFCMToken();

    if (kDebugMode) {
      print("🔍 USER EMAIL RAW: ${widget.userEmail}");
      print("🔍 USER EMAIL NORMALIZED: $_normalizedUserEmail");
    }

    // Setup realtime after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupRealtime();
      _showWelcomeNotificationOncePerLoginSession();
    });

  }

  // Separate realtime setup
  void _setupRealtime() {
    _notificationsChannel = SupabaseService.client
      .channel('public:notifications')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'notifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: _normalizedUserEmail,
        ),
        callback: (payload) {
          if (payload.newRecord == null) return;
          
          if (kDebugMode) {
            print("🔥 REALTIME HIT: ${payload.newRecord}");
          }
          
          _refreshUnreadCount();

          final newData = Map<String, dynamic>.from(payload.newRecord);

          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final String title = newData['title'] ?? "New Notification";
              final String message = newData['message'] ?? "";
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (message.isNotEmpty) Text(message),
                    ],
                  ),
                  backgroundColor: TemplateTheme.primary,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(12),
                  duration: const Duration(seconds: 4),
                ),
              );
            });
          }
        },
      )
      .subscribe((status, error) {
        if (kDebugMode) {
          print("📡 Realtime subscription status: $status");
          if (error != null) print("❌ Realtime subscription error: $error");
        }
        if (status == RealtimeSubscribeStatus.subscribed && kDebugMode) {
          print("✅ Successfully subscribed to notifications realtime");
        }
      });
  }

  @override
  void dispose() {
    _notificationsChannel?.unsubscribe();
    _tokenRefreshSubscription?.cancel();
    super.dispose();
  }

  // Get Unread Count Function
  Future<int> _getUnreadCount() async {
    try {
      final response = await SupabaseService.client
          .from('notifications')
          .select('id')
          .eq('user_id', _normalizedUserEmail)
          .eq('is_read', false);

      return response?.length ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print("Unread count error: $e");
      }
      return 0;
    }
  }

  // Refresh unread count
  Future<void> _refreshUnreadCount() async {
    final count = await _getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }

  // Bell Icon Widget
  Widget _buildNotificationBell() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: TemplateTheme.textPrimary),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationScreen(
                  userEmail: _normalizedUserEmail,
                ),
              ),
            );
            _refreshUnreadCount();
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> fetchNewsData() async {
    try {
      final data = await Apiservice().fetchNews();
      final limitedData = data.take(10).toList();

      if (mounted) {
        setState(() {
          articles = limitedData;
          isLoading = false;
        });
      }

      _saveToDatabase(limitedData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint("REAL ERROR: $e");
      }
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _saveToDatabase(List<NewsArticle> articles) async {
    final String url = "${ApiConstants.authUrl}/api/news/save-batch";

    Map<String, dynamic> inputs = {
      "q": "latest news",
      "language": _currentLanguage,
      "size": "10",
      "country": "in",
      "id": "",
      "qInTitle": "",
      "qInMeta": "",
      "timeframe": "",
      "excludecountry": "",
      "category": "",
      "excludecategory": "",
      "excludelanguage": "",
      "sort": "",
      "url": "",
      "tag": "",
      "sentiment": "",
      "organization": "",
      "region": "",
      "domain": "",
      "domainurl": "",
      "excludedomain": "",
      "excludefield": "",
      "prioritydomain": "",
      "timezone": "",
      "full_content": "",
      "image": "",
      "video": "",
      "removeduplicate": "",
      "page": "",
    };

    List<Map<String, dynamic>> articlesJson = articles
        .map(
          (a) => {
            "articleid": a.articleid,
            "title": a.title,
            "link": a.link,
            "description": a.description,
            "keywords": a.keywords,
            "creator": a.creator,
            "imageurl": a.imageurl,
            "pubdate": a.pubdate,
            "pubdatetz": a.pubdatetz,
            "sourceid": a.sourceid,
            "sourceurl": a.sourceurl,
            "sourceicon": a.sourceicon,
            "sourcepriority": a.sourcepriority,
            "country": a.country,
            "category": a.category,
            "language": a.language,
            "duplicate": a.duplicate,
          },
        )
        .toList();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "inputs": inputs,
          "articles": articlesJson,
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Success: 1 Input and ${articlesJson.length} Outputs saved.");
        }
      } else {
        if (kDebugMode) {
          print("Failed to save: ${response.body}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving to DB: $e");
      }
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('welcome_notification_shown_for_login_session', false);

    await SessionService.clearSession();
    await RoleService.clear();


    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _onSectionToggle(String url, ActiveSection section) {
    setState(() {
      if (_expandedArticleUrl == url && _expandedSection == section) {
        _expandedSection = ActiveSection.none;
        _expandedArticleUrl = null;
      } else {
        _expandedArticleUrl = url;
        _expandedSection = section;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: HamburgerMenu(
        userName: widget.userName,
        userEmail: widget.userEmail,
        onLogout: _handleLogout,
        selectedLanguage: _currentLanguage,
        onLanguageChanged: (newLanguage) {
          setState(() => _currentLanguage = newLanguage);
          Navigator.pop(context);
        },
      ),
      body: TemplateLayout(
       brandTitle: "Arthum AI",
        brandSubtitle:
            "Multi-Modal Generative AI Platform",
        sectionTitle: "News Feed",
        leading: Container(
          decoration: TemplateTheme.glassPanel(
            color: Colors.white,
            opacity: 0.56,
            radius: 20,
          ),
          child: IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(
              Icons.menu,
              color: TemplateTheme.textPrimary,
            ),
          ),
        ),
        headerAction: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationBell(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyAiScreen(),
                  ),
                );
              },
              style: TemplateTheme.secondaryButtonStyle(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
              child: const Text("My AI"),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: fetchNewsData,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 8,
                        ),
                        itemCount: articles.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 18),
                        itemBuilder: (context, index) {
                          final article = articles[index];

                          final bool isThisCardActive =
                              _expandedArticleUrl == article.link;
                          final ActiveSection currentCardSection =
                              isThisCardActive
                              ? _expandedSection
                              : ActiveSection.none;

                          final cardColor = index.isEven
                              ? const Color(0xFFF7F8FF)
                              : const Color(0xFFF9FBFF);

                          return NewsCard(
                            key: ValueKey(article.link),
                            title: article.title,
                            desc: article.description.isNotEmpty
                                ? article.description
                                : "No description available.",
                            articleUrl: article.link,
                            imageUrl: article.imageurl,
                            userEmail: widget.userEmail,
                            bg: cardColor,
                            border: index.isEven
                                ? const Color(0xFFDCE1F5)
                                : const Color(0xFFD6E5FF),
                            titleColor: index.isEven
                                ? TemplateTheme.primary
                                : TemplateTheme.night,
                            activeSection: currentCardSection,
                            onSectionChange: (section) =>
                                _onSectionToggle(article.link, section),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NEWS CARD ---
class NewsCard extends StatefulWidget {
  final String title;
  final String desc;
  final String articleUrl;
  final String imageUrl;
  final String userEmail;
  final Color bg;
  final Color border;
  final Color titleColor;
  final ActiveSection activeSection;
  final Function(ActiveSection) onSectionChange;

  const NewsCard({
    super.key,
    required this.title,
    required this.desc,
    required this.articleUrl,
    required this.imageUrl,
    required this.userEmail,
    required this.bg,
    required this.border,
    required this.titleColor,
    required this.activeSection,
    required this.onSectionChange,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> with AutomaticKeepAliveClientMixin {
  String? _impactSummary;
  String? _actionSummary;
  bool _isFetched = false;
  bool _isLoading = false;
  String? _error;
  Timer? _debounceTimer;
  bool _isLiked = false;
  bool _isDisliked = false;

  @override
  bool get wantKeepAlive => _isFetched || widget.activeSection != ActiveSection.none;

  String _mapError(String rawError) {
    if (kDebugMode) {
      debugPrint("REAL ERROR: $rawError");
    }
    if (rawError.toLowerCase().contains('timeout')) return "Connection seems slow. Please try again.";
    if (rawError.toLowerCase().contains('network')) return "No internet connection.";
    return "Oops! Something went wrong. Please try again.";
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (_isFetched || _isLoading) return;
    if (info.visibleFraction > 0.1) {
      debugPrint("CARD VISIBLE");
      _debounceTimer ??= Timer(const Duration(milliseconds: 200), () {
        _fetchAiData();
        _debounceTimer = null;
      });
    } else {
      _debounceTimer?.cancel();
      _debounceTimer = null;
    }
  }

  Future<void> _fetchAiData() async {
    if (!mounted) return;
    debugPrint("_fetchAiData START");
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.authUrl}/api/news/ai/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "prompt": "Analyze this news event:\nHEADLINE: ${widget.title}\nCONTEXT: ${widget.desc}\n\nTASK:\nReturn ONLY in this format:\nImpact Analysis: <text> ||| Quick Action: <text>\n\nDo not add headings, markdown, or extra text.\nWrite 4-5 lines each.\n",
          "temperature": 0.7
        }),
        )
        .timeout(
           const Duration(minutes: 3),

      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && (data['choices'] as List).isNotEmpty) {
          String content = data['choices'][0]['message']['content'];
          List<String> parts = content.split("|||");
          String impact = parts.length >= 2 ? parts[0] : content;
          String action = parts.length >= 2 ? parts[1] : "";
          
          impact = impact.replaceAll(RegExp(r'Impact Analysis[:\-]*', caseSensitive: false), '').trim();
          action = action.replaceAll(RegExp(r'Quick Action[:\-]*', caseSensitive: false), '').trim();
          
          if (action.isEmpty || action.length < 10) action = "Quick action unavailable.";

          setState(() {
            _impactSummary = impact;
            _actionSummary = action;
            _isFetched = true;
            _isLoading = false;
          });
          updateKeepAlive();
          return;
        }
      }
      setState(() { _error = _mapError("Analysis unavailable."); _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = _mapError(e.toString()); _isLoading = false; });
    }
  }

  Future<void> _logInteraction(String action) async {
    try {
      await http.post(
        Uri.parse("${ApiConstants.authUrl}/api/interactions/log"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userEmail": widget.userEmail, "newsId": widget.articleUrl, "action": action, "platform": "mobile"}),
      );
    } catch (e) {
      if (kDebugMode) print("Error logging: $e");
    }
  }

  void _toggleLike() => setState(() { _isLiked = !_isLiked; if (_isLiked) { _isDisliked = false; _logInteraction("like"); } });
  void _toggleDislike() => setState(() { _isDisliked = !_isDisliked; if (_isDisliked) { _isLiked = false; _logInteraction("dislike"); } });
  void _handleShare() { Share.share("📰 ${widget.title}\n\n🔗 ${widget.articleUrl}\n\n🚀 Read this on PINA App"); _logInteraction("share"); }
  void _handleStickToExpert() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Our expert will contact you soon")));

  @override
  void dispose() { _debounceTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return VisibilityDetector(
      key: widget.key!,
      onVisibilityChanged: _handleVisibilityChanged,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: TemplateTheme.softCard(color: widget.bg, borderColor: widget.border, radius: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.imageUrl.isNotEmpty) ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(widget.imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
            ),
            const SizedBox(height: 10),
            ControllableSmartText(text: widget.title, isExpanded: widget.activeSection == ActiveSection.title, wordLimit: 25, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: widget.titleColor), onExpand: () => widget.onSectionChange(ActiveSection.title)),
            const SizedBox(height: 8),
            ControllableSmartText(text: widget.desc, isExpanded: widget.activeSection == ActiveSection.desc, wordLimit: 25, style: const TextStyle(color: TemplateTheme.textMuted, fontSize: 14, height: 1.5), onExpand: () => widget.onSectionChange(ActiveSection.desc)),
            const Divider(height: 16),
            _buildSectionHeader("Impact Analysis:"),
            if (_isLoading) _buildLoadingIndicator() else if (_error != null) _buildErrorText() else if (_impactSummary != null) ControllableSmartText(text: _impactSummary!, isExpanded: widget.activeSection == ActiveSection.impact, wordLimit: 25, style: const TextStyle(fontSize: 15, height: 1.5, color: TemplateTheme.textPrimary), onExpand: () => widget.onSectionChange(ActiveSection.impact)),
            const SizedBox(height: 16),
            _buildSectionHeader("Quick Actions:"),
            if (_isLoading) _buildLoadingIndicator() else if (_actionSummary != null) ControllableSmartText(text: _actionSummary!, isExpanded: widget.activeSection == ActiveSection.action, wordLimit: 25, style: const TextStyle(fontSize: 15, height: 1.4, color: TemplateTheme.textPrimary), onExpand: () => widget.onSectionChange(ActiveSection.action)),
            const SizedBox(height: 20),
            const Divider(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InkWell(onTap: _toggleLike, child: Padding(padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8), child: Icon(_isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt, color: _isLiked ? TemplateTheme.primary : TemplateTheme.textMuted, size: 24))),
                  InkWell(onTap: _toggleDislike, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Icon(_isDisliked ? Icons.thumb_down : Icons.thumb_down_off_alt, color: _isDisliked ? TemplateTheme.night : TemplateTheme.textMuted, size: 24))),
                  InkWell(onTap: _handleShare, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Icon(Icons.share, color: TemplateTheme.primary, size: 24))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(child: ElevatedButton(onPressed: _handleStickToExpert, style: TemplateTheme.secondaryButtonStyle(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text("Speak to Expert", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: TemplateTheme.textPrimary)));
  Widget _buildLoadingIndicator() => Row(children: [SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: widget.titleColor)), const SizedBox(width: 8), const Text("AI is analyzing...", style: TextStyle(fontSize: 12, color: TemplateTheme.textMuted))]);
  Widget _buildErrorText() => Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12));
}

class ControllableSmartText extends StatelessWidget {
  final String text; final int wordLimit; final TextStyle? style; final bool isExpanded; final VoidCallback onExpand;
  const ControllableSmartText({super.key, required this.text, required this.isExpanded, required this.onExpand, this.wordLimit = 25, this.style});

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    final isLong = words.length > wordLimit;
    if (isExpanded) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(text, style: style)]);
    if (isLong) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${words.take(wordLimit).join(' ')}...", style: style), GestureDetector(onTap: onExpand, child: Padding(padding: const EdgeInsets.only(top: 4, bottom: 4), child: Text("More", style: TextStyle(color: TemplateTheme.primary, fontWeight: FontWeight.w700, fontSize: 14))))]);
    return Text(text, style: style);
  }
}
