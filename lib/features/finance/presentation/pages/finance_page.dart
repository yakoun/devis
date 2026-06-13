import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/core/extensions/num_extensions.dart';
import 'package:devis/data/providers/providers.dart';
import 'package:devis/data/models/transaction.dart';
import 'package:devis/core/utils/enums.dart';

class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage> {
  final _libelleCtrl = TextEditingController();
  final _montantCtrl = TextEditingController();
  final _categorieCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isDepense = true;
  PaiementMode _modePaiement = PaiementMode.especes;

  Future<void> _refresh() async {
    ref.invalidate(facturesProvider);
    ref.invalidate(transactionsProvider);
    ref.invalidate(chantiersProvider);
  }

  void _showAddTransaction(BuildContext context, bool isDark) {
    _libelleCtrl.clear();
    _montantCtrl.clear();
    _categorieCtrl.clear();
    _notesCtrl.clear();
    _isDepense = true;
    _modePaiement = PaiementMode.especes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: StatefulBuilder(
          builder: (context, setD) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(width: 36, height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(_isDepense ? 'Nouvelle dépense' : 'Nouveau revenu',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _TypeToggle(label: 'Dépense', active: _isDepense, color: const Color(0xFFEF476F), onTap: () => setD(() => _isDepense = true)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _TypeToggle(label: 'Revenu', active: !_isDepense, color: const Color(0xFF06D6A0), onTap: () => setD(() => _isDepense = false)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        PremiumTextField(controller: _libelleCtrl, label: 'Libellé', hint: 'Ex: Prestation X'),
                        const SizedBox(height: 10),
                        PremiumTextField(controller: _montantCtrl, label: 'Montant', hint: '0', keyboardType: TextInputType.number),
                        const SizedBox(height: 10),
                        PremiumTextField(controller: _categorieCtrl, label: 'Catégorie', hint: 'Ex: Matériel, Transport'),
                        const SizedBox(height: 10),
                        PremiumTextField(controller: _notesCtrl, label: 'Notes (optionnel)', hint: ''),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _saveTransaction(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isDepense ? const Color(0xFFEF476F) : const Color(0xFF06D6A0),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Enregistrer', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveTransaction(BuildContext context) async {
    final libelle = _libelleCtrl.text.trim();
    final montantStr = _montantCtrl.text.trim();
    final categorie = _categorieCtrl.text.trim();
    if (libelle.isEmpty || montantStr.isEmpty || categorie.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Remplissez tous les champs')));
      return;
    }
    final montant = double.tryParse(montantStr.replaceAll(' ', '')) ?? 0;
    if (montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Montant invalide')));
      return;
    }
    try {
      final repo = ref.read(hiveRepositoryProvider);
      final t = Transaction.create(
        libelle: libelle,
        montant: montant,
        categorie: categorie,
        isDepense: _isDepense,
        modePaiement: _modePaiement,
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      );
      await repo.saveTransaction(t);
      ref.invalidate(transactionsProvider);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final facturesAsync = ref.watch(facturesProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final chantiersAsync = ref.watch(chantiersProvider);
    final devisAsync = ref.watch(devisProvider);

    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Finance',
        showBack: false,
        isDark: isDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () => _showAddTransaction(context, isDark),
        backgroundColor: const Color(0xFF4895EF),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: facturesAsync.when(
        loading: () => ShimmerLoading(
          isDark: isDark,
          itemCount: 1,
          itemBuilder: (index) => SkeletonFinanceCard(isDark: isDark),
        ),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (factures) {
          final devis = devisAsync.asData?.value ?? [];
          if (factures.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const EmptyState(
                      icon: Icons.account_balance_rounded,
                      title: 'Pas encore de données',
                      subtitle: 'Les graphiques s\'afficheront dès vos premières factures',
                    ),
                  ),
                ],
              ),
            );
          }

          final transactions = transactionsAsync.asData?.value ?? [];
          final chantiers = chantiersAsync.asData?.value ?? [];

          final chiffreAffaires = factures
              .where((f) => f.statut == FactureStatus.payee)
              .fold<double>(0, (sum, f) => sum + f.total);
          final totalFacture = factures
              .fold<double>(0, (sum, f) => sum + f.total);
          final enAttente = factures
              .where((f) =>
                  f.statut == FactureStatus.impayee ||
                  f.statut == FactureStatus.partielle)
              .length;
          final chantiersActifs = chantiers
              .where((c) => c.statut == ChantierStatus.enCours)
              .length;

          final now = DateTime.now();
          final moisLabels = [
            'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
            'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
          ];

          final revenusParMois = List.generate(6, (i) {
            final m = now.month - 5 + i;
            final year = now.year + (m - 1) ~/ 12;
            final month = ((m - 1) % 12) + 1;
            return factures
                .where((f) =>
                    f.statut == FactureStatus.payee &&
                    f.dateEmission.month == month &&
                    f.dateEmission.year == year)
                .fold<double>(0, (sum, f) => sum + f.total);
          }).toList();

          final depensesParMois = List.generate(6, (i) {
            final m = now.month - 5 + i;
            final year = now.year + (m - 1) ~/ 12;
            final month = ((m - 1) % 12) + 1;
            return transactions
                .where((t) =>
                    t.isDepense &&
                    t.date.month == month &&
                    t.date.year == year)
                .fold<double>(0, (sum, t) => sum + t.montant);
          }).toList();

          final revenueTotal = revenusParMois.fold<double>(0, (a, b) => a + b);
          final expenseTotal = depensesParMois.fold<double>(0, (a, b) => a + b);
          final margeBrute = revenueTotal - expenseTotal;
          final margePct = revenueTotal > 0 ? (margeBrute / revenueTotal * 100) : 0.0;

          var cumulative = 0.0;
          final cashflowSpots = List.generate(6, (i) {
            cumulative += revenusParMois[i] - depensesParMois[i];
            return FlSpot(i.toDouble(), cumulative / 1000000);
          });

          final maxRev = revenusParMois.isNotEmpty
              ? revenusParMois.reduce(max)
              : 0.0;
          final bestMonthIndex = revenusParMois.isNotEmpty
              ? revenusParMois.indexOf(maxRev)
              : 0;
          final bestMonth = revenusParMois.isNotEmpty
              ? moisLabels[(now.month - 6 + bestMonthIndex + 12) % 12]
              : '-';

          final croissance = revenusParMois.length >= 2
              ? revenusParMois.last - revenusParMois[revenusParMois.length - 2]
              : 0.0;
          final croissancePct = revenusParMois.length >= 2 &&
                  revenusParMois[revenusParMois.length - 2] > 0
              ? ((croissance / revenusParMois[revenusParMois.length - 2]) * 100)
              : 0.0;

          final prevision = revenusParMois.length >= 2
              ? (revenusParMois.last * 2) - revenusParMois[revenusParMois.length - 2]
              : revenusParMois.isNotEmpty
                  ? revenusParMois.last
                  : 0.0;

          final payee = factures.where((f) => f.statut == FactureStatus.payee).length.toDouble();
          final impayee = factures.where((f) => f.statut == FactureStatus.impayee).length.toDouble();
          final partielle = factures.where((f) => f.statut == FactureStatus.partielle).length.toDouble();
          final annulee = factures.where((f) => f.statut == FactureStatus.annulee).length.toDouble();

          final recentTransactions = [...transactions]
            ..sort((a, b) => b.date.compareTo(a.date));
          final displayTransactions = recentTransactions.take(5).toList();

          final revenusMois = factures
              .where((f) =>
                  f.statut == FactureStatus.payee &&
                  f.dateEmission.month == now.month &&
                  f.dateEmission.year == now.year)
              .fold<double>(0, (sum, f) => sum + f.total);
          final depensesMois = transactions
              .where((t) =>
                  t.isDepense &&
                  t.date.month == now.month &&
                  t.date.year == now.year)
              .fold<double>(0, (sum, t) => sum + t.montant);
          final soldeMois = revenusMois - depensesMois;

          final revenuMoyen = revenusParMois.isNotEmpty
              ? revenusParMois.reduce((a, b) => a + b) / revenusParMois.length
              : 0.0;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryBar(isDark, revenusMois, depensesMois, soldeMois, margePct),
                  const SizedBox(height: 20),
                  _buildKpiRow(isDark, chiffreAffaires, totalFacture, enAttente, chantiersActifs),
                  const SizedBox(height: 20),
                  _buildRevenueAreaChart(isDark, revenusParMois, depensesParMois, moisLabels, now),
                  const SizedBox(height: 20),
                  _buildCashflowChart(isDark, cashflowSpots),
                  const SizedBox(height: 20),
                  _buildProfitabilityCard(isDark, revenueTotal, expenseTotal, margeBrute, margePct),
                  const SizedBox(height: 20),
                  _buildCategoryChart(isDark, payee, impayee, partielle, annulee),
                  const SizedBox(height: 20),
                  _buildSpendingBreakdown(isDark, transactions),
                  const SizedBox(height: 20),
                  _buildFinancialAnalysis(isDark, revenuMoyen, bestMonth, croissancePct, prevision, expenseTotal / (revenueTotal > 0 ? revenueTotal : 1)),
                  const SizedBox(height: 20),
                  _buildRecentTransactions(isDark, displayTransactions),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryBar(bool isDark, double revenus, double depenses, double solde, double margePct) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          _MiniCard(isDark: isDark, title: 'Revenus du mois', value: revenus.formattedCurrency, icon: Icons.trending_up_rounded, color: const Color(0xFF06D6A0)),
          const SizedBox(width: 10),
          _MiniCard(isDark: isDark, title: 'Dépenses du mois', value: depenses.formattedCurrency, icon: Icons.trending_down_rounded, color: const Color(0xFFEF476F)),
          const SizedBox(width: 10),
          _MiniCard(isDark: isDark, title: 'Solde', value: solde.formattedCurrency, icon: Icons.account_balance_wallet_rounded, color: solde >= 0 ? const Color(0xFF06D6A0) : const Color(0xFFEF476F)),
          const SizedBox(width: 10),
          _MiniCard(isDark: isDark, title: 'Marge', value: '${margePct.toStringAsFixed(1)}%', icon: Icons.pie_chart_rounded, color: const Color(0xFF7B61FF)),
        ],
      ),
    );
  }

  Widget _buildKpiRow(bool isDark, double chiffreAffaires, double totalFacture, int enAttente, int chantiersActifs) {
    return Row(
      children: [
        Expanded(child: _KpiCard(isDark: isDark, label: 'CA réalisé', value: chiffreAffaires.formattedCurrency, icon: Icons.trending_up_rounded, color: const Color(0xFF06D6A0))),
        const SizedBox(width: 8),
        Expanded(child: _KpiCard(isDark: isDark, label: 'Total facturé', value: totalFacture.formattedCurrency, icon: Icons.receipt_long_rounded, color: const Color(0xFF4895EF))),
      ],
    );
  }

  Widget _buildRevenueAreaChart(bool isDark, List<double> revenues, List<double> expenses, List<String> months, DateTime now) {
    final revenueSpots = revenues.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value / 1000000)).toList();
    final expenseSpots = expenses.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value / 1000000)).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF132042).withValues(alpha: 0.5), const Color(0xFF0F1A2E).withValues(alpha: 0.3)]
              : [const Color(0xFFFFFFFF), const Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (isDark ? AppColors.glassBorder : AppColors.lightBorder).withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFF4895EF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.show_chart_rounded, color: Color(0xFF4895EF), size: 16),
              ),
              const SizedBox(width: 10),
              Text('Tendance des revenus', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textOnDark : AppColors.textPrimary)),
              const Spacer(),
              _LegendDot(const Color(0xFF4895EF), 'Revenus'),
              const SizedBox(width: 12),
              _LegendDot(const Color(0xFFEF476F), 'Dépenses'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? AppColors.glassBorder.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.04),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, reservedSize: 36,
                      getTitlesWidget: (value, meta) => Text('${value.toInt()}k', style: TextStyle(fontSize: 9, color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = (now.month - 6 + value.toInt() + 12) % 12;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(months[idx], style: TextStyle(fontSize: 9, color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary)),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: revenueSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF4895EF),
                    barWidth: 2.5,
                    dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 3, color: const Color(0xFF4895EF), strokeWidth: 1.5, strokeColor: isDark ? const Color(0xFF0F1A2E) : Colors.white,
                    )),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [const Color(0xFF4895EF).withValues(alpha: 0.2), const Color(0xFF4895EF).withValues(alpha: 0.0)],
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: expenseSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFFEF476F).withValues(alpha: 0.6),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [const Color(0xFFEF476F).withValues(alpha: 0.1), const Color(0xFFEF476F).withValues(alpha: 0.0)],
                      ),
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

  Widget _buildCashflowChart(bool isDark, List<FlSpot> cashflowSpots) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF132042).withValues(alpha: 0.5), const Color(0xFF0F1A2E).withValues(alpha: 0.3)]
              : [const Color(0xFFFFFFFF), const Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (isDark ? AppColors.glassBorder : AppColors.lightBorder).withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFF06D6A0).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.trending_up_rounded, color: Color(0xFF06D6A0), size: 16),
              ),
              const SizedBox(width: 10),
              Text('Cashflow cumulé', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textOnDark : AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true, drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? AppColors.glassBorder.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.04),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, reservedSize: 36,
                      getTitlesWidget: (value, meta) => Text('${value.toInt()}k', style: TextStyle(fontSize: 9, color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const m = ['J', 'F', 'M', 'A', 'M', 'J'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(m[value.toInt() % 6], style: TextStyle(fontSize: 9, color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary)),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: cashflowSpots,
                    isCurved: true,
                    curveSmoothness: 0.4,
                    color: const Color(0xFF06D6A0),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [const Color(0xFF06D6A0).withValues(alpha: 0.15), const Color(0xFF06D6A0).withValues(alpha: 0.0)],
                      ),
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

  Widget _buildProfitabilityCard(bool isDark, double revenue, double expenses, double marge, double margePct) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF132042).withValues(alpha: 0.5), const Color(0xFF0F1A2E).withValues(alpha: 0.3)]
              : [const Color(0xFFFFFFFF), const Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (isDark ? AppColors.glassBorder : AppColors.lightBorder).withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFF7B61FF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.account_balance_rounded, color: Color(0xFF7B61FF), size: 16),
              ),
              const SizedBox(width: 10),
              Text('Rentabilité', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textOnDark : AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 32,
                      sections: [
                        PieChartSectionData(value: revenue, color: const Color(0xFF06D6A0), radius: 36, title: '${((revenue / (revenue + expenses)) * 100).toStringAsFixed(0)}%', titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                        PieChartSectionData(value: expenses, color: const Color(0xFFEF476F).withValues(alpha: 0.6), radius: 36, title: '', titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MetricRow(label: 'Revenus totaux', value: revenue.formattedCurrency, color: const Color(0xFF06D6A0), isDark: isDark),
                      const SizedBox(height: 10),
                      _MetricRow(label: 'Dépenses totales', value: expenses.formattedCurrency, color: const Color(0xFFEF476F), isDark: isDark),
                      const SizedBox(height: 10),
                      _MetricRow(label: 'Marge brute', value: marge.formattedCurrency, color: marge >= 0 ? const Color(0xFF06D6A0) : const Color(0xFFEF476F), isDark: isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: margePct.clamp(0, 1) / 100,
              backgroundColor: const Color(0xFFEF476F).withValues(alpha: 0.1),
              color: const Color(0xFF06D6A0),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text('Marge de ${margePct.toStringAsFixed(1)}%', style: TextStyle(fontSize: 9, color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(bool isDark, double payee, double impayee, double partielle, double annulee) {
    final sections = <(String, double, Color)>[
      ('Payée', payee, const Color(0xFF06D6A0)),
      ('Impayée', impayee, const Color(0xFFEF476F)),
      ('Partielle', partielle, const Color(0xFFF4A261)),
      ('Annulée', annulee, const Color(0xFF9CA3AF)),
    ].where((s) => s.$2 > 0).toList();
    final total = payee + impayee + partielle + annulee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF132042).withValues(alpha: 0.5), const Color(0xFF0F1A2E).withValues(alpha: 0.3)]
              : [const Color(0xFFFFFFFF), const Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (isDark ? AppColors.glassBorder : AppColors.lightBorder).withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFF7B61FF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.pie_chart_rounded, color: Color(0xFF7B61FF), size: 16),
              ),
              const SizedBox(width: 10),
              Text('Statut des factures', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textOnDark : AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 36,
                      sections: sections.map((s) {
                        final pct = total > 0 ? (s.$2 / total * 100) : 0.0;
                        return PieChartSectionData(
                          value: s.$2, color: s.$3, radius: 40,
                          title: '${pct.toStringAsFixed(0)}%',
                          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sections.map((s) {
                    final pct = total > 0 ? (s.$2 / total * 100) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: s.$3, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text('${s.$1} • ${pct.toStringAsFixed(0)}%', style: TextStyle(fontSize: 10, color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingBreakdown(bool isDark, List<dynamic> transactions) {
    final depenses = <String, double>{};
    final revenus = <String, double>{};
    for (final t in transactions) {
      if (t.isDepense) {
        depenses[t.categorie] = (depenses[t.categorie] ?? 0) + t.montant;
      } else {
        revenus[t.categorie] = (revenus[t.categorie] ?? 0) + t.montant;
      }
    }

    final topDepenses = depenses.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (topDepenses.isEmpty) return const SizedBox.shrink();

    final totalDep = topDepenses.fold<double>(0, (s, e) => s + e.value);
    final colors = [const Color(0xFF4895EF), const Color(0xFF7B61FF), const Color(0xFFF4A261), const Color(0xFFEF476F), const Color(0xFF06D6A0)];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF132042).withValues(alpha: 0.5), const Color(0xFF0F1A2E).withValues(alpha: 0.3)]
              : [const Color(0xFFFFFFFF), const Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (isDark ? AppColors.glassBorder : AppColors.lightBorder).withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFFF4A261).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.receipt_long_rounded, color: Color(0xFFF4A261), size: 16),
              ),
              const SizedBox(width: 10),
              Text('Répartition des dépenses', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textOnDark : AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(topDepenses.length > 5 ? 5 : topDepenses.length, (i) {
            final e = topDepenses[i];
            final pct = totalDep > 0 ? (e.value / totalDep * 100) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e.key, style: TextStyle(fontSize: 10, color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary))),
                      Text(e.value.formattedCurrency, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? AppColors.textOnDark : AppColors.textPrimary)),
                      const SizedBox(width: 6),
                      Text('${pct.toStringAsFixed(0)}%', style: TextStyle(fontSize: 9, color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      backgroundColor: colors[i % colors.length].withValues(alpha: 0.08),
                      color: colors[i % colors.length].withValues(alpha: 0.5),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFinancialAnalysis(bool isDark, double revenuMoyen, String bestMonth, double croissancePct, double prevision, double expenseRatio) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF132042).withValues(alpha: 0.5), const Color(0xFF0F1A2E).withValues(alpha: 0.3)]
              : [const Color(0xFFFFFFFF), const Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (isDark ? AppColors.glassBorder : AppColors.lightBorder).withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFF4895EF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.analytics_rounded, color: Color(0xFF4895EF), size: 16),
              ),
              const SizedBox(width: 10),
              Text('Analyse financière', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textOnDark : AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _AnalysisTile(isDark: isDark, icon: Icons.calendar_month_rounded, label: 'Moyen mensuel', value: revenuMoyen.formattedCurrency, color: const Color(0xFF4895EF))),
              const SizedBox(width: 8),
              Expanded(child: _AnalysisTile(isDark: isDark, icon: Icons.star_rounded, label: 'Meilleur mois', value: bestMonth, color: const Color(0xFF7B61FF))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _AnalysisTile(isDark: isDark, icon: croissancePct >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded, label: 'Croissance', value: '${croissancePct.toStringAsFixed(1)}%', color: croissancePct >= 0 ? const Color(0xFF06D6A0) : const Color(0xFFEF476F))),
              const SizedBox(width: 8),
              Expanded(child: _AnalysisTile(isDark: isDark, icon: Icons.query_stats_rounded, label: 'Prévision', value: prevision.formattedCurrency, color: const Color(0xFFF4A261))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _AnalysisTile(isDark: isDark, icon: Icons.monetization_on_rounded, label: 'Ratio dépenses', value: '${(expenseRatio * 100).toStringAsFixed(0)}%', color: const Color(0xFFEF476F))),
              const SizedBox(width: 8),
              Expanded(child: _AnalysisTile(isDark: isDark, icon: Icons.trending_up_rounded, label: 'ROI estimé', value: '${((revenuMoyen > 0 ? ((revenuMoyen * 12) / (revenuMoyen * expenseRatio * 12) - 1) * 100 : 0)).toStringAsFixed(0)}%', color: const Color(0xFF06D6A0))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(bool isDark, List<dynamic> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('TRANSACTIONS RÉCENTES', style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary, fontWeight: FontWeight.w600)),
        ),
        if (transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF132042).withValues(alpha: 0.3), const Color(0xFF0F1A2E).withValues(alpha: 0.1)]
                    : [const Color(0xFFFFFFFF).withValues(alpha: 0.5), const Color(0xFFF8F9FA).withValues(alpha: 0.3)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: (isDark ? AppColors.glassBorder : AppColors.lightBorder).withValues(alpha: 0.2), width: 0.5),
            ),
            child: Center(child: Text('Aucune transaction', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary))),
          )
        else
          ...transactions.asMap().entries.map((entry) {
            final i = entry.key;
            final t = entry.value;
            final isDepense = t.isDepense;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 300 + (i * 80)),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF132042).withValues(alpha: 0.4), const Color(0xFF0F1A2E).withValues(alpha: 0.2)]
                                : [const Color(0xFFFFFFFF), const Color(0xFFF8F9FA)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: (isDark ? AppColors.glassBorder : AppColors.lightBorder).withValues(alpha: 0.2), width: 0.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (isDepense ? const Color(0xFFEF476F) : const Color(0xFF06D6A0)).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(isDepense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: isDepense ? const Color(0xFFEF476F) : const Color(0xFF06D6A0), size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.libelle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? AppColors.textOnDark : AppColors.textPrimary)),
                                  SizedBox(height: 2),
                                  Text('${t.date.day}/${t.date.month}/${t.date.year}', style: TextStyle(fontSize: 9, color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary)),
                                ],
                              ),
                            ),
                            Text(
                              '${isDepense ? '-' : '+'}${t.montant.formattedCurrency}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDepense ? const Color(0xFFEF476F) : const Color(0xFF06D6A0)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9)),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final bool isDark;
  final String title, value;
  final IconData icon;
  final Color color;
  const _MiniCard({required this.isDark, required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF132042).withValues(alpha: 0.6), const Color(0xFF0F1A2E).withValues(alpha: 0.3)]
              : [const Color(0xFFFFFFFF).withValues(alpha: 0.9), const Color(0xFFF8F9FA).withValues(alpha: 0.6)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.15), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Icon(icon, size: 12, color: color),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 8, color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? AppColors.textOnDark : AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 9, color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _TypeToggle({required this.label, required this.active, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? color : Colors.grey.withValues(alpha: 0.2), width: 1),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? color : Colors.grey)),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final bool isDark;
  final String label, value;
  final IconData icon;
  final Color color;
  const _KpiCard({required this.isDark, required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF132042).withValues(alpha: 0.6), const Color(0xFF0F1A2E).withValues(alpha: 0.3)]
              : [const Color(0xFFFFFFFF).withValues(alpha: 0.9), const Color(0xFFF8F9FA).withValues(alpha: 0.6)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.15 : 0.1), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 14, color: color),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
                child: Text(label, style: TextStyle(fontSize: 7, color: color.withValues(alpha: 0.6), letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? AppColors.textOnDark : AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _AnalysisTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label, value;
  final Color color;
  const _AnalysisTile({required this.isDark, required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.06 : 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const Spacer(),
              Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 9, color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool isDark;
  const _MetricRow({required this.label, required this.value, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 10, color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary)),
          ],
        ),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.textOnDark : AppColors.textPrimary)),
      ],
    );
  }
}
