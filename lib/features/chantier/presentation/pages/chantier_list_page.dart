import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/core/extensions/date_extensions.dart';
import 'package:devis/core/utils/enums.dart';
import 'package:devis/core/widgets/searchable_list.dart';
import 'package:devis/data/models/chantier.dart';
import 'package:devis/data/providers/providers.dart';

class ChantierListPage extends ConsumerStatefulWidget {
  const ChantierListPage({super.key});

  @override
  ConsumerState<ChantierListPage> createState() => _ChantierListPageState();
}

class _ChantierListPageState extends ConsumerState<ChantierListPage> {
  Future<void> _refresh() async {
    ref.invalidate(chantiersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chantiersAsync = ref.watch(chantiersProvider);

    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Chantiers',
        showBack: false,
        isDark: isDark,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: chantiersAsync.when(
        loading: () => ShimmerLoading(
          isDark: isDark,
          itemCount: 4,
          itemBuilder: (index) => SkeletonDevisCard(isDark: isDark),
        ),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (chantiers) {
          if (chantiers.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: EmptyState(
                      icon: Icons.construction_rounded,
                      title: 'Aucun chantier',
                      subtitle: 'Planifiez votre premier chantier',
                      actionLabel: 'Nouveau chantier',
                      onAction: () => _showCreateDialog(context, ref),
                    ),
                  ),
                ],
              ),
            );
          }
          return SearchableList<Chantier>(
            items: chantiers,
            searchKey: (c) => '${c.nom} ${c.description ?? ''} ${c.adresse ?? ''}',
            hintText: 'Rechercher un chantier...',
            header: (filtered) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text('${filtered.length} chantiers',
                  style: AppTypography.caption),
            ),
            itemBuilder: (c, index) => AnimatedListItem(
              index: index,
              child: _ChantierCard(chantier: c, isDark: isDark),
            ),
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final nomCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final adresseCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau chantier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PremiumTextField(label: 'Nom', controller: nomCtrl),
            const SizedBox(height: 12),
            PremiumTextField(label: 'Description', controller: descCtrl),
            const SizedBox(height: 12),
            PremiumTextField(label: 'Adresse', controller: adresseCtrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          GlowButton(
            label: 'CRÉER',
            onPressed: () async {
              if (nomCtrl.text.isEmpty) return;
              final chantier = Chantier.create(
                nom: nomCtrl.text,
                description: descCtrl.text.isNotEmpty ? descCtrl.text : null,
                adresse:
                    adresseCtrl.text.isNotEmpty ? adresseCtrl.text : null,
              );
              final repo = ref.read(hiveRepositoryProvider);
              await repo.saveChantier(chantier);
              if (!ctx.mounted) return;
              ref.invalidate(chantiersProvider);
              Navigator.pop(ctx);
              if (!context.mounted) return;
              AppSnackbar.success(context, 'Chantier créé avec succès');
            },
          ),
        ],
      ),
    );
  }
}

class _ChantierCard extends StatelessWidget {
  final Chantier chantier;
  final bool isDark;
  const _ChantierCard({required this.chantier, required this.isDark});

  Color _statusColor(ChantierStatus status) {
    switch (status) {
      case ChantierStatus.planifie:
        return AppColors.electricBlue;
      case ChantierStatus.enCours:
        return AppColors.electricGreen;
      case ChantierStatus.enPause:
        return AppColors.electricOrange;
      case ChantierStatus.termine:
        return AppColors.electricPurple;
      case ChantierStatus.annule:
        return AppColors.electricRed;
    }
  }

  String _statusLabel(ChantierStatus status) {
    switch (status) {
      case ChantierStatus.planifie:
        return 'Planifié';
      case ChantierStatus.enCours:
        return 'En cours';
      case ChantierStatus.enPause:
        return 'En pause';
      case ChantierStatus.termine:
        return 'Terminé';
      case ChantierStatus.annule:
        return 'Annulé';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElectricCard(
      isDark: isDark,
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => GoRouter.of(context).push('/chantiers/${chantier.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(chantier.nom,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
              ),
              StatusBadge(
                label: _statusLabel(chantier.statut),
                color: _statusColor(chantier.statut),
              ),
            ],
          ),
          if (chantier.description != null) ...[
            const SizedBox(height: 4),
            Text(chantier.description!,
                style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _MetaInfo(Icons.location_on_rounded,
                  chantier.adresse ?? 'Non définie'),
              const SizedBox(width: 16),
              _MetaInfo(
                  Icons.checklist_rounded,
                  '${chantier.checklist.where((c) => c.isDone).length}/${chantier.checklist.length}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MetaInfo(Icons.access_time_rounded,
                  chantier.dateDebut.formatted),
              const Spacer(),
              _MetaInfo(Icons.timer_rounded,
                  '${chantier.tempsPasse.inHours}h${chantier.tempsPasse.inMinutes.remainder(60)}min'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaInfo(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: AppTypography.caption),
      ],
    );
  }
}
