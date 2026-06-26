/// ------------------------------------------------------------
 /// 📁 File: history_sidebar.dart
 /// 📂 Module: MyAI (Frontend)
 ///
 /// 🧠 Purpose:
 /// Sidebar panel for loading/saving/deleting chat history items.
 ///
 /// ⚙️ Responsibilities:
 /// - Infinite scroll history list
 /// - Per-widget filtering
 /// - Delete individual entries
 /// - Callback to load into screens
 ///
 /// 🔗 Backend Connection:
 /// - Endpoint: /myai/history
 /// - Method: GET/POST/DELETE
 /// - Service Used: myai_api_service.dart (getHistory/saveHistory/deleteHistory)
 ///
 /// ✅ Template Migration Complete (Widget - NO Layout wrap)
 /// ------------------------------------------------------------
 import 'package:flutter/material.dart';

 import 'package:pina/ui_template/utils/template_theme.dart';
 import '../models/widget_model.dart';
 import '../services/myai_api_service.dart';

 class HistorySidebar extends StatefulWidget {
   final String userEmail;
   final String? widgetType;
   final int refreshToken;
   final ValueChanged<Map<String, dynamic>> onHistorySelected;

   const HistorySidebar({
     super.key,
     required this.userEmail,
     this.widgetType,
     required this.refreshToken,
     required this.onHistorySelected,
   });

   @override
   State<HistorySidebar> createState() => _HistorySidebarState();
 }

 class _HistorySidebarState extends State<HistorySidebar> {
   final ScrollController _scrollController = ScrollController();
   List<HistoryModel> history = <HistoryModel>[];
   bool isLoading = false;
   bool isLoadingMore = false;
   bool hasMore = true;
   int currentPage = 1;

   @override
   void initState() {
     super.initState();
     _scrollController.addListener(_onScroll);
     _loadHistory(reset: true);
   }

   @override
   void dispose() {
     _scrollController.dispose();
     super.dispose();
   }

   @override
   void didUpdateWidget(covariant HistorySidebar oldWidget) {
     super.didUpdateWidget(oldWidget);
     final shouldReload = oldWidget.userEmail != widget.userEmail ||
         oldWidget.widgetType != widget.widgetType ||
         oldWidget.refreshToken != widget.refreshToken;

     if (shouldReload) {
       _loadHistory(reset: true);
     }
   }

   void _onScroll() {
     if (!_scrollController.hasClients || !hasMore || isLoading || isLoadingMore) {
       return;
     }

     final threshold = _scrollController.position.maxScrollExtent - 160;
     if (_scrollController.position.pixels >= threshold) {
       _loadHistory(reset: false);
     }
   }

   Future<void> _loadHistory({required bool reset}) async {
     if (reset) {
       setState(() {
         isLoading = true;
         currentPage = 1;
         hasMore = true;
       });
     } else {
       if (isLoading || isLoadingMore || !hasMore) return;
       setState(() => isLoadingMore = true);
     }

     try {
       final list = await myAiService.getHistory(
         widget.userEmail,
         widgetType: widget.widgetType,
         page: currentPage,
         limit: 20,
       );

       final mapped = list
           .whereType<Map>()
           .map((item) => HistoryModel.fromJson(Map<String, dynamic>.from(item)))
           .toList();

       final reachedEnd = mapped.length < 20;
       if (!mounted) return;

       setState(() {
         if (reset) {
           history = mapped;
         } else {
           history = [...history, ...mapped];
         }

         hasMore = !reachedEnd;
         if (!reachedEnd) currentPage += 1;

         isLoading = false;
         isLoadingMore = false;
       });
     } catch (e) {
       if (!mounted) return;

       setState(() {
         isLoading = false;
         isLoadingMore = false;
       });

       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('Failed to load history: ${e.toString().replaceFirst('Exception: ', '')}'),
           action: SnackBarAction(
             label: 'Retry',
             onPressed: () => _loadHistory(reset: reset),
           ),
         ),
       );
     }
   }

   Future<void> _deleteHistory(HistoryModel item) async {
     await myAiService.deleteHistory(item.id, userEmail: widget.userEmail);
     if (!mounted) return;

     setState(() {
       history.removeWhere((entry) => entry.id == item.id);
     });
   }

   String _formatDate(DateTime date) {
     final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
     final minute = date.minute.toString().padLeft(2, '0');
     final suffix = date.hour >= 12 ? 'PM' : 'AM';
     return '${date.day}/${date.month}/${date.year} $hour:$minute $suffix';
   }

   Widget _buildLoadingState() {
     return Center(
       child: CircularProgressIndicator(color: TemplateTheme.accent),
     );
   }

   Widget _buildEmptyState() {
     return Center(
       child: Padding(
         padding: const EdgeInsets.all(24),
         child: Text(
           'No history yet for this widget',
           textAlign: TextAlign.center,
           style: TextStyle(
             color: TemplateTheme.textMuted,
             fontSize: 14,
           ),
         ),
       ),
     );
   }

   Widget _buildHistoryList() {
     return ListView.separated(
       controller: _scrollController,
       itemCount: history.length + (isLoadingMore ? 1 : 0),
       separatorBuilder: (_, __) => const SizedBox(height: 8),
       padding: const EdgeInsets.only(bottom: 24),
       itemBuilder: (context, index) {
         if (index >= history.length) {
           return Padding(
             padding: const EdgeInsets.symmetric(vertical: 16),
             child: Center(child: CircularProgressIndicator(color: TemplateTheme.accent)),
           );
         }

         final item = history[index];
         final preview = item.prompt.isNotEmpty ? item.prompt : item.content;

         return Container(
           margin: const EdgeInsets.symmetric(horizontal: 12),
           decoration: TemplateTheme.softCard(),
           child: ListTile(
             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
             leading: CircleAvatar(
               radius: 18,
               backgroundColor: TemplateTheme.primary.withOpacity(0.1),
               child: Icon(Icons.history_rounded, size: 18, color: TemplateTheme.textMuted),
             ),
             title: Text(
               item.widgetType,
               maxLines: 1,
               overflow: TextOverflow.ellipsis,
               style: TextStyle(
                 fontSize: 14,
                 fontWeight: FontWeight.w600,
                 color: TemplateTheme.textPrimary,
               ),
             ),
             subtitle: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const SizedBox(height: 4),
                 Text(
                   preview,
                   maxLines: 1,
                   overflow: TextOverflow.ellipsis,
                   style: TextStyle(
                     fontSize: 13,
                     color: TemplateTheme.textMuted,
                   ),
                 ),
                 const SizedBox(height: 4),
                 Text(
                   _formatDate(item.createdAt.toLocal()),
                   style: TextStyle(
                     color: TemplateTheme.textMuted,
                     fontSize: 12,
                   ),
                 ),
               ],
             ),
             trailing: PopupMenuButton<String>(
               icon: Icon(Icons.more_vert_rounded, color: TemplateTheme.textMuted),
               onSelected: (value) {
                 if (value == 'delete') {
                   _deleteHistory(item);
                 }
               },
               itemBuilder: (context) => [
                 PopupMenuItem(
                   value: 'delete',
                   child: Text('Delete', style: TextStyle(color: TemplateTheme.textPrimary)),
                 ),
               ],
             ),
             onTap: () => widget.onHistorySelected({
               'id': item.id,
               'promptId': item.promptId,
               'prompt': item.prompt,
               'content': item.content,
               'widgetType': item.widgetType,
               'modelName': item.modelName,
               'createdAt': item.createdAt.toIso8601String(),
             }),
           ),
         );
       },
     );
   }

   @override
   Widget build(BuildContext context) {
     return Container(
       width: 320,
       decoration: TemplateTheme.softCard(),
       child: Column(
         children: [
           Padding(
             padding: const EdgeInsets.all(16),
             child: Row(
               children: [
                 Icon(Icons.history_rounded, color: TemplateTheme.textPrimary, size: 20),
                 const SizedBox(width: 12),
                 Text(
                   'History',
                   style: TextStyle(
                     fontSize: 16,
                     fontWeight: FontWeight.w700,
                     color: TemplateTheme.textPrimary,
                   ),
                 ),
                 const Spacer(),
                 IconButton(
                   tooltip: 'Refresh',
                   onPressed: () => _loadHistory(reset: true),
                   icon: Icon(Icons.refresh_rounded, color: TemplateTheme.textMuted, size: 20),
                 ),
               ],
             ),
           ),
           Expanded(
             child: isLoading
                 ? _buildLoadingState()
                 : history.isEmpty
                     ? _buildEmptyState()
                     : _buildHistoryList(),
           ),
         ],
       ),
     );
   }
 }

