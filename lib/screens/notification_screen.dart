import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pina/services/supabase_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';
import 'package:pina/screens/my_ai_screen.dart';

class NotificationScreen extends StatefulWidget {
  final String userEmail;

  const NotificationScreen({super.key, required this.userEmail});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {


  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String get _normalizedUserEmail => widget.userEmail.trim().toLowerCase();
  
  // 🔥 STEP 2: Realtime channel
  RealtimeChannel? _channel;

  // 🔥 STEP 1: ICON MAP - Smart way, no if/else spam
  final Map<String, IconData> typeIcons = {
    "ai_result": Icons.auto_awesome,
    "ready_content": Icons.menu_book,
    "scan_result": Icons.analytics,
    "credit_update": Icons.account_balance_wallet,
    "studyabroad_update": Icons.flight,
    "alert": Icons.warning,
    "promotion": Icons.local_offer,
    "system": Icons.settings,
  };

  // 🔥 STEP 3: NAVIGATION MAP - Smart routing
  final Map<String, String> typeRoutes = {
    "ai_result": "/ai",
    "ready_content": "/ready",
    "scan_result": "/report",
    "credit_update": "/credits",
    "studyabroad_update": "/study-abroad",
    "alert": "/alerts",
    "promotion": "/offers",
  };

  @override
  void initState() {
    super.initState();
      _fetchNotifications();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _setupRealtime();
  });
}

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  // 🔥 STEP 2: Realtime subscription
  void _setupRealtime() {
    _channel = SupabaseService.client
      .channel('public:notifications_screen_${_normalizedUserEmail}')
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

          final newData = Map<String, dynamic>.from(payload.newRecord);

          if (mounted) {
            setState(() {
              _notifications.insert(0, newData);
            });
          }
        },
      )
      .subscribe();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await SupabaseService.client
          .from('notifications')
          .select()
          .eq('user_id', _normalizedUserEmail)
          .order('created_at', ascending: false);

      setState(() {
        _notifications = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching notifications: $e");
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);

      if (mounted) {
        setState(() {
          final index = _notifications.indexWhere((n) => n['id'] == id);
          if (index != -1) {
            _notifications[index]['is_read'] = true;
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error marking as read: $e");
      }
    }
  }

  // 🔥 STEP 3: Smart navigation handler
  void _handleNavigation(Map<String, dynamic> notification) {
    final type = notification['type'];
    
    // Get route from map - default to null if not found
    final route = typeRoutes[type];
    
    if (route != null) {
      // Navigate using named route
      Navigator.pushNamed(context, route);
    } else {
      // Fallback - if no specific route, just show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tap to open: ${notification['title']}"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 🔥 STEP 4: Get formatted time (OPTIONAL but nice)
  String _getFormattedTime(String? dateTimeString) {
    if (dateTimeString == null) return "";
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 7) {
        return "${difference.inDays ~/ 7}w ago";
      } else if (difference.inDays > 0) {
        return "${difference.inDays}d ago";
      } else if (difference.inHours > 0) {
        return "${difference.inHours}h ago";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes}m ago";
      } else {
        return "Just now";
      }
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TemplateBackdrop(
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,

            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(
                color: TemplateTheme.textPrimary,
              ),
              title: const Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TemplateTheme.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
            ),

            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: TemplateTheme.textMuted,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "You're all caught up 🎉",
                              style: TextStyle(
                                color: TemplateTheme.textMuted,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "New notifications will appear here",
                              style: TextStyle(
                                color: TemplateTheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final n = _notifications[index];
                          final isRead = n['is_read'] == true;
                          final notificationType = n['type'] ?? 'default';

                          return GestureDetector(
                            onTap: () {
                              _markAsRead(n['id']);
                              _handleNavigation(n);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🔥 STEP 2: Smart Icon from map
                                  Icon(
                                    typeIcons[notificationType] ?? Icons.notifications,
                                    color: isRead ? Colors.grey : TemplateTheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),

                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          n['title'] ?? 'Notification',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isRead
                                                ? FontWeight.w500
                                                : FontWeight.w700,
                                            color: TemplateTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (n['message'] != null)
                                          Text(
                                            n['message'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: TemplateTheme.textMuted,
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        // 🔥 STEP 5: Time stamp (Optional but nice)
                                        if (n['created_at'] != null)
                                          Text(
                                            _getFormattedTime(n['created_at']),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Unread indicator
                                  if (!isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}
