import 'package:flutter/material.dart';

class BackgroundScreen extends StatelessWidget {
  final Widget child;

  const BackgroundScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/template/Backgrounds/cloud.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}
