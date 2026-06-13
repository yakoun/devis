import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import 'liquid_reveal.dart';

class AnimatedLogo extends StatelessWidget {
  final Animation<double> animation;
  final double size;

  const AnimatedLogo({
    super.key,
    required this.animation,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidReveal(
      animation: animation,
      width: size,
      height: size,
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.electricBlue, AppColors.electricPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricCyan.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: AppColors.electricBlue.withValues(alpha: 0.3),
              blurRadius: 40,
              spreadRadius: 8,
            ),
          ],
        ),
        child: const Icon(
          Icons.bolt_rounded,
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }
}
