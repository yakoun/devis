import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devis/data/models/devis.dart';
import 'package:devis/core/extensions/num_extensions.dart';
import 'package:devis/core/extensions/date_extensions.dart';

class DevisViewer extends ConsumerWidget {
  final Devis devis;

  const DevisViewer({super.key, required this.devis});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          const Divider(thickness: 1),
          const SizedBox(height: 20),
          _buildTitle(),
          const SizedBox(height: 24),
          _buildClientAndTechnician(),
          const SizedBox(height: 16),
          _buildDescription(),
          const SizedBox(height: 24),
          _buildItemsTable(),
          const SizedBox(height: 4),
          const Divider(thickness: 2),
          const SizedBox(height: 16),
          _buildTotals(),
          const SizedBox(height: 40),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('E',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                )),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ETECH SERVICE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  )),
              SizedBox(height: 4),
              Text('Electricite, Informatique, Reseau Telecom',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              SizedBox(height: 2),
              Text('97 53 33 07 / 91 05 55 72',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ),
        const Text('DEVIS',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2563EB),
            )),
      ],
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('N° DEVIS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                )),
            const SizedBox(height: 4),
            Text(devis.numero,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                )),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('DATE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                )),
            const SizedBox(height: 4),
            Text(devis.date.formatted,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildClientAndTechnician() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CLIENT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  )),
              const SizedBox(height: 8),
              _infoRow('Nom : ', devis.client.nomComplet),
              const SizedBox(height: 4),
              _infoRow('Contact : ', devis.client.contact),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TECHNICIEN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  )),
              const SizedBox(height: 8),
              _infoRow('Nom : ', devis.technicien.nom),
              const SizedBox(height: 4),
              _infoRow('Prénom : ', devis.technicien.prenom),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
        children: [
          TextSpan(text: label),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    if (devis.description.isEmpty) return const SizedBox.shrink();
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
        children: [
          const TextSpan(text: 'Description : '),
          TextSpan(
            text: devis.description,
            style: const TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                _tableHeader('Qté', flex: 1, align: TextAlign.center),
                _tableHeader('Désignation', flex: 3),
                _tableHeader('Prix unitaire', flex: 2, align: TextAlign.end),
                _tableHeader('Prix total', flex: 2, align: TextAlign.end),
              ],
            ),
          ),
          ...List.generate(devis.lignes.length, (i) {
            final item = devis.lignes[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: i.isEven ? Colors.white : const Color(0xFFF8FAFC),
              child: Row(
                children: [
                  _tableCell('${item.quantite.toString().padLeft(2, '0')}',
                      flex: 1, align: TextAlign.center),
                  _tableCell(item.designation, flex: 3),
                  _tableCell(item.prixUnitaire.formattedCurrency, flex: 2, align: TextAlign.end),
                  _tableCell(item.prixTotal.formattedCurrency, flex: 2, align: TextAlign.end, bold: true),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _tableHeader(String text, {int flex = 1, TextAlign align = TextAlign.start}) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
          textAlign: align),
    );
  }

  Widget _tableCell(String text, {int flex = 1, TextAlign align = TextAlign.start, bool bold = false}) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: const Color(0xFF1E293B),
          ),
          textAlign: align),
    );
  }

  Widget _buildTotals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _totalLine('Total achat', devis.totalAchat.formattedCurrency),
        if (devis.mainOeuvre > 0) ...[
          const SizedBox(height: 8),
          _totalLine("Main d'œuvre", devis.mainOeuvre.formattedCurrency),
        ],
        const SizedBox(height: 12),
        const Divider(thickness: 1, height: 1),
        const SizedBox(height: 12),
        _totalLine('Net à payer', devis.netAPayer.formattedCurrency,
            bold: true, accent: true),
      ],
    );
  }

  Widget _totalLine(String label, String value, {bool bold = false, bool accent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 200,
            child: Text(label,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: bold ? 18 : 13,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: const Color(0xFF334155),
                )),
          ),
          const SizedBox(width: 40),
          SizedBox(
            width: 160,
            child: Text(value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: bold ? 22 : 13,
                  fontWeight: FontWeight.w800,
                  color: accent ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Merci de votre confiance',
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        const Text('www.etech-service.com',
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
      ],
    );
  }
}
