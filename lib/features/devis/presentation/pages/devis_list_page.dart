import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/core/extensions/date_extensions.dart';
import 'package:devis/core/extensions/num_extensions.dart';
import 'package:devis/core/utils/enums.dart';
import 'package:devis/core/widgets/searchable_list.dart';
import 'package:devis/data/models/devis.dart';
import 'package:devis/data/providers/providers.dart';
import 'package:devis/data/providers/settings_provider.dart';
import 'package:devis/services/invoice_pdf_template.dart';
import 'package:devis/services/pdf_service.dart';

class DevisListPage extends ConsumerStatefulWidget {
  const DevisListPage({super.key});

  @override
  ConsumerState<DevisListPage> createState() => _DevisListPageState();
}

class _DevisListPageState extends ConsumerState<DevisListPage> {
  Future<void> _refresh() async {
    ref.invalidate(devisProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final devisAsync = ref.watch(devisProvider);

    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Devis',
        showBack: false,
        isDark: isDark,
        actions: [
          if (devisAsync.asData?.value case final devis?)
            CountBadge(count: devis.length, isDark: isDark),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/devis/create'),
        child: const Icon(Icons.add_rounded),
      ),
      body: devisAsync.when(
        loading: () => ShimmerLoading(
          isDark: isDark,
          itemCount: 4,
          itemBuilder: (index) => SkeletonDevisCard(isDark: isDark),
        ),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (devis) {
          if (devis.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: EmptyState(
                      icon: Icons.description_outlined,
                      title: 'Aucun devis',
                      subtitle: 'Créez votre premier devis pour commencer',
                      actionLabel: 'Créer un premier devis',
                      onAction: () => context.push('/devis/create'),
                    ),
                  ),
                ],
              ),
            );
          }
          return SearchableList<Devis>(
            items: devis,
            searchKey: (d) => '${d.numero} ${d.client.nomComplet}',
            hintText: 'Rechercher un devis...',
            header: (filtered) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text('${filtered.length} devis',
                  style: AppTypography.caption),
            ),
            itemBuilder: (d, index) => AnimatedListItem(
              index: index,
              child: _DevisCard(
                devis: d,
                isDark: isDark,
                onPdf: () async {
                  try {
                    final info = await ref.read(technicienInfoProvider.future);
                    final settings = ref.read(appSettingsProvider);
                    final doc = await InvoicePdfTemplate.buildDevisDocument(
                      devis: d, info: info, settings: settings,
                    );
                    final pdfBytes = await doc.save();
                    final pdfService = PdfService();
                    await pdfService.sharePdf(pdfBytes, d.numero);
                  } catch (e) {
                    if (!context.mounted) return;
                    AppSnackbar.error(context, 'Erreur PDF: $e');
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DevisCard extends StatelessWidget {
  final Devis devis;
  final bool isDark;
  final VoidCallback? onPdf;

  const _DevisCard({required this.devis, required this.isDark, this.onPdf});

  Color _statusColor(String status) {
    switch (status) {
      case 'brouillon':
        return AppColors.textSecondary;
      case 'envoyé':
        return AppColors.electricBlue;
      case 'accepté':
        return AppColors.electricGreen;
      case 'refusé':
        return AppColors.electricRed;
      case 'expiré':
        return AppColors.electricOrange;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'brouillon':
        return 'Brouillon';
      case 'envoyé':
        return 'Envoyé';
      case 'accepté':
        return 'Accepté';
      case 'refusé':
        return 'Refusé';
      case 'expiré':
        return 'Expiré';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElectricCard(
      isDark: isDark,
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => context.push('/devis/${devis.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(devis.numero,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.electricBlue,
                  )),
              StatusBadge(
                label: _statusLabel(devis.statut),
                color: _statusColor(devis.statut),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(devis.client.nomComplet, style: AppTypography.titleMedium),
          const SizedBox(height: 4),
          Text(devis.date.formatted,
              style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(devis.netAPayer.formattedCurrency,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
              Row(
                children: [
                  Text('${devis.lignes.length} articles',
                      style: AppTypography.caption),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onPdf,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded,
                          color: AppColors.electricBlue, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
