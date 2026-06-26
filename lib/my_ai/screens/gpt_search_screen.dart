/// ------------------------------------------------------------
 /// 📁 File: gpt_search_screen.dart
 /// 📂 Module: MyAI (Frontend)
 ///
 /// 🧠 Purpose:
 /// Simple chat-style UI for GPT search widgets.
 ///
 /// ✅ Template Migration Complete
 /// ------------------------------------------------------------
import 'dart:convert';
 import 'package:flutter/material.dart';

 import '../models/widget_model.dart';
 import '../services/myai_api_service.dart';

 class GptSearchScreen extends StatefulWidget {
   final WidgetModel widgetItem;
   final String userEmail;

   const GptSearchScreen({
     super.key,
     required this.widgetItem,
     required this.userEmail,
   });

   @override
   State<GptSearchScreen> createState() => _GptSearchScreenState();
 }

 class _GptSearchScreenState extends State<GptSearchScreen> {
   final MyAiApiService _service = myAiService;
   final TextEditingController _inputController = TextEditingController();
   final List<Map<String, dynamic>> _messages = [];
   bool _isLoading = false;

   Future<void> _sendMessage() async {
     final input = _inputController.text.trim();
     if (input.isEmpty) return;

     final userMessage = {'text': input, 'isUser': true};
     setState(() {
       _messages.add(userMessage);
       _inputController.clear();
       _isLoading = true;
     });

     try {
       final result = await _service.callWidget(
         widget: widget.widgetItem,
         userEmail: widget.userEmail,
         input: input,
       );
       final data = result['data'] ?? result;
       final aiResponse = {'text': data.toString(), 'isUser': false};
       if (mounted) {
         setState(() {
           _messages.add(aiResponse);
         });
       }
     } catch (e) {
       final errorMsg = {'text': 'Error: $e', 'isUser': false};
       if (mounted) {
         setState(() {
           _messages.add(errorMsg);
         });
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: $e')),
         );
       }
     } finally {
       if (mounted) setState(() => _isLoading = false);
     }
   }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
     final isUser = message['isUser'] as bool;
     final theme = Theme.of(context);
     return Align(
       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
       child: Container(
         margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
         decoration: BoxDecoration(
           gradient: isUser ? LinearGradient(
             colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
           ) : null,
           color: isUser ? null : theme.colorScheme.surfaceVariant,
           borderRadius: BorderRadius.circular(20),
           border: Border.all(
             color: theme.colorScheme.outline.withOpacity(0.3),
             width: 1,
           ),
         ),
         child: Text(
           message['text'] as String,
           style: TextStyle(
             height: 1.4,
             fontSize: 15,
             color: isUser ? Colors.white : theme.colorScheme.onSurface,
             fontWeight: FontWeight.w500,
           ),
         ),
       ),
     );
   }

   @override
   Widget build(BuildContext context) {
     final viewInsets = MediaQuery.of(context).viewInsets.bottom;
     final theme = Theme.of(context);

     return Scaffold(
       backgroundColor: theme.scaffoldBackgroundColor,
       appBar: AppBar(
         elevation: 0,
         centerTitle: true,
         title: Text(widget.widgetItem.widgetName),
       ),
       body: SafeArea(
         child: Padding(
           padding: EdgeInsets.only(bottom: viewInsets),
           child: Column(
             children: [
               Expanded(
                 child: ListView.builder(
                   reverse: true,
                   itemCount: _messages.length + (_isLoading ? 1 : 0),
                   itemBuilder: (context, index) {
                     if (_isLoading && index == 0) {
                       return const Padding(
                         padding: EdgeInsets.all(20),
                         child: Center(child: CircularProgressIndicator()),
                       );
                     }
                     return _buildMessageBubble(_messages[_messages.length - 1 - index]);
                   },
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(16),
                 child: Row(
                   children: [
                     Expanded(
                       child: TextField(
                         controller: _inputController,
                         decoration: InputDecoration(
                           labelText: 'Ask anything...',
                           hintText: 'Ask anything...',
                           prefixIcon: Icon(Icons.message_rounded, color: theme.colorScheme.onSurfaceVariant),
                           border: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(12),
                           ),
                           filled: true,
                           fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                         ),
                         onSubmitted: (_) => _sendMessage(),
                       ),
                     ),
                     const SizedBox(width: 12),
                     IconButton(
                       onPressed: _isLoading ? null : _sendMessage,
                       icon: Icon(
                         Icons.send,
                         size: 20,
                       ),
                       style: IconButton.styleFrom(
                         backgroundColor: theme.colorScheme.primary,
                         foregroundColor: Colors.white,
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(12),
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
             ],
           ),
         ),
       ),
     );
   }

   @override
   void dispose() {
     _inputController.dispose();
     super.dispose();
   }
 }

