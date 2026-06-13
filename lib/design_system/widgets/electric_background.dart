import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens/colors.dart';

class ElectricBackground extends StatefulWidget {
  final Widget child;
  final bool blur;

  const ElectricBackground({super.key, required this.child, this.blur = true});

  @override
  State<ElectricBackground> createState() => _ElectricBackgroundState();
}

class _ElectricBackgroundState extends State<ElectricBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
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
      builder: (context, child) {
        final t = _controller.value;
        final dx = 0.3 + 0.4 * math.sin(t * math.pi * 2);
        final dy = 0.3 + 0.4 * math.cos(t * math.pi * 1.7);
        final dx2 = 0.6 + 0.3 * math.sin(t * math.pi * 2 + 1.2);
        final dy2 = 0.5 + 0.3 * math.cos(t * math.pi * 1.3 + 0.8);
        final dx3 = 0.5 + 0.35 * math.sin(t * math.pi * 2.3 + 2.1);
        final dy3 = 0.7 + 0.25 * math.cos(t * math.pi * 1.9 + 1.4);
        final pulse = 0.6 + 0.4 * math.sin(t * math.pi * 2);
        final pulse2 = 0.5 + 0.5 * math.sin(t * math.pi * 2 + 0.5);
        final pulse3 = 0.4 + 0.6 * math.sin(t * math.pi * 2 + 1.0);

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(dx, dy),
              radius: 1.2,
              colors: [
                Color.lerp(
                  AppColors.electricBlue.withValues(alpha: pulse * 0.15),
                  AppColors.electricCyan.withValues(alpha: pulse * 0.1),
                  t,
                )!,
                Color.lerp(
                  AppColors.electricPurple.withValues(alpha: pulse2 * 0.1),
                  AppColors.electricBlue.withValues(alpha: pulse2 * 0.08),
                  t,
                )!,
                AppColors.darkBackground,
                AppColors.darkBackground,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: MediaQuery.of(context).size.width * dx2,
                top: MediaQuery.of(context).size.height * dy2,
                child: _Halo(
                  color: AppColors.electricCyan.withValues(alpha: pulse3 * 0.12),
                  radius: 120 + 40 * math.sin(t * math.pi * 2),
                ),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * dx3,
                top: MediaQuery.of(context).size.height * dy3,
                child: _Halo(
                  color: AppColors.electricPurple.withValues(alpha: pulse * 0.1),
                  radius: 100 + 30 * math.sin(t * math.pi * 2 + 1.5),
                ),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * 0.8,
                top: MediaQuery.of(context).size.height * 0.15,
                child: _Halo(
                  color: AppColors.electricBlue.withValues(alpha: pulse2 * 0.08),
                  radius: 90 + 50 * math.sin(t * math.pi * 2 + 0.3),
                ),
              ),
              if (widget.blur)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                    child: const SizedBox.expand(),
                  ),
                ),
              if (child != null) child,
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _Halo extends StatelessWidget {
  final Color color;
  final double radius;

  const _Halo({required this.color, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: radius * 0.8,
            spreadRadius: radius * 0.3,
          ),
        ],
      ),
    );
  }
}
