import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

class LoadingSteps extends StatefulWidget {
  final List<String> steps;
  final Duration interval;

  const LoadingSteps({
    super.key,
    this.steps = const [
      'Initialisation des modules...',
      'Connexion à la base de données...',
      'Chargement des devis...',
      'Préparation du tableau de bord...',
    ],
    this.interval = const Duration(milliseconds: 800),
  });

  @override
  State<LoadingSteps> createState() => _LoadingStepsState();
}

class _LoadingStepsState extends State<LoadingSteps>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(widget.interval, () {
      if (!mounted) return;
      _controller.forward().then((_) {
        if (!mounted) return;
        setState(() {
          _currentStep = (_currentStep + 1) % widget.steps.length;
        });
        _controller.reverse();
        _startTimer();
      });
    });
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
        final opacity = 1.0 - _controller.value * 0.3;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Text(
            widget.steps[_currentStep],
            key: ValueKey(_currentStep),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.electricCyan.withValues(alpha: opacity),
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }
}
