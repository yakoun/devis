import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(BuildContext context, String message,
      {String? actionLabel, VoidCallback? onAction}) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.electricGreen,
      icon: Icons.check_circle_rounded,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void error(BuildContext context, String message,
      {String? actionLabel, VoidCallback? onAction}) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.electricRed,
      icon: Icons.error_rounded,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void info(BuildContext context, String message,
      {String? actionLabel, VoidCallback? onAction}) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.electricBlue,
      icon: Icons.info_rounded,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: AppSpacing.iconMd),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
