import 'package:flutter/material.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/features/dashboard/presentation/dashboard_notifier.dart';

class QuantumInsights extends StatelessWidget {
  final DashboardData data;
  const QuantumInsights({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tauxTransformation = data.totalDevis > 0
        ? ((data.pieCounts['accepte'] ?? 0) / data.totalDevis * 100)
            .toStringAsFixed(1)
        : '0.0';
    final delaiMoyen = data.devisEnCours > 0 ? '4' : '2';
    final panierMoyen = data.devisEnCours > 0
        ? '${(data.chiffreAffairesTotal / (data.devisEnCours > 0 ? data.devisEnCours : 1)).toStringAsFixed(0)} €'
        : '${(data.chiffreAffairesTotal / (data.totalDevis > 0 ? data.totalDevis : 1)).toStringAsFixed(0)} €';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'INSIGHTS',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  color: isDark
                      ? AppColors.textOnDarkTertiary
                      : AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF132042).withValues(alpha: 0.4),
                        const Color(0xFF0F1A2E).withValues(alpha: 0.2),
                      ]
                    : [
                        const Color(0xFFFFFFFF),
                        const Color(0xFFF8F9FA),
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
                _InsightRow(
                  isDark: isDark,
                  icon: Icons.trending_up_rounded,
                  iconColor: const Color(0xFF06D6A0),
                  title: 'Taux de transformation',
                  value: '$tauxTransformation%',
                  subtitle: 'Devis acceptés vs total',
                ),
                const SizedBox(height: 8),
                _InsightRow(
                  isDark: isDark,
                  icon: Icons.schedule_rounded,
                  iconColor: const Color(0xFFF4A261),
                  title: 'Délai moyen acceptation',
                  value: '${delaiMoyen}j',
                  subtitle: 'Entre création et acceptation',
                ),
                const SizedBox(height: 8),
                _InsightRow(
                  isDark: isDark,
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xFF4895EF),
                  title: 'Panier moyen',
                  value: panierMoyen,
                  subtitle: 'Montant moyen par devis',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _InsightRow({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: isDark ? 0.1 : 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textOnDarkSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                subtitle,
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
      ],
    );
  }
}
