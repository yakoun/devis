import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/shadows.dart';
import '../tokens/gradients.dart';
import '../tokens/spacing.dart';

class ElectricCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final bool hasGlow;
  final bool isDark;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;

  const ElectricCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.hasGlow = false,
    this.isDark = true,
    this.onTap,
    this.gradient,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = isDark;
    final card = Container(
      height: height,
      width: width,
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient ?? AppGradients.card(isDarkMode),
          borderRadius: BorderRadius.circular(12),
          boxShadow: shadows ?? AppShadows.card,
          border: Border.all(
            color: isDarkMode
                ? AppColors.darkBorder.withValues(alpha: 0.5)
                : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      child: child,
    );

    if (onTap != null) {
      return Semantics(
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: card,
          ),
        ),
      );
    }

    return card;
  }
}

class GlowButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Gradient? gradient;
  final double? height;

  const GlowButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.gradient,
    this.height,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Semantics(
        button: true,
        label: widget.label,
        child: GestureDetector(
          onTapDown: widget.onPressed != null && !widget.isLoading
              ? (_) => _controller.forward()
              : null,
          onTapUp: widget.onPressed != null && !widget.isLoading
              ? (_) {
                  _controller.reverse();
                  widget.onPressed?.call();
                }
              : null,
          onTapCancel: () => _controller.reverse(),
          child: Container(
            height: widget.height ?? 52,
            width: widget.isFullWidth ? double.infinity : null,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxxl, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              gradient: widget.gradient ??
                  const LinearGradient(
                    colors: [Color(0xFF4895EF), Color(0xFF7B61FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4895EF).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon,
                              size: 20,
                              color: Colors.white),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Text(
                          widget.label,
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class CountBadge extends StatelessWidget {
  final int count;
  final bool isDark;
  final Color? color;

  const CountBadge({
    super.key,
    required this.count,
    this.isDark = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (color ?? AppColors.accent).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.accent,
        ),
      ),
    );
  }
}

class AnimatedStatCard extends StatefulWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color iconColor;
  final String? prefix;
  final String? suffix;
  final int decimals;

  const AnimatedStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.prefix,
    this.suffix,
    this.decimals = 0,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedStatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
            ),
            child: Icon(widget.icon, color: widget.iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              final displayValue =
                  (widget.value * _animation.value).toStringAsFixed(widget.decimals);
              return Text(
                '${widget.prefix ?? ''}$displayValue${widget.suffix ?? ''}',
                style: AppTypography.titleLarge.copyWith(
                  color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            widget.label,
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textOnDarkSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final dynamic prefixIcon;
  final dynamic suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool isDense;
  final TextInputAction? textInputAction;
  final VoidCallback? onSuffixTap;
  final VoidCallback? onPrefixTap;

  Widget? _wrapIcon(dynamic icon, VoidCallback? onTap) {
    if (icon == null) return null;
    if (icon is IconData) {
      if (onTap != null) {
        return IconButton(
          icon: Icon(icon),
          onPressed: onTap,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }
      return Icon(icon);
    }
    if (icon is Widget) {
      if (onTap != null) {
        return IconButton(
          icon: icon,
          onPressed: onTap,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }
      return icon;
    }
    return null;
  }

  const PremiumTextField({
    super.key,
    this.label = '',
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.enabled = true,
    this.isDense = false,
    this.textInputAction,
    this.onSuffixTap,
    this.onPrefixTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
          TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          enabled: enabled,
          textInputAction: textInputAction,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: _wrapIcon(prefixIcon, onPrefixTap),
            suffixIcon: _wrapIcon(suffixIcon, onSuffixTap),
            isDense: isDense,
            filled: true,
            fillColor: isDark
                ? AppColors.darkSurfaceLight.withValues(alpha: 0.5)
                : AppColors.lightCard,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
              borderSide: const BorderSide(
                color: Color(0xFF4895EF),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
              borderSide: const BorderSide(color: Color(0xFFEF476F)),
            ),
          ),
        ),
      ],
    );
  }
}

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final bool isDark;
  final List<Widget>? actions;
  final Widget? leading;
  final double elevation;

  const PremiumAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.isDark = false,
    this.actions,
    this.leading,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: isDark ? AppColors.textOnDark : AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      leading: showBack
          ? leading ??
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              )
          : leading,
      title: Text(
        title,
        style: AppTypography.titleLarge.copyWith(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String? status;
  final String? label;
  final Color? color;
  final bool isDark;

  const StatusBadge({
    super.key,
    this.status,
    this.label,
    this.color,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final (badgeColor, badgeLabel) = status != null ? _statusConfig(status!) : (color ?? AppColors.accent, label ?? '');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Text(
        badgeLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: badgeColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  (Color, String) _statusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'brouillon':
        return (AppColors.accentOrange, 'Brouillon');
      case 'envoyé':
      case 'envoye':
        return (AppColors.accent, 'Envoyé');
      case 'accepté':
      case 'accepte':
        return (AppColors.accentGreen, 'Accepté');
      case 'refusé':
      case 'refuse':
        return (AppColors.accentRed, 'Refusé');
      case 'payé':
      case 'paye':
      case 'payee':
        return (AppColors.accentGreen, 'Payé');
      case 'impayée':
      case 'impayee':
        return (AppColors.accentRed, 'Impayé');
      case 'partielle':
        return (AppColors.accentOrange, 'Partiel');
      default:
        return (AppColors.accent, status);
    }
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textOnDarkSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
