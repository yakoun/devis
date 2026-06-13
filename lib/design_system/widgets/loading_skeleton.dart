import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';

class _ShimmerAnimated extends StatefulWidget {
  final bool isDark;
  final Widget child;

  const _ShimmerAnimated({required this.isDark, required this.child});

  @override
  State<_ShimmerAnimated> createState() => _ShimmerAnimatedState();
}

class _ShimmerAnimatedState extends State<_ShimmerAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<Alignment>(
      begin: const Alignment(-2, 0),
      end: const Alignment(2, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.06),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: _animation.value,
              end: Alignment(-_animation.value.x, -_animation.value.y),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcOver,
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final bool isDark;
  final int itemCount;
  final Widget Function(int index) itemBuilder;

  const ShimmerLoading({
    super.key,
    required this.isDark,
    this.itemCount = 3,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return _ShimmerAnimated(
      isDark: isDark,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: itemCount,
        itemBuilder: (context, index) => itemBuilder(index),
      ),
    );
  }
}

class SkeletonDevisCard extends StatelessWidget {
  final bool isDark;

  const SkeletonDevisCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _bar(120, 16),
              _bar(80, 24, borderRadius: 100),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _bar(180, 14),
          const SizedBox(height: AppSpacing.xs),
          _bar(100, 12),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _bar(100, 16),
              _bar(80, 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar(double width, double height, {double borderRadius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SkeletonClientCard extends StatelessWidget {
  final bool isDark;

  const SkeletonClientCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(140, 16),
                const SizedBox(height: AppSpacing.sm),
                _bar(100, 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class SkeletonDashboardGrid extends StatelessWidget {
  final bool isDark;

  const SkeletonDashboardGrid({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildWelcomeSkeleton(),
          const SizedBox(height: AppSpacing.xxl),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            children: List.generate(4, (_) => _buildStatSkeleton()),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSkeleton() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
      ),
    );
  }

  Widget _buildStatSkeleton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
            ),
          ),
          const Spacer(),
          _bar(60, 20),
          const SizedBox(height: AppSpacing.xs),
          _bar(80, 12),
        ],
      ),
    );
  }

  Widget _bar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class SkeletonFinanceCard extends StatelessWidget {
  final bool isDark;

  const SkeletonFinanceCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            children: List.generate(4, (_) => _buildStatCard()),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildChartPlaceholder(),
          const SizedBox(height: AppSpacing.lg),
          _buildChartPlaceholder(),
          const SizedBox(height: AppSpacing.lg),
          _buildChartPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildStatCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
      ),
    );
  }
}
