import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/core/extensions/date_extensions.dart';
import 'package:devis/core/extensions/num_extensions.dart';
import 'package:devis/core/constants/app_constants.dart';
import 'package:devis/data/models/devis.dart';
import 'package:devis/data/models/facture.dart';
import 'package:devis/data/providers/providers.dart';
import 'package:devis/data/providers/settings_provider.dart';
import 'package:devis/services/pdf_receipt_template.dart';
import 'package:devis/services/pdf_service.dart';
import 'package:devis/services/invoice_pdf_template.dart';
import 'package:devis/services/bluetooth_service.dart';

class DevisDetailPage extends ConsumerStatefulWidget {
  final String devisId;
  const DevisDetailPage({super.key, required this.devisId});

  @override
  ConsumerState<DevisDetailPage> createState() => _DevisDetailPageState();
}

class _DevisDetailPageState extends ConsumerState<DevisDetailPage> {
  final _bluetoothService = BluetoothService();

  Future<void> _printBluetooth(Devis d) async {
    try {
      final info = await ref.read(technicienInfoProvider.future);
      final settings = ref.read(appSettingsProvider);
      final doc = await InvoicePdfTemplate.buildDevisDocument(
        devis: d,
        info: info,
        settings: settings,
      );
      final pdfBytes = await doc.save();
      final pdfService = PdfService();
      await pdfService.printPdf(pdfBytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impression envoyée')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _sharePdf(Devis d) async {
    try {
      final info = await ref.read(technicienInfoProvider.future);
      final settings = ref.read(appSettingsProvider);
      final doc = await InvoicePdfTemplate.buildDevisDocument(
        devis: d,
        info: info,
        settings: settings,
      );
      final pdfBytes = await doc.save();
      final pdfService = PdfService();
      await pdfService.sharePdf(pdfBytes, d.numero);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _generateReceipt(Devis d) async {
    try {
      final settings = ref.read(appSettingsProvider);
      final pdfBytes = await PdfReceiptTemplate.generate(
        devis: d,
        settings: settings,
        amountPaid: d.netAPayer,
      );
      final pdfService = PdfService();
      await pdfService.printPdf(pdfBytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reçu généré')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur reçu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final devisAsync = ref.watch(devisProviderById(widget.devisId));

    return devisAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Erreur: $e')),
      ),
      data: (devis) {
        if (devis == null) {
          return const Scaffold(body: Center(child: Text('Devis introuvable')));
        }
        final d = devis;
        return Scaffold(
          appBar: PremiumAppBar(
            title: d.numero,
            isDark: isDark,
            actions: [
              PopupMenuButton<String>(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'modifier', child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Modifier'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )),
                  const PopupMenuItem(value: 'pdf', child: ListTile(
                    leading: Icon(Icons.picture_as_pdf),
                    title: Text('PDF'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )),
                  const PopupMenuItem(value: 'partager', child: ListTile(
                    leading: Icon(Icons.share_outlined),
                    title: Text('Partager'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )),
                  const PopupMenuItem(value: 'recu', child: ListTile(
                    leading: Icon(Icons.receipt_long_outlined),
                    title: Text('Reçu'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )),
                  const PopupMenuItem(value: 'whatsapp', child: ListTile(
                    leading: Icon(Icons.chat_rounded, color: Color(0xFF25D366)),
                    title: Text('WhatsApp'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )),
                  const PopupMenuItem(value: 'bluetooth', child: ListTile(
                    leading: Icon(Icons.bluetooth),
                    title: Text('Imprimer Bluetooth'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )),
                  const PopupMenuItem(value: 'dupliquer', child: ListTile(
                    leading: Icon(Icons.copy_outlined),
                    title: Text('Dupliquer'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )),
                  if (d.statut == 'accepté')
                    const PopupMenuItem(value: 'facture', child: ListTile(
                      leading: Icon(Icons.receipt),
                      title: Text('Convertir en facture'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    )),
                  const PopupMenuItem(value: 'supprimer', child: ListTile(
                    leading: Icon(Icons.delete_outline, color: Colors.red),
                    title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )),
                ],
                onSelected: (value) async {
                  if (value == 'modifier') {
                    context.push('/devis/edit/${d.id}', extra: d);
                  }
                  if (value == 'pdf') await _sharePdf(d);
                  if (value == 'partager') await _sharePdf(d);
                  if (value == 'recu') await _generateReceipt(d);
                  if (value == 'bluetooth') await _printBluetooth(d);
                  if (value == 'whatsapp') {
                    final text = 'Devis ${d.numero}\n'
                        'Client: ${d.client.nomComplet}\n'
                        'Total: ${d.netAPayer.formattedCurrency}\n'
                        '${AppConstants.companyName}';
                    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("WhatsApp n'est pas installé")),
                      );
                    }
                  }
                  if (value == 'dupliquer') _duplicateDevis(d);
                  if (value == 'facture') await _convertToInvoice(d);
                  if (value == 'supprimer') await _deleteDevis(d);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(d, isDark),
                const SizedBox(height: 16),
                _buildClientSection(d, isDark),
                const SizedBox(height: 16),
                _buildActionsRow(d),
                const SizedBox(height: 12),
                if (d.statut != 'accepté')
                  _buildValidateButton(d),
                const SizedBox(height: 16),
                _buildItemsSection(d),
                const SizedBox(height: 16),
                _buildTotalsCard(d),
                if (d.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildNotesCard(d, isDark),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(Devis d, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.description_rounded, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Devis N° ${d.numero}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    )),
                const SizedBox(height: 4),
                Text(d.date.formatted,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    )),
              ],
            ),
          ),
          _StatusChip(
            label: d.statut.toUpperCase(),
            color: d.statut == 'accepté'
                ? const Color(0xFF06D6A0)
                : d.statut == 'envoyé'
                    ? const Color(0xFF4895EF)
                    : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildClientSection(Devis d, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_rounded, size: 16, color: AppColors.electricBlue),
              const SizedBox(width: 8),
              Text('CLIENT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.electricBlue,
                    letterSpacing: 1,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Text(d.client.nomComplet,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              )),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.phone_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(d.client.contact,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.build_rounded, size: 16, color: AppColors.electricPurple),
              const SizedBox(width: 8),
              Text('TECHNICIEN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.electricPurple,
                    letterSpacing: 1,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Text(d.technicien.nomComplet,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              )),
        ],
      ),
    );
  }

  Widget _buildActionsRow(Devis d) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF',
            color: const Color(0xFF2563EB),
            onTap: () => _sharePdf(d),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.share_rounded,
            label: 'Partager',
            color: const Color(0xFF7B61FF),
            onTap: () => _sharePdf(d),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.receipt_long_rounded,
            label: 'Reçu',
            color: const Color(0xFF06D6A0),
            onTap: () => _generateReceipt(d),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.bluetooth_rounded,
            label: 'Bluetooth',
            color: const Color(0xFF4895EF),
            onTap: () => _printBluetooth(d),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(Devis d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('Articles (${d.lignes.length})',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: const Color(0xFFF8FAFC),
                  child: Row(
                    children: [
                      _itemHeader('Qté', flex: 1),
                      _itemHeader('Désignation', flex: 3),
                      _itemHeader('P.U', flex: 2, align: TextAlign.end),
                      _itemHeader('Total', flex: 2, align: TextAlign.end),
                    ],
                  ),
                ),
                ...List.generate(d.lignes.length, (i) {
                  final item = d.lignes[i];
                  final isEven = i.isEven;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    color: isEven ? Colors.white : const Color(0xFFF8FAFC),
                    child: Row(
                      children: [
                        _itemCell('${item.quantite}', flex: 1, align: TextAlign.center),
                        _itemCell(item.designation, flex: 3),
                        _itemCell(item.prixUnitaire.formattedCurrency, flex: 2, align: TextAlign.end),
                        _itemCell(item.prixTotal.formattedCurrency, flex: 2, align: TextAlign.end, bold: true),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalsCard(Devis d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        children: [
          _totalRow('Total achat', d.totalAchat.formattedCurrency),
          if (d.mainOeuvre > 0) ...[
            const SizedBox(height: 8),
            _totalRow("Main d'œuvre", d.mainOeuvre.formattedCurrency),
          ],
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.lightBorder),
          const SizedBox(height: 12),
          _totalRow(
            'NET À PAYER',
            d.netAPayer.formattedCurrency,
            bold: true,
            color: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(Devis d, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text('Description',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Text(d.description,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              )),
        ],
      ),
    );
  }

  Future<void> _duplicateDevis(Devis d) async {
    try {
      final newDevis = Devis(
        id: const Uuid().v4(),
        numero: d.numero,
        date: DateTime.now(),
        client: Client(
          nom: d.client.nom,
          prenom: d.client.prenom,
          contact: d.client.contact,
        ),
        technicien: Technicien(
          nom: d.technicien.nom,
          prenom: d.technicien.prenom,
        ),
        description: d.description,
        lignes: d.lignes
            .map((l) => LigneDevis(
                  quantite: l.quantite,
                  designation: l.designation,
                  prixUnitaire: l.prixUnitaire,
                ))
            .toList(),
        mainOeuvre: d.mainOeuvre,
        statut: 'brouillon',
      );
      final repo = ref.read(hiveRepositoryProvider);
      await repo.saveDevis(newDevis);
      ref.invalidate(devisProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Devis dupliqué')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _convertToInvoice(Devis d) async {
    try {
      final facture = Facture.fromDevis(d);
      final repo = ref.read(hiveRepositoryProvider);
      await repo.saveFacture(facture);
      final updatedDevis = d.copyWith(statut: 'accepté');
      await repo.saveDevis(updatedDevis);
      ref.invalidate(devisProvider);
      ref.invalidate(facturesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Facture créée avec succès'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'VOIR',
              onPressed: () => GoRouter.of(context).push('/factures/${facture.id}'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _deleteDevis(Devis d) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le devis'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        final repo = ref.read(hiveRepositoryProvider);
        await repo.deleteDevis(d.id);
        ref.invalidate(devisProvider);
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Devis supprimé')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  Widget _buildValidateButton(Devis d) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _validateDevis(d),
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        label: const Text('Valider le paiement',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF059669),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _validateDevis(Devis d) async {
    try {
      final repo = ref.read(hiveRepositoryProvider);
      final updated = d.copyWith(statut: 'accepté');
      await repo.saveDevis(updated);
      final facture = Facture.fromDevis(updated);
      await repo.saveFacture(facture);
      ref.invalidate(devisProviderById(d.id));
      ref.invalidate(devisProvider);
      ref.invalidate(facturesProvider);

      final settings = ref.read(appSettingsProvider);
      final pdfBytes = await PdfReceiptTemplate.generate(
        devis: updated,
        settings: settings,
        amountPaid: updated.netAPayer,
      );
      final dir = await _getTempDir();
      final file = File('${dir.path}/recu_${updated.numero}.pdf');
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Paiement validé — Reçu généré'),
            action: SnackBarAction(
              label: 'Partager',
              textColor: Colors.white,
              onPressed: () {
                final pdfService = PdfService();
                pdfService.sharePdf(pdfBytes, 'recu_${updated.numero}');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<Directory> _getTempDir() async {
    return Directory.systemTemp;
  }

  Widget _itemHeader(String text, {int flex = 1, TextAlign align = TextAlign.start}) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
          textAlign: align),
    );
  }

  Widget _itemCell(String text, {int flex = 1, TextAlign align = TextAlign.start, bool bold = false}) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          textAlign: align),
    );
  }

  Widget _totalRow(String label, String value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: bold ? 16 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            )),
        Text(value,
            style: TextStyle(
              fontSize: bold ? 20 : 13,
              fontWeight: FontWeight.w800,
              color: color ?? AppColors.textPrimary,
            )),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 1,
          )),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
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
