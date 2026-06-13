import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devis/features/dashboard/presentation/dashboard_notifier.dart';
import 'package:devis/features/dashboard/presentation/widgets/quantum_header.dart';
import 'package:devis/features/dashboard/presentation/widgets/quantum_kpi.dart';
import 'package:devis/features/dashboard/presentation/widgets/quantum_charts.dart';
import 'package:devis/features/dashboard/presentation/widgets/quantum_activity.dart';
import 'package:devis/features/dashboard/presentation/widgets/quantum_insights.dart';
import 'package:devis/data/providers/providers.dart';
import 'package:devis/design_system/design_system.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  Future<void> _refresh() async {
    invalidateAllProviders(ref);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncData = ref.watch(dashboardProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: asyncData.when(
          loading: () => _buildLoading(isDark),
          error: (e, _) => _buildError(e.toString(), isDark),
          data: (data) => RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFF4895EF),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuantumHeader(data: data),
                  const SizedBox(height: 12),
                  _QuickActionRow(),
                  const SizedBox(height: 16),
                  QuantumKpiGrid(data: data),
                  const SizedBox(height: 20),
                  QuantumCharts(data: data),
                  const SizedBox(height: 20),
                  QuantumActivity(activities: data.recentActivity),
                  const SizedBox(height: 20),
                  QuantumInsights(data: data),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isDark
                  ? const Color(0xFF4895EF).withValues(alpha: 0.6)
                  : const Color(0xFF4895EF),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Chargement du tableau de bord...',
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.textOnDarkTertiary
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: isDark
                  ? const Color(0xFFEF476F).withValues(alpha: 0.6)
                  : const Color(0xFFEF476F),
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 9,
                color: isDark
                    ? AppColors.textOnDarkTertiary
                    : AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => ref.invalidate(dashboardProvider),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4895EF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4895EF).withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  'RÉESSAYER',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1,
                    color: isDark
                        ? const Color(0xFF4895EF).withValues(alpha: 0.8)
                        : const Color(0xFF4895EF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actions = [
      (Icons.add_circle_rounded, 'Devis', const Color(0xFF4895EF), '/devis/create'),
      (Icons.person_add_rounded, 'Client', const Color(0xFF06D6A0), '/clients'),
      (Icons.build_rounded, 'Chantier', const Color(0xFFF4A261), '/chantiers'),
      (Icons.receipt_long_rounded, 'Facture', const Color(0xFF7B61FF), '/factures'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: actions.map((a) {
          final (icon, label, color, route) = a;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _DashQuickBtn(
                icon: icon,
                label: label,
                color: color,
                isDark: isDark,
                onTap: () => context.push(route),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DashQuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _DashQuickBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
