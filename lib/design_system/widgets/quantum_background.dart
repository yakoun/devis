import 'package:flutter/material.dart';
import '../tokens/colors.dart';

class QuantumBackground extends StatefulWidget {
  final Widget child;

  const QuantumBackground({super.key, required this.child});

  @override
  State<QuantumBackground> createState() => _QuantumBackgroundState();
}

class _QuantumBackgroundState extends State<QuantumBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF081120),
                  const Color(0xFF0F1A2E),
                  _controller.value,
                )!,
                Color.lerp(
                  const Color(0xFF0F1A2E),
                  const Color(0xFF1A2744),
                  _controller.value,
                )!,
                Color.lerp(
                  const Color(0xFF081120),
                  const Color(0xFF132042),
                  _controller.value,
                )!,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
