import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devis/data/providers/providers.dart';
import 'package:devis/services/auth_service.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final Animation<double> _logoAnim;
  late final Animation<double> _subtitleAnim;
  late final Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _logoAnim = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
    );
    _subtitleAnim = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
    );
    _barAnim = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.9, curve: Curves.easeInOut),
    );

    _mainController.forward();

    Future.delayed(const Duration(milliseconds: 4000), () {
      if (!mounted) return;
      _mainController.dispose();
      _navigate();
    });
  }

  Future<void> _navigate() async {
    final isSetupComplete = await ref.read(isSetupCompleteProvider.future);
    if (!mounted) return;

    if (!isSetupComplete) {
      context.go('/setup');
      return;
    }

    final auth = ref.read(authServiceProvider);
    final hasPin = await auth.hasPin();
    if (!mounted) return;

    context.go(hasPin ? '/lock' : '/dashboard');
  }

  @override
  void dispose() {
    if (_mainController.isAnimating) _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _SplashContent(),
    );
  }
}

class _SplashContent extends StatefulWidget {
  const _SplashContent();

  @override
  State<_SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<_SplashContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, _) {
        return CustomPaint(
          painter: _SplashPainter(progress: _particleController.value),
          child: const SizedBox.expand(
            child: _OverlayContent(),
          ),
        );
      },
    );
  }
}

class _OverlayContent extends StatelessWidget {
  const _OverlayContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  _buildLogo(),
                  const SizedBox(height: 40),
                  const _GlowText(),
                  const Spacer(flex: 2),
                  const _LoadingBar(),
                  const SizedBox(height: 40),
                  const _VersionText(),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 100,
      height: 100,
      child: CustomPaint(
        painter: _LogoPainter(),
      ),
    );
  }
}

class _GlowText extends StatelessWidget {
  const _GlowText();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00f3ff), Color(0xFFff00e6), Color(0xFF7000ff)],
                ).createShader(bounds),
                child: Text(
                  'YTech Pro',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF00f3ff).withValues(alpha: 0.4 * value),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: const AlwaysStoppedAnimation(0),
                builder: (context, _) {
                  return Text(
                    'SYSTEM ONLINE',
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 6,
                      color: const Color(0xFF00f3ff).withValues(alpha: 0.6),
                      fontWeight: FontWeight.w300,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LoadingBar extends StatefulWidget {
  const _LoadingBar();

  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _widthAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _widthAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: AnimatedBuilder(
          animation: _widthAnim,
          builder: (context, _) {
            return Stack(
              children: [
                Container(
                  width: 220,
                  height: 3,
                  color: const Color(0xFF1a1a3a),
                ),
                Container(
                  width: 220 * _widthAnim.value,
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00f3ff), Color(0xFFff00e6), Color(0xFF7000ff)],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VersionText extends StatelessWidget {
  const _VersionText();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Opacity(
          opacity: value * 0.5,
          child: const Text(
            'v3.44 | offline-first',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF555555),
              letterSpacing: 1,
            ),
          ),
        );
      },
    );
  }
}

class _Particle {
  final double x, y, radius, speed, phase;
  final Color color;
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.color,
  });
}

class _SplashPainter extends CustomPainter {
  final double progress;
  _SplashPainter({required this.progress});

