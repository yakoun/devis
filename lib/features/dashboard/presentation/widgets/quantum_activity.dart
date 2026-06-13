import 'package:flutter/material.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/features/dashboard/presentation/dashboard_notifier.dart';
import 'package:devis/core/extensions/date_extensions.dart';

class QuantumActivity extends StatelessWidget {
  final List<ActivityItem> activities;
  const QuantumActivity({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ACTIVITÉ RÉCENTE',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  color: isDark
                      ? AppColors.textOnDarkTertiary
                      : AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${activities.length} événements',
                style: TextStyle(
                  fontSize: 8,
                  color: isDark
                      ? AppColors.textOnDarkTertiary
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (activities.isEmpty)
            _EmptyActivity(isDark: isDark)
          else
            ...activities.asMap().entries.map((entry) {
              return _ActivityRow(
                isDark: isDark,
                activity: entry.value,
                isLast: entry.key == activities.length - 1,
              );
            }),
        ],
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  final bool isDark;
  const _EmptyActivity({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF132042).withValues(alpha: 0.3),
                  const Color(0xFF0F1A2E).withValues(alpha: 0.1),
                ]
              : [
                  const Color(0xFFFFFFFF).withValues(alpha: 0.5),
                  const Color(0xFFF8F9FA).withValues(alpha: 0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? AppColors.glassBorder : AppColors.lightBorder)
              .withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 28,
            color: isDark
                ? AppColors.textOnDarkTertiary
                : AppColors.textTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune activité récente',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textOnDarkSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Les actions apparaîtront ici en temps réel',
            style: TextStyle(
              fontSize: 9,
              color: isDark
                  ? AppColors.textOnDarkTertiary
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final bool isDark;
  final ActivityItem activity;
  final bool isLast;

  const _ActivityRow({
    required this.isDark,
    required this.activity,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = activity.color;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.3),
                    border: Border.all(
                      color: color.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 0.5,
                      color: isDark
                          ? AppColors.glassBorder
                          : AppColors.lightBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF132042).withValues(alpha: 0.3),
                          const Color(0xFF0F1A2E).withValues(alpha: 0.1),
                        ]
                      : [
                          const Color(0xFFFFFFFF).withValues(alpha: 0.5),
                          const Color(0xFFF8F9FA).withValues(alpha: 0.3),
                        ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (isDark ? AppColors.glassBorder : AppColors.lightBorder)
                      .withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(activity.icon, size: 12, color: color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textOnDark
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          activity.subtitle,
                          style: TextStyle(
                            fontSize: 8,
                            color: isDark
                                ? AppColors.textOnDarkTertiary
                                : AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    activity.date.formattedShort,
                    style: TextStyle(
                      fontSize: 8,
                      color: isDark
                          ? AppColors.textOnDarkTertiary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
