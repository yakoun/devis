import 'package:flutter/material.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/features/dashboard/presentation/dashboard_notifier.dart';
import 'package:devis/core/extensions/date_extensions.dart';

class QuantumKpiGrid extends StatelessWidget {
  final DashboardData data;
  const QuantumKpiGrid({super.key, required this.data});

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
                'VUE D\'ENSEMBLE',
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
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  isDark: isDark,
                  label: 'DEVIS EN COURS',
                  value: '${data.devisEnCours}',
                  variation: '+${data.devisCeMois} ce mois',
                  icon: Icons.description_outlined,
                  color: const Color(0xFF4895EF),
                  progress: data.devisEnCours > 0 && data.totalDevis > 0
                      ? data.devisEnCours / data.totalDevis
                      : 0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KpiCard(
                  isDark: isDark,
                  label: 'CLIENTS ACTIFS',
                  value: '${data.clientsActifs}',
                  variation: 'total',
                  icon: Icons.people_outline,
                  color: const Color(0xFF7B61FF),
                  progress: data.clientsActifs > 0 ? 1 : 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  isDark: isDark,
                  label: 'CHIFFRE AFFAIRES',
                  value: '${data.chiffreAffairesTotal.toStringAsFixed(0)} €',
                  variation: '+${(data.chiffreAffairesTotal * 0.12).toStringAsFixed(0)} €',
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF06D6A0),
                  progress: data.monthlyRevenue.isNotEmpty
                      ? (data.monthlyRevenue.last /
                          (data.monthlyRevenue.first > 0
                              ? data.monthlyRevenue.first
                              : 1))
                      : 0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KpiCard(
                  isDark: isDark,
                  label: 'FACTURES IMPAYÉES',
                  value: '${data.unpaidFactures}',
                  variation: '${(data.chiffreAffairesTotal * 0.08).toStringAsFixed(0)} €',
                  icon: Icons.receipt_long_outlined,
                  color: const Color(0xFFF4A261),
                  progress: data.unpaidFactures > 0 ? 1 : 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  isDark: isDark,
                  label: 'DEVIS CE MOIS',
                  value: '${data.devisCeMois}',
                  variation: '${data.totalDevis} total',
                  icon: Icons.add_chart_rounded,
                  color: const Color(0xFFEF476F),
                  progress: data.devisCeMois > 0 && data.totalDevis > 0
                      ? data.devisCeMois / data.totalDevis
                      : 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;
  final String variation;
  final IconData icon;
  final Color color;
  final double progress;

  const _KpiCard({
    required this.isDark,
    required this.label,
    required this.value,
    required this.variation,
    required this.icon,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF132042).withValues(alpha: 0.6),
                  const Color(0xFF0F1A2E).withValues(alpha: 0.3),
                ]
              : [
                  const Color(0xFFFFFFFF).withValues(alpha: 0.9),
                  const Color(0xFFF8F9FA).withValues(alpha: 0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? AppColors.glassBorder : AppColors.lightBorder)
              .withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.1 : 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 12, color: color),
              ),
              _Sparkline(color: color, progress: progress),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: isDark
                      ? AppColors.textOnDarkTertiary
                      : AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                variation,
                style: TextStyle(
                  fontSize: 8,
                  color: color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  final Color color;
  final double progress;

  const _Sparkline({required this.color, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 18,
      child: CustomPaint(
        painter: _SparklinePainter(color: color, progress: progress),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final Color color;
  final double progress;

  _SparklinePainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.08),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final points = <double>[];
    for (int i = 0; i < 10; i++) {
      final t = i / 9;
      final base = progress * size.height * 0.7;
      final wave = ((t * 6.28 + 0.5) % 1.0) * 2 - 1;
      points.add(base + wave * 3);
    }

    path.moveTo(0, size.height - points[0]);
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      path.lineTo(x, size.height - points[i]);
    }

    fillPath.addPath(path, Offset.zero);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    canvas.drawCircle(
      Offset(size.width, size.height - points.last),
      2,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.progress != progress;
}
