import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/core/extensions/date_extensions.dart';
import 'package:devis/core/extensions/num_extensions.dart';
import 'package:devis/core/extensions/context_extensions.dart';
import 'package:devis/core/utils/enums.dart';
import 'package:devis/core/widgets/searchable_list.dart';
import 'package:devis/data/models/facture.dart';
import 'package:devis/data/providers/providers.dart';

class FactureListPage extends ConsumerStatefulWidget {
  const FactureListPage({super.key});

  @override
  ConsumerState<FactureListPage> createState() => _FactureListPageState();
}

class _FactureListPageState extends ConsumerState<FactureListPage> {
  FactureStatus? _filterStatus;

  List<Facture> _filterFactures(List<Facture> factures) {
    if (_filterStatus == null) return factures;
    return factures.where((f) => f.statut == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final facturesAsync = ref.watch(facturesProvider);

    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Factures',
        showBack: false,
        isDark: isDark,
        actions: [
          if (facturesAsync.asData?.value case final factures?)
            CountBadge(count: factures.length, isDark: isDark),
          PopupMenuButton<FactureStatus?>(
            icon: const Icon(Icons.filter_alt_rounded),
            onSelected: (v) => setState(() => _filterStatus = v),
            itemBuilder: (context) => [
              PopupMenuItem<FactureStatus?>(
                value: null,
                child: Text(_filterStatus == null ? 'Toutes' : 'Tous les statuts',
                    style: TextStyle(fontWeight: _filterStatus == null ? FontWeight.bold : FontWeight.normal)),
              ),
              ...FactureStatus.values.map((s) => PopupMenuItem<FactureStatus?>(
                    value: s,
                    child: Text(s.name, style: TextStyle(fontWeight: _filterStatus == s ? FontWeight.bold : FontWeight.normal)),
                  )),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).push('/devis');
          context.showSnackBar('Sélectionnez un devis à convertir');
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: facturesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (factures) {
          final filtered = _filterFactures(factures);
          if (filtered.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(facturesProvider);
                await ref.read(facturesProvider.future);
              },
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: EmptyState(
                      icon: Icons.receipt_outlined,
                      title: 'Aucune facture',
                      subtitle: factures.isEmpty
                          ? 'Créez une facture depuis un devis'
                          : 'Aucune facture avec ce filtre',
                      actionLabel: factures.isEmpty ? 'Créer une facture' : null,
                      onAction: factures.isEmpty
                          ? () {
                              GoRouter.of(context).push('/devis');
                              context.showSnackBar('Sélectionnez un devis à convertir');
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            );
          }
          return SearchableList<Facture>(
            items: filtered,
            searchKey: (f) => '${f.numero} ${f.clientNom}',
            hintText: 'Rechercher une facture...',
            header: (filteredItems) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text('${filteredItems.length} factures',
                  style: AppTypography.caption),
            ),
            itemBuilder: (f, index) => _FactureCard(facture: f, isDark: isDark),
          );
        },
      ),
    );
  }
}

class _FactureCard extends StatelessWidget {
  final Facture facture;
  final bool isDark;
  const _FactureCard({required this.facture, required this.isDark});

  Color _statusColor(FactureStatus status) {
    switch (status) {
      case FactureStatus.impayee:
        return AppColors.electricOrange;
      case FactureStatus.partielle:
        return AppColors.electricBlue;
      case FactureStatus.payee:
        return AppColors.electricGreen;
      case FactureStatus.annulee:
        return AppColors.electricRed;
    }
  }

  String _statusLabel(FactureStatus status) {
    switch (status) {
      case FactureStatus.impayee:
        return 'Impayée';
      case FactureStatus.partielle:
        return 'Partielle';
      case FactureStatus.payee:
        return 'Payée';
      case FactureStatus.annulee:
        return 'Annulée';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElectricCard(
      isDark: isDark,
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => GoRouter.of(context).push('/factures/${facture.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(facture.numero,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.electricPurple,
                  )),
              StatusBadge(
                label: _statusLabel(facture.statut),
                color: _statusColor(facture.statut),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(facture.clientNom, style: AppTypography.titleMedium),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(facture.dateEmission.formatted,
                  style: AppTypography.caption),
              const SizedBox(width: 16),
              Text('Échéance: ${facture.dateEcheance.formatted}',
                  style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(facture.total.formattedCurrency,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
              if (facture.statut == FactureStatus.impayee ||
                  facture.statut == FactureStatus.partielle)
                Text('Reste: ${facture.restantDu.formattedCurrency}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.electricRed,
                    )),
            ],
          ),
          if (facture.montantPaye > 0) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: facture.montantPaye / facture.total,
                backgroundColor:
                    AppColors.electricGreen.withValues(alpha: 0.1),
                color: AppColors.electricGreen,
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
