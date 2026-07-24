import 'package:flutter/material.dart';

import '../../controllers/chatbot_controller.dart';


import '../../../ui_template/utils/myai_background.dart';

import 'widgets/chat_bubble.dart';
import 'widgets/message_input.dart';
import 'widgets/typing_indicator.dart';



/// Chatbot UI (UI only; no backend / no API calls).
///
/// This screen is isolated under `lib/screens/chatbot/` to keep the UI structure
/// stable even if backend integration is added later.
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  late final ChatbotController _chatbotController;

  int _lastMessageCount = 0;
  bool _lastTypingState = false;


  @override
  void initState() {
    super.initState();

    // Start with an empty conversation (no welcome message).
    _chatbotController = ChatbotController(initialMessages: const []);


    _lastMessageCount = _chatbotController.messages.length;
    _lastTypingState = _chatbotController.isBotTyping;

    _chatbotController.addListener(() {
      final msgCount = _chatbotController.messages.length;
      final typing = _chatbotController.isBotTyping;

      if (msgCount != _lastMessageCount || typing != _lastTypingState) {
        _lastMessageCount = msgCount;
        _lastTypingState = typing;
        _scrollToBottom();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      _focusNode.requestFocus();
    });
  }


  @override
  void dispose() {
    _chatbotController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (_scrollController.positions.isEmpty) return;

      final max = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        max,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _handleSend() async {
    // Presentation-only: forward to controller; controller owns validation, timing, and replies.
    final rawText = _controller.text;
    await _chatbotController.sendMessage(rawText);

    if (rawText.trim().isNotEmpty) {
      _controller.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    return MyAIBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  centerTitle: false,
                  title: const Text(
                    'Chatbot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(

                  child: AnimatedBuilder(
                    animation: _chatbotController,
                    builder: (context, _) {
                      final messages = _chatbotController.messages;
                      final isBotTyping = _chatbotController.isBotTyping;

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length + (isBotTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= messages.length) {
                            return const SizedBox(height: 8, child: TypingIndicator(isVisible: true));
                          }

                          final msg = messages[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ChatBubble(text: msg.text, isUser: msg.isUser),
                          );
                        },
                      );
                    },
                  ),
                ),

                // (intentionally no suggestion chips / predefined questions)


                // Bottom input
                MessageInput(
                  controller: _controller,
                  focusNode: _focusNode,
                  onSend: () {
                    _handleSend();
                  },

                  onChanged: (_) {},
                ),
                const SizedBox(height: 6),

              ],
            ),
          ),
        ),
      ),
    );
  }
}



