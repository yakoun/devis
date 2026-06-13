import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/features/dashboard/presentation/dashboard_notifier.dart';

class QuantumHeader extends ConsumerWidget {
  final DashboardData data;
  const QuantumHeader({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = data.computedAt;
    final timeStr = DateFormat('HH:mm', 'fr_FR').format(now);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 48, 16, 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF0F1A2E).withValues(alpha: 0.8),
                  const Color(0xFF132042).withValues(alpha: 0.4),
                ]
              : [
                  const Color(0xFFFFFFFF).withValues(alpha: 0.9),
                  const Color(0xFFF0F2F5).withValues(alpha: 0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isDark ? AppColors.glassBorder : AppColors.lightBorder)
              .withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF06D6A0).withValues(alpha: 0.7)
                    : const Color(0xFF06D6A0),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'SYSTEM ONLINE',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: isDark
                    ? const Color(0xFF06D6A0).withValues(alpha: 0.6)
                    : const Color(0xFF06D6A0),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1,
                color: isDark
                    ? AppColors.textOnDarkTertiary
                    : AppColors.textTertiary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/activities'),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF06D6A0).withValues(alpha: 0.06)
                      : const Color(0xFF06D6A0).withValues(alpha: 0.04),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF06D6A0).withValues(alpha: 0.1)
                        : const Color(0xFF06D6A0).withValues(alpha: 0.08),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 16,
                  color: isDark
                      ? const Color(0xFF06D6A0).withValues(alpha: 0.6)
                      : const Color(0xFF06D6A0),
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => context.push('/settings'),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.glassBorder.withValues(alpha: 0.3)
                      : AppColors.lightBorder.withValues(alpha: 0.3),
                  border: Border.all(
                    color: isDark
                        ? AppColors.glassBorder
                        : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  size: 16,
                  color: isDark
                      ? AppColors.textOnDarkSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
