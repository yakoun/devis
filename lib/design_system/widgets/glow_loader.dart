import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../tokens/colors.dart';

class GlowLoader extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const GlowLoader({
    super.key,
    this.size = 48,
    this.strokeWidth = 3.5,
    this.color,
  });

  @override
  State<GlowLoader> createState() => _GlowLoaderState();
}

class _GlowLoaderState extends State<GlowLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _GlowLoaderPainter(
              progress: _controller.value,
              strokeWidth: widget.strokeWidth,
              color: widget.color ?? AppColors.electricBlue,
            ),
          );
        },
      ),
    );
  }
}

class _GlowLoaderPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _GlowLoaderPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.7;
    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = (math.pi * 2 * 0.75);
    final startAngle = -math.pi / 2 + progress * math.pi * 2;

    final gradientPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.3),
          color,
          color,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      gradientPaint,
    );

    final endAngle = startAngle + sweepAngle;
    final dotX = center.dx + radius * math.cos(endAngle);
    final dotY = center.dy + radius * math.sin(endAngle);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(dotX, dotY), strokeWidth * 1.2, dotPaint);

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(dotX, dotY), strokeWidth * 2.5, glowPaint);
  }

  @override
  bool shouldRepaint(_GlowLoaderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