  final List<_Particle> _particles = [
    _Particle(x: 0.15, y: 0.25, radius: 3, speed: 0.03, phase: 0, color: const Color(0xFF00f3ff)),
    _Particle(x: 0.85, y: 0.5, radius: 2, speed: 0.04, phase: 1.5, color: const Color(0xFFff00e6)),
    _Particle(x: 0.5, y: 0.75, radius: 4, speed: 0.035, phase: 0.8, color: const Color(0xFF7000ff)),
    _Particle(x: 0.08, y: 0.85, radius: 2.5, speed: 0.025, phase: 2.0, color: const Color(0xFF00f3ff)),
    _Particle(x: 0.92, y: 0.12, radius: 3, speed: 0.05, phase: 0.3, color: const Color(0xFFff00e6)),
    _Particle(x: 0.3, y: 0.55, radius: 1.5, speed: 0.02, phase: 1.2, color: const Color(0xFF00f3ff)),
    _Particle(x: 0.7, y: 0.35, radius: 2, speed: 0.045, phase: 0.6, color: const Color(0xFF7000ff)),
    _Particle(x: 0.45, y: 0.15, radius: 2.5, speed: 0.03, phase: 1.8, color: const Color(0xFFff00e6)),
    _Particle(x: 0.6, y: 0.65, radius: 1.5, speed: 0.04, phase: 0.1, color: const Color(0xFF00f3ff)),
    _Particle(x: 0.2, y: 0.45, radius: 2, speed: 0.035, phase: 2.5, color: const Color(0xFF7000ff)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawGrid(canvas, size);
    _drawParticles(canvas, size);
    _drawOrbit(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0a0a1a), Color(0xFF0d0d2b), Color(0xFF0a0a1a)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00f3ff).withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    final offset = (progress * 40) % 40;
    for (double x = -offset; x < size.width + 40; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = -offset; y < size.height + 40; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawParticles(Canvas canvas, Size size) {
    for (final p in _particles) {
      final yOffset = sin((progress * 2 * pi) / p.speed + p.phase) * 30;
      final xOffset = cos((progress * 2 * pi) / (p.speed * 1.5) + p.phase) * 15;
      final alpha = (sin(progress * 3 + p.phase) + 1) / 2;

      canvas.drawCircle(
        Offset(
          p.x * size.width + xOffset,
          p.y * size.height + yOffset,
        ),
        p.radius,
        Paint()..color = p.color.withValues(alpha: alpha * 0.7),
      );
    }
  }

  void _drawOrbit(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.35;

    final outerPaint = Paint()
      ..color = const Color(0xFF00f3ff).withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final innerPaint = Paint()
      ..color = const Color(0xFFff00e6).withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final outerAngle = progress * 2 * pi;
    final innerAngle = -progress * 2 * pi * 1.5;

    canvas.save();
    canvas.translate(cx, cy);

    canvas.drawCircle(Offset.zero, 80, outerPaint);
    canvas.drawCircle(Offset.zero, 60, innerPaint);

    final dot1 = Offset(80 * cos(outerAngle), 80 * sin(outerAngle));
    final dot2 = Offset(60 * cos(innerAngle), 60 * sin(innerAngle));

    canvas.drawCircle(dot1, 3, Paint()..color = const Color(0xFF00f3ff).withValues(alpha: 0.6));
    canvas.drawCircle(dot2, 2, Paint()..color = const Color(0xFFff00e6).withValues(alpha: 0.5));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SplashPainter old) => old.progress != progress;
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = size.width / 100;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    final outerPaint = Paint()
      ..color = const Color(0xFF00f3ff).withValues(alpha: 0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final yPaint = Paint()
      ..color = const Color(0xFF1e1e2f)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final circuitPaint = Paint()
      ..color = const Color(0xFFff6600)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerPaint = Paint()
      ..color = const Color(0xFF0055ff).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFF00f3ff).withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset.zero, 70, outerPaint);

    final yPath = Path()
      ..moveTo(-35, -50)
      ..quadraticBezierTo(-15, -20, 0, 15)
      ..moveTo(35, -50)
      ..quadraticBezierTo(15, -20, 0, 15)
      ..moveTo(0, 15)
      ..lineTo(0, 55);
    canvas.drawPath(yPath, yPaint);

    canvas.drawLine(Offset(-14, 35), Offset(14, 35), circuitPaint);
    canvas.drawLine(Offset(-9, 45), Offset(9, 45), Paint()
      ..color = const Color(0xFFff6600)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round);

    canvas.drawCircle(Offset.zero, 9, centerPaint);

    for (final dot in [(-40, -40), (40, -40), (0, 65)]) {
      canvas.drawCircle(
        Offset(dot.$1.toDouble(), dot.$2.toDouble()),
        dot.$1 == 0 && dot.$2 == 65 ? 3.5 : 4.5,
        Paint()..color = dot.$1 == -40 ? const Color(0xFF0055ff) : (dot.$1 == 40 ? const Color(0xFFff6600) : const Color(0xFF1e1e2f)),
      );
    }

    canvas.drawLine(Offset(-35, -35), Offset(-9, -9), linePaint);
    canvas.drawLine(Offset(35, -35), Offset(9, -9), linePaint);
    canvas.drawLine(Offset(0, 55), Offset(0, 65), linePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LogoPainter old) => false;
}
