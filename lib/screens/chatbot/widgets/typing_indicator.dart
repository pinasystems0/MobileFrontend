import 'package:flutter/material.dart';

/// UI-only typing indicator.
///
/// This is shown while the bot is "typing" (visual only).
class TypingIndicator extends StatelessWidget {
  final bool isVisible;

  const TypingIndicator({
    super.key,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final bubbleColor = Colors.white.withOpacity(0.06);
    final borderColor = Colors.white.withOpacity(0.12);

    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _Dot(index: index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int index;

  const _Dot({required this.index});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delay = widget.index * 0.15;
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay,
        1.0,
        curve: Curves.easeInOut,
      ),
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.85 + (curved.value * 0.35),
          child: child,
        );
      },
      child: const SizedBox(
        width: 10,
        height: 10,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

