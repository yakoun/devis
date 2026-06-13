import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/features/dashboard/presentation/dashboard_notifier.dart';

class QuantumCharts extends StatelessWidget {
  final DashboardData data;
  const QuantumCharts({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = TextStyle(
      fontSize: 9,
      color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ANALYTICS',
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
          // Revenue curve + Donut
          Row(
            children: [
              Expanded(flex: 3, child: _RevenueChart(isDark: isDark, data: data)),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: _DevisRepartition(isDark: isDark, data: data)),
            ],
          ),
          const SizedBox(height: 8),
          // Monthly performance
          _MonthlyBar(isDark: isDark, data: data),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final bool isDark;
  final DashboardData data;
  const _RevenueChart({required this.isDark, required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(7, (i) {
      final base = 2000.0 + i * 300;
      final variance = (i * i * 0.5) % 500;
      return FlSpot(i.toDouble(), base + variance);
    });

    return Container(
      height: 120,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'REVENUS',
              style: TextStyle(
                fontSize: 8,
                letterSpacing: 1,
                color: isDark
                    ? AppColors.textOnDarkTertiary
                    : AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: (isDark ? AppColors.glassBorder : AppColors.lightBorder)
                        .withValues(alpha: 0.3),
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 4000,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF4895EF),
                    barWidth: 1.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF4895EF).withValues(alpha: 0.15),
                          const Color(0xFF4895EF).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 300),
            ),
          ),
        ],
      ),
    );
  }
}

class _DevisRepartition extends StatelessWidget {
  final bool isDark;
  final DashboardData data;
  const _DevisRepartition({required this.isDark, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEVIS',
            style: TextStyle(
              fontSize: 8,
              letterSpacing: 1,
              color: isDark
                  ? AppColors.textOnDarkTertiary
                  : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 1,
                centerSpaceRadius: 18,
                sections: [
                  PieChartSectionData(
                    value: 45,
                    color: const Color(0xFF4895EF),
                    radius: 14,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 25,
                    color: const Color(0xFF06D6A0),
                    radius: 14,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 20,
                    color: const Color(0xFF7B61FF),
                    radius: 14,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 10,
                    color: const Color(0xFFF4A261),
                    radius: 14,
                    showTitle: false,
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 300),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: const Color(0xFF4895EF), label: 'Brouillon'),
              const SizedBox(width: 6),
              _LegendDot(color: const Color(0xFF06D6A0), label: 'Accepté'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 7,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textOnDarkTertiary
                : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _MonthlyBar extends StatelessWidget {
  final bool isDark;
  final DashboardData data;
  const _MonthlyBar({required this.isDark, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'PERFORMANCE MENSUELLE',
              style: TextStyle(
                fontSize: 8,
                letterSpacing: 1,
                color: isDark
                    ? AppColors.textOnDarkTertiary
                    : AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: (isDark ? AppColors.glassBorder : AppColors.lightBorder)
                        .withValues(alpha: 0.2),
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['J', 'F', 'M', 'A', 'M', 'J'];
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            labels[idx],
                            style: TextStyle(
                              fontSize: 7,
                              color: isDark
                                  ? AppColors.textOnDarkTertiary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        );
                      },
                      reservedSize: 14,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(6, (i) {
                  final values = [0.4, 0.7, 0.5, 0.9, 0.6, 0.8];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        color: const Color(0xFF4895EF).withValues(alpha: 0.7),
                        width: 8,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              duration: const Duration(milliseconds: 300),
            ),
          ),
        ],
      ),
    );
  }
}
