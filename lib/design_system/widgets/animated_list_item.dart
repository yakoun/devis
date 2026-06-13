import 'package:flutter/material.dart';
import '../tokens/spacing.dart';

class AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final int staggerMs;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.staggerMs = 50,
  });

  @override
  Widget build(BuildContext context) {
    final delay = index * staggerMs;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration + Duration(milliseconds: delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * (AppSpacing.lg + AppSpacing.sm)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
