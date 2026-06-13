import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const AnimatedStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isCompleted
                ? const Color(0xFF00D4FF)
                : isActive
                    ? const Color(0xFF7B61FF)
                    : Colors.white24,
          ),
        );
      }),
    );
  }
}

class StepTransition extends StatelessWidget {
  final int step;
  final Widget child;

  const StepTransition({
    super.key,
    required this.step,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.15, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(step),
        child: child,
      ),
    );
  }
}

class ParticleBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;

  const ParticleBackground({
    super.key,
    required this.child,
    this.particleCount = 20,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _ParticlePainter(
                progress: _controller.value,
                particleCount: widget.particleCount,
              ),
              child: child,
            );
          },
          child: widget.child,
        ),
      ],
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final int particleCount;

  _ParticlePainter({required this.progress, required this.particleCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final x = (sin(progress * 2 * pi + i * 1.7) * 0.5 + 0.5) * size.width;
      final y = (cos(progress * 1.3 * pi + i * 2.3) * 0.5 + 0.5) * size.height;
      final radius = (sin(progress * pi + i * 0.7) * 0.5 + 0.5) * 2 + 1;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = const Color(0xFF00D4FF).withValues(alpha: 0.1 + sin(progress * pi + i) * 0.05),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
