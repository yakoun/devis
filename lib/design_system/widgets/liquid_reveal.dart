import 'package:flutter/material.dart';

class LiquidReveal extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Alignment begin;
  final Alignment end;
  final Color backgroundColor;
  final double width;
  final double height;

  const LiquidReveal({
    super.key,
    required this.animation,
    required this.child,
    this.begin = Alignment.bottomCenter,
    this.end = Alignment.topCenter,
    this.backgroundColor = Colors.transparent,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: begin,
              end: end,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.white,
                Colors.white,
              ],
              stops: [
                0.0,
                animation.value * 0.7,
                animation.value * 0.7 + 0.05,
                1.0,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Container(
            width: width,
            height: height,
            color: backgroundColor,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
