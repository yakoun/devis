import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/core/extensions/date_extensions.dart';
import 'package:devis/core/extensions/context_extensions.dart';
import 'package:devis/core/extensions/num_extensions.dart';
import 'package:devis/core/utils/enums.dart';
import 'package:devis/data/models/facture.dart';
import 'package:devis/data/providers/providers.dart';
import 'package:devis/data/providers/settings_provider.dart';
import 'package:devis/services/pdf_service.dart';
import 'package:devis/services/invoice_pdf_template.dart';

class FactureDetailPage extends ConsumerWidget {
  final String factureId;
  const FactureDetailPage({super.key, required this.factureId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final factureAsync = ref.watch(factureProviderById(factureId));

    return factureAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
      data: (facture) {
        if (facture == null) {
          return Scaffold(
            body: Center(child: Text('Facture introuvable')),
          );
        }
        final f = facture;
        return Scaffold(
          appBar: PremiumAppBar(
            title: f.numero,
            isDark: isDark,
            actions: [
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'pdf', child: Text('PDF')),
                  const PopupMenuItem(value: 'partager', child: Text('Partager')),
                  if (f.statut != FactureStatus.payee)
                    const PopupMenuItem(value: 'payer', child: Text('Enregistrer paiement')),
                ],
                onSelected: (value) async {
                  if (value == 'pdf') {
                    try {
                      final info = await ref.read(technicienInfoProvider.future);
                      final settings = ref.read(appSettingsProvider);
                      final doc = await InvoicePdfTemplate.buildFactureDocument(facture: f, info: info, settings: settings);
                      final bytes = await doc.save();
                      final pdfService = PdfService();
                      await pdfService.printPdf(bytes);
                    } catch (e) {
                      if (!context.mounted) return;
                      context.showSnackBar('Erreur PDF: $e');
                    }
                  }
                  if (value == 'partager') {
                    try {
                      final info = await ref.read(technicienInfoProvider.future);
                      final settings = ref.read(appSettingsProvider);
                      final doc = await InvoicePdfTemplate.buildFactureDocument(facture: f, info: info, settings: settings);
                      final bytes = await doc.save();
                      final pdfService = PdfService();
                      await pdfService.sharePdf(bytes, f.numero);
                    } catch (e) {
                      if (!context.mounted) return;
                      context.showSnackBar('Erreur: $e');
                    }
                  }
                  if (value == 'payer') {
                    _showPaymentDialog(context, ref, f);
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElectricCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Client', style: AppTypography.caption),
                              Text(f.clientNom, style: AppTypography.titleLarge),
                            ],
                          ),
                          StatusBadge(
                            label: f.statut.name,
                            color: f.statut == FactureStatus.payee
                                ? AppColors.electricGreen
                                : f.statut == FactureStatus.impayee
                                    ? AppColors.electricOrange
                                    : AppColors.electricRed,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoRow('Émission', f.dateEmission.formatted),
                      _InfoRow('Échéance', f.dateEcheance.formatted),
                      if (f.datePaiement != null)
                        _InfoRow('Payée le', f.datePaiement!.formatted),
                      if (f.modePaiement != null)
                        _InfoRow('Mode', f.modePaiement!.name),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionHeader(title: 'Articles'),
                ...f.items.map((item) => ElectricCard(
                      isDark: isDark,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.designation,
                                    style: AppTypography.titleMedium),
                                Text('${item.quantite} x ${item.prixUnitaire.formattedCurrency}',
                                    style: AppTypography.bodySmall),
                              ],
                            ),
                          ),
                          Text(item.prixTotal.formattedCurrency,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                ElectricCard(
                  isDark: isDark,
                  child: Column(
                    children: [
                      _TotalRow('Sous-total', f.sousTotal.formattedCurrency),
                      if (f.remise > 0)
                        _TotalRow('Remise', '-${f.remise.formattedCurrency}'),
                      _TotalRow('TVA (${f.tva}%)', f.montantTva.formattedCurrency),
                      const Divider(),
                      _TotalRow('Total', f.total.formattedCurrency, isBold: true),
                      const Divider(),
                      _TotalRow('Payé', f.montantPaye.formattedCurrency),
                      _TotalRow('Reste dû', f.restantDu.formattedCurrency,
                          isBold: true, color: AppColors.electricRed),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaymentDialog(BuildContext context, WidgetRef ref, Facture facture) {
    final montantCtrl =
        TextEditingController(text: facture.restantDu.toStringAsFixed(0));
    PaiementMode mode = PaiementMode.especes;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Enregistrer un paiement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PremiumTextField(
                label: 'Montant',
                controller: montantCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PaiementMode>(
                initialValue: mode,
                items: PaiementMode.values.map((m) {
                  return DropdownMenuItem(value: m, child: Text(m.name));
                }).toList(),
                onChanged: (v) => setState(() => mode = v!),
                decoration: const InputDecoration(labelText: 'Mode de paiement'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            GlowButton(
              label: 'VALIDER',
              onPressed: () async {
                final montant = double.tryParse(montantCtrl.text);
                if (montant == null || montant <= 0) return;
                try {
                  final newPaye = facture.montantPaye + montant;
                  final statut = newPaye >= facture.total
                      ? FactureStatus.payee
                      : FactureStatus.partielle;
                  final updated = facture.copyWith(
                    montantPaye: newPaye,
                    statut: statut,
                    datePaiement: DateTime.now(),
                    modePaiement: mode,
                  );
                  final repo = ref.read(hiveRepositoryProvider);
                  await repo.saveFacture(updated);
                  ref.invalidate(facturesProvider);
                  ref.invalidate(factureProviderById(facture.id));
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  if (!context.mounted) return;
                  context.showSnackBar('Paiement enregistré');
                } catch (e) {
                  if (!context.mounted) return;
                  context.showSnackBar('Erreur: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ',
              style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary)),
          Text(value, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;
  const _TotalRow(this.label, this.value,
      {this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              )),
          Text(value,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
                color: color,
              )),
        ],
      ),
    );
  }
}
