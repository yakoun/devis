import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devis/data/providers/providers.dart';
import 'package:devis/data/models/devis.dart';
import 'package:devis/data/models/facture.dart';
import 'package:devis/data/models/client.dart';
import 'package:devis/data/models/chantier.dart';
import 'package:devis/data/models/transaction.dart';
import 'package:devis/core/utils/enums.dart';
import 'package:devis/design_system/design_system.dart';

@immutable
class DashboardData {
  final int devisEnCours;
  final int devisCeMois;
  final double chiffreAffairesTotal;
  final int clientsActifs;
  final int totalDevis;
  final List<double> monthlyRevenue;
  final Map<String, double> pieCounts;
  final List<ActivityItem> recentActivity;
  final int unpaidFactures;
  final DateTime computedAt;

  const DashboardData({
    required this.devisEnCours,
    required this.devisCeMois,
    required this.chiffreAffairesTotal,
    required this.clientsActifs,
    required this.totalDevis,
    required this.monthlyRevenue,
    required this.pieCounts,
    required this.recentActivity,
    required this.unpaidFactures,
    required this.computedAt,
  });

  static const _months = [
    'J', 'F', 'M', 'A', 'M', 'J',
    'J', 'A', 'S', 'O', 'N', 'D'
  ];

  static List<String> get monthLabels => _months;

  factory DashboardData.compute(
    List<Devis> devis,
    List<Facture> factures,
    List<Chantier> chantiers,
    List<AppClient> clients,
    List<Transaction> transactions,
  ) {
    final now = DateTime.now();

    final devisEnCours = devis
        .where((d) =>
            d.statut == 'brouillon' ||
            d.statut == 'envoyé')
        .length;

    final devisCeMois = devis
        .where((d) =>
            d.date.month == now.month &&
            d.date.year == now.year)
        .length;

    final chiffreAffairesTotal = factures
        .where((f) => f.statut == FactureStatus.payee)
        .fold<double>(0, (sum, f) => sum + f.total);

    final monthlyRevenue = List.generate(6, (i) {
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

    final brouillon =
        devis.where((d) => d.statut == 'brouillon').length.toDouble();
    final envoye =
        devis.where((d) => d.statut == 'envoyé').length.toDouble();
    final accepte =
        devis.where((d) => d.statut == 'accepté').length.toDouble();
    final refuse =
        devis.where((d) => d.statut == 'refusé').length.toDouble();

    final unpaidFactures = factures
        .where((f) =>
            f.statut == FactureStatus.impayee ||
            f.statut == FactureStatus.partielle)
        .length;

    final recentActivity = _buildRecentActivityList(
      devis, factures, clients, chantiers, transactions,
    );

    return DashboardData(
      devisEnCours: devisEnCours,
      devisCeMois: devisCeMois,
      chiffreAffairesTotal: chiffreAffairesTotal,
      clientsActifs: clients.length,
      totalDevis: devis.length,
      monthlyRevenue: monthlyRevenue,
      pieCounts: {
        'brouillon': brouillon,
        'envoye': envoye,
        'accepte': accepte,
        'refuse': refuse,
      },
      recentActivity: recentActivity,
      unpaidFactures: unpaidFactures,
      computedAt: now,
    );
  }

  static List<ActivityItem> _buildRecentActivityList(
    List<Devis> devis,
    List<Facture> factures,
    List<AppClient> clients,
    List<Chantier> chantiers,
    List<Transaction> transactions,
  ) {
    final activities = <ActivityItem>[];

    for (final d in devis.take(5)) {
      activities.add(ActivityItem(
        title: 'Devis créé',
        subtitle: d.numero,
        icon: Icons.description_rounded,
        color: AppColors.electricBlue,
        date: d.date,
      ));
    }
    for (final f in factures.take(5)) {
      activities.add(ActivityItem(
        title: f.statut == FactureStatus.payee
            ? 'Facture payée'
            : 'Facture créée',
        subtitle: f.numero,
        icon: f.statut == FactureStatus.payee
            ? Icons.check_circle_rounded
            : Icons.receipt_rounded,
        color: f.statut == FactureStatus.payee
            ? AppColors.electricGreen
            : AppColors.electricOrange,
        date: f.updatedAt,
      ));
    }
    for (final c in clients.take(5)) {
      activities.add(ActivityItem(
        title: 'Client ajouté',
        subtitle: c.nom,
        icon: Icons.person_add_rounded,
        color: AppColors.electricPurple,
        date: c.updatedAt,
      ));
    }
    for (final c in chantiers.take(5)) {
      activities.add(ActivityItem(
        title: 'Chantier ${c.statut.name}',
        subtitle: c.nom,
        icon: Icons.construction_rounded,
        color: AppColors.electricOrange,
        date: c.updatedAt,
      ));
    }
    for (final t in transactions.take(5)) {
      activities.add(ActivityItem(
        title: t.isDepense ? 'Dépense' : 'Revenu',
        subtitle: t.libelle,
        icon: t.isDepense
            ? Icons.arrow_downward_rounded
            : Icons.arrow_upward_rounded,
        color: t.isDepense ? AppColors.electricRed : AppColors.electricGreen,
        date: t.date,
      ));
    }

    activities.sort((a, b) => b.date.compareTo(a.date));
    return activities.take(5).toList();
  }

  double get pieTotal => pieCounts.values.fold(0, (a, b) => a + b);
}

class ActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final DateTime date;

  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.date,
  });
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final devis = await ref.watch(devisProvider.future);
  final factures = await ref.watch(facturesProvider.future);
  final chantiers = await ref.watch(chantiersProvider.future);
  final clients = await ref.watch(clientsProvider.future);
  final transactions = await ref.watch(transactionsProvider.future);
  return DashboardData.compute(devis, factures, chantiers, clients, transactions);
});
