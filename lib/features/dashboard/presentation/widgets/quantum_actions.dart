import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:devis/design_system/design_system.dart';

class QuantumQuickActions extends StatelessWidget {
  const QuantumQuickActions({super.key});

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
                'ACTIONS RAPIDES',
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionButton(
                isDark: isDark,
                icon: Icons.description_outlined,
                label: 'Nouveau devis',
                color: const Color(0xFF4895EF),
                onTap: () => context.push('/devis/create'),
              ),
              _ActionButton(
                isDark: isDark,
                icon: Icons.person_add_outlined,
                label: 'Nouveau client',
                color: const Color(0xFF7B61FF),
                onTap: () => context.push('/clients'),
              ),
              _ActionButton(
                isDark: isDark,
                icon: Icons.receipt_outlined,
                label: 'Nouvelle facture',
                color: const Color(0xFF06D6A0),
                onTap: () => context.push('/factures'),
              ),
              _ActionButton(
                isDark: isDark,
                icon: Icons.construction_outlined,
                label: 'Nouveau chantier',
                color: const Color(0xFFEF476F),
                onTap: () => context.push('/chantiers'),
              ),
              _ActionButton(
                isDark: isDark,
                icon: Icons.show_chart_rounded,
                label: 'Finances',
                color: const Color(0xFFFFD166),
                onTap: () => context.push('/finance'),
              ),
              _ActionButton(
                isDark: isDark,
                icon: Icons.settings_rounded,
                label: 'Paramètres',
                color: const Color(0xFF9CA3AF),
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: isDark ? 0.08 : 0.06),
              color.withValues(alpha: isDark ? 0.02 : 0.01),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.15 : 0.1),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textOnDarkSecondary
                    : AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
