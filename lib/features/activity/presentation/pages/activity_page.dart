import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/data/providers/providers.dart';
import 'package:devis/core/utils/enums.dart';

class ActivityPage extends ConsumerStatefulWidget {
  const ActivityPage({super.key});

  @override
  ConsumerState<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends ConsumerState<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final devisAsync = ref.watch(devisProvider);
    final facturesAsync = ref.watch(facturesProvider);
    final chantiersAsync = ref.watch(chantiersProvider);
    final clientsAsync = ref.watch(clientsProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Toute l\'activité',
        isDark: isDark,
      ),
      body: devisAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (devis) {
          final factures = facturesAsync.asData?.value ?? [];
          final chantiers = chantiersAsync.asData?.value ?? [];
          final clients = clientsAsync.asData?.value ?? [];
          final transactions = transactionsAsync.asData?.value ?? [];

          final activities = <_ActivityItem>[];

          for (final d in devis) {
            activities.add(_ActivityItem(
              type: 'Devis',
              title: d.numero,
              subtitle: d.client.nomComplet,
              icon: Icons.description_rounded,
              color: AppColors.electricBlue,
              date: d.date,
            ));
          }
          for (final f in factures) {
            activities.add(_ActivityItem(
              type: f.statut == FactureStatus.payee ? 'Facture payée' : 'Facture',
              title: f.numero,
              subtitle: f.clientNom,
              icon: f.statut == FactureStatus.payee
                  ? Icons.check_circle_rounded
                  : Icons.receipt_rounded,
              color: f.statut == FactureStatus.payee
                  ? AppColors.electricGreen
                  : AppColors.electricOrange,
              date: f.updatedAt,
            ));
          }
          for (final c in clients) {
            activities.add(_ActivityItem(
              type: 'Client',
              title: c.nom,
              subtitle: c.email ?? c.telephone,
              icon: Icons.person_add_rounded,
              color: AppColors.electricPurple,
              date: c.updatedAt,
            ));
          }
          for (final c in chantiers) {
            activities.add(_ActivityItem(
              type: 'Chantier ${c.statut.name}',
              title: c.nom,
              subtitle: c.clientNom ?? '',
              icon: Icons.construction_rounded,
              color: AppColors.electricOrange,
              date: c.updatedAt,
            ));
          }
          for (final t in transactions) {
            activities.add(_ActivityItem(
              type: t.isDepense ? 'Dépense' : 'Revenu',
              title: t.libelle,
              subtitle: t.montant.toString(),
              icon: t.isDepense
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: t.isDepense
                  ? AppColors.electricRed
                  : AppColors.electricGreen,
              date: t.date,
            ));
          }

          activities.sort((a, b) => b.date.compareTo(a.date));

          if (activities.isEmpty) {
            return const Center(
              child: EmptyState(
                icon: Icons.history_rounded,
                title: 'Aucune activité',
                subtitle: 'Les activités apparaîtront ici',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(devisProvider);
              ref.invalidate(facturesProvider);
              ref.invalidate(chantiersProvider);
              ref.invalidate(clientsProvider);
              ref.invalidate(transactionsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                final localIndex = index;
                return AnimatedListItem(
                  index: localIndex,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: activity.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(activity.icon, color: activity.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(activity.type,
                                  style: AppTypography.titleMedium),
                              Text(activity.title,
                                  style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Text(_timeAgo(activity.date),
                            style: AppTypography.caption),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ActivityItem {
  final String type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final DateTime date;

  const _ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.date,
  });
}
