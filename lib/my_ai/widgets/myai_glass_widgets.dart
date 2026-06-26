import 'dart:ui';

import 'package:flutter/material.dart';

import '../../ui_template/utils/myai_background.dart';

// ============================================================
// MAIN SCREEN COMPONENT (FULLY FIXED)
// ============================================================

class MyAiGlassScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;
  final bool showBackButton;
  final FloatingActionButton? floatingActionButton;

  const MyAiGlassScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions = const [],
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 20),
    this.showBackButton = true,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ FIXED: true for proper keyboard handling
      backgroundColor: Colors.transparent,
      floatingActionButton: floatingActionButton,
      body: MyAIBackground(
        child: SafeArea(
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MyAiHeader(
                  title: title,
                  subtitle: subtitle,
                  actions: actions,
                  showBackButton: showBackButton,
                ),
                const SizedBox(height: 20),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// GLASS PANEL (KEPT FOR OTHER USES)
// ============================================================

class MyAiGlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color borderColor;
  final Gradient? gradient;

  const MyAiGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.borderColor = const Color(0x33FFFFFF),
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: borderColor),
            gradient: gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.18),
                    Colors.white.withOpacity(0.08),
                  ],
                ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B7CFF).withOpacity(0.18),
                blurRadius: 36,
                spreadRadius: 2,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================================
// GRADIENT BUTTON
// ============================================================

class MyAiGradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const MyAiGradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8A7CFF), Color(0xFF44D7FF)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF44D7FF).withOpacity(0.26),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white70,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: child,
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class MyAiEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const MyAiEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Icon(icon, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  height: 1.4,
                ),
              ),
              if (action != null) ...[
                const SizedBox(height: 18),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SEARCH FIELD
// ============================================================

class MyAiSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final VoidCallback? onClear;

  const MyAiSearchField({
    super.key,
    required this.controller,
    this.onChanged,
    required this.hintText,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.black45,
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Colors.black54,
            size: 22,
          ),
          suffixIcon: controller.text.trim().isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.black54,
                    size: 20,
                  ),
                ),
        ),
      ),
    );
  }
}

// ============================================================
// META CHIP
// ============================================================

class MyAiMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const MyAiMetaChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.78)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.86),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class _MyAiHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final bool showBackButton;

  const _MyAiHeader({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBackButton && canPop) ...[
          _GlassIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.76),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(width: 12),
          Wrap(spacing: 10, runSpacing: 10, children: actions),
        ],
      ],
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ============================================================
// CHAT COMPOSER (🔥 SUPER SMOOTH WITH ANIMATION)
// ============================================================

class MyAiChatComposer extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final bool isLoading;

  const MyAiChatComposer({
    super.key,
    required this.controller,
    this.onSend,
    this.onChanged,
    this.hintText = 'Type a message...',
    this.isLoading = false,
  });

  @override
  State<MyAiChatComposer> createState() => _MyAiChatComposerState();
}

class _MyAiChatComposerState extends State<MyAiChatComposer> {
  @override
  Widget build(BuildContext context) {
    // 🔥 SUPER SMOOTH - Animated padding that follows keyboard
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200), // Smooth animation
      curve: Curves.easeOut, // Natural easing curve
      padding: EdgeInsets.only(
        // ✅ DYNAMIC padding based on keyboard height
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      child: SafeArea(
        top: false,
        child: MyAiGlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  onChanged: widget.onChanged,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: 8),
              MyAiGradientButton(
                onPressed: widget.isLoading ? null : widget.onSend,
                padding: const EdgeInsets.all(12),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EXAMPLE: CHAT SCREEN (🔥 FULLY OPTIMIZED)
// ============================================================

class ExampleChatScreen extends StatefulWidget {
  const ExampleChatScreen({super.key});

  @override
  State<ExampleChatScreen> createState() => _ExampleChatScreenState();
}

class _ExampleChatScreenState extends State<ExampleChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hello! How can I help you?', 'isUser': false},
    {'text': 'What is AI?', 'isUser': true},
    {'text': 'AI stands for Artificial Intelligence...', 'isUser': false},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text.trim(),
          'isUser': true,
        });
        _messageController.clear();
      });
      // Simulate AI response
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add({
            'text': 'This is a response to: ${_messages.last['text']}',
            'isUser': false,
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyAiGlassScreen(
      title: 'AI Assistant',
      subtitle: 'Ask me anything...',
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isUser = message['isUser'] as bool;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: MyAiGlassPanel(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        message['text'] as String,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          MyAiChatComposer(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}