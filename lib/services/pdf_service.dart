import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/devis.dart';
import '../data/models/facture.dart';
import '../data/models/technicien_info.dart';
import '../core/constants/app_constants.dart';

class DevisPdfGenerator {
  final double marginTop;
  final double marginBottom;
  final double marginLeft;
  final double marginRight;

  DevisPdfGenerator({
    this.marginTop = 40,
    this.marginBottom = 40,
    this.marginLeft = 48,
    this.marginRight = 48,
  });

  Future<Uint8List> generateDevisPdf(
    Devis devis,
    TechnicienInfo info,
    List<LigneDevis> items,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.only(
          top: marginTop,
          bottom: marginBottom,
          left: marginLeft,
          right: marginRight,
        ),
        build: (context) => [
          _buildHeader('DEVIS', devis.numero, info),
          pw.SizedBox(height: 32),
          _buildInfoSection(info, devis),
          pw.SizedBox(height: 24),
          _buildDetailsRow(devis),
          pw.SizedBox(height: 24),
          _buildItemsTable(items),
          pw.SizedBox(height: 32),
          _buildTotals(devis.totalAchat, devis.mainOeuvre, devis.netAPayer),
          _buildFooter(info),
        ],
        footer: (context) => _buildPageNumber(context),
      ),
    );
    return pdf.save();
  }

  pw.Widget _buildHeader(String title, String numero, TechnicienInfo info) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  info.entreprise.isNotEmpty ? info.entreprise : AppConstants.companyName,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (info.siret.isNotEmpty)
                  pw.Text(
                    'SIRET: ${info.siret}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey700,
                    ),
                  ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'N° $numero',
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Container(height: 1, color: PdfColors.black),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildInfoSection(TechnicienInfo info, Devis devis) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'ÉMETTEUR',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.5,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (info.entreprise.isNotEmpty)
                      _infoText(info.entreprise, isBold: true),
                    if (info.nom.isNotEmpty || info.prenom.isNotEmpty)
                      _infoText('${info.prenom} ${info.nom}'),
                    if (info.adresse.isNotEmpty) _infoText(info.adresse),
                    if (info.ville.isNotEmpty) _infoText(info.ville),
                    if (info.codePostal.isNotEmpty) _infoText(info.codePostal),
                    if (info.telephone.isNotEmpty) _infoText('Tél: ${info.telephone}'),
                    if (info.email.isNotEmpty) _infoText(info.email),
                    if (info.siret.isNotEmpty) _infoText('SIRET: ${info.siret}'),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 24),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CLIENT',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.5,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _infoText(devis.client.nomComplet, isBold: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _infoText(String text, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildDetailsRow(Devis devis) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        color: PdfColors.grey100,
      ),
      child: pw.Row(
        children: [
          _detailCell('Devis N°', devis.numero),
          _detailCell('Date', '${devis.date.day}/${devis.date.month}/${devis.date.year}'),
          _detailCell('Valable jusqu\'au', '${devis.date.day}/${devis.date.month}/${devis.date.year}'),
          _detailCell('Réf client', devis.client.nomComplet),
        ],
      ),
    );
  }

  pw.Widget _detailCell(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
              letterSpacing: 0.8,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildItemsTable(List<LigneDevis> items) {
    final headers = ['Qté', 'Description', 'Prix unitaire', 'Total'];
    final data = items.map((item) {
      return [
        item.quantite.toString(),
        item.designation,
        '${item.prixUnitaire.toStringAsFixed(0)} FCFA',
        '${item.prixTotal.toStringAsFixed(0)} FCFA',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.3),
        verticalInside: pw.BorderSide.none,
        bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
        top: pw.BorderSide(color: PdfColors.black, width: 0.5),
      ),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
        color: PdfColors.black,
      ),
      headerDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
        ),
      ),
      cellStyle: pw.TextStyle(fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: const pw.FixedColumnWidth(40),
        1: const pw.FlexColumnWidth(),
        2: const pw.FixedColumnWidth(100),
        3: const pw.FixedColumnWidth(100),
      },
    );
  }

  pw.Widget _buildTotals(int totalAchat, int mainOeuvre, int netAPayer) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildTotalRow('Total achats', '${totalAchat.toStringAsFixed(0)} FCFA'),
          if (mainOeuvre > 0)
            _buildTotalRow('Main d\'œuvre', '${mainOeuvre.toStringAsFixed(0)} FCFA'),
          pw.SizedBox(height: 4),
          pw.Container(
            width: 250,
            height: 1,
            color: PdfColors.black,
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: PdfColors.grey100,
            child: pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.SizedBox(
                  width: 120,
                  child: pw.Text(
                    'NET À PAYER',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                pw.SizedBox(
                  width: 130,
                  child: pw.Text(
                    '${netAPayer.toStringAsFixed(0)} FCFA',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTotalRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 9),
            ),
          ),
          pw.SizedBox(
            width: 130,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(TechnicienInfo info) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 40),
        pw.Container(height: 0.5, color: PdfColors.grey400),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                'Merci pour votre confiance',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
            if (info.siret.isNotEmpty)
              pw.Text(
                'SIRET: ${info.siret}',
                style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
              ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '${info.entreprise.isNotEmpty ? info.entreprise : AppConstants.companyName} - ${AppConstants.companySlogan}',
          style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _buildPageNumber(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Page ${context.pageNumber} / ${context.pagesCount}',
        style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
      ),
    );
  }
}

class FacturePdfGenerator {
  final double marginTop;
  final double marginBottom;
  final double marginLeft;
  final double marginRight;

  FacturePdfGenerator({
    this.marginTop = 40,
    this.marginBottom = 40,
    this.marginLeft = 48,
    this.marginRight = 48,
  });

  Future<Uint8List> generateFacturePdf(
    Facture facture,
    TechnicienInfo info,
    List<LigneDevis> items,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.only(
          top: marginTop,
          bottom: marginBottom,
          left: marginLeft,
          right: marginRight,
        ),
        build: (context) => [
          _buildHeader('FACTURE', facture.numero, info),
          pw.SizedBox(height: 32),
          _buildInfoSection(info, facture),
          pw.SizedBox(height: 24),
          _buildDetailsRow(facture),
          pw.SizedBox(height: 24),
          _buildItemsTable(items),
          pw.SizedBox(height: 32),
          _buildTotals(facture.sousTotal, facture.remise, facture.tva,
              facture.montantTva, facture.total),
          _buildPaymentInfo(facture),
          _buildFooter(info),
        ],
        footer: (context) => _buildPageNumber(context),
      ),
    );
    return pdf.save();
  }

  pw.Widget _buildHeader(String title, String numero, TechnicienInfo info) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  info.entreprise.isNotEmpty ? info.entreprise : AppConstants.companyName,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (info.siret.isNotEmpty)
                  pw.Text(
                    'SIRET: ${info.siret}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey700,
                    ),
                  ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'N° $numero',
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Container(height: 1, color: PdfColors.black),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pw.Widget _buildInfoSection(TechnicienInfo info, Facture facture) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'ÉMETTEUR',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.5,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (info.entreprise.isNotEmpty)
                      _infoText(info.entreprise, isBold: true),
                    if (info.nom.isNotEmpty || info.prenom.isNotEmpty)
                      _infoText('${info.prenom} ${info.nom}'),
                    if (info.adresse.isNotEmpty) _infoText(info.adresse),
                    if (info.ville.isNotEmpty) _infoText(info.ville),
                    if (info.codePostal.isNotEmpty) _infoText(info.codePostal),
                    if (info.telephone.isNotEmpty) _infoText('Tél: ${info.telephone}'),
                    if (info.email.isNotEmpty) _infoText(info.email),
                    if (info.siret.isNotEmpty) _infoText('SIRET: ${info.siret}'),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 24),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CLIENT',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.5,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _infoText(facture.clientNom, isBold: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _infoText(String text, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildDetailsRow(Facture facture) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        color: PdfColors.grey100,
      ),
      child: pw.Row(
        children: [
          _detailCell('Facture N°', facture.numero),
          _detailCell('Date d\'émission', '${facture.dateEmission.day}/${facture.dateEmission.month}/${facture.dateEmission.year}'),
          _detailCell('Échéance', '${facture.dateEcheance.day}/${facture.dateEcheance.month}/${facture.dateEcheance.year}'),
          _detailCell('Réf client', facture.clientNom),
        ],
      ),
    );
  }

  pw.Widget _detailCell(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
              letterSpacing: 0.8,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildItemsTable(List<LigneDevis> items) {
    final headers = ['Qté', 'Description', 'Prix unitaire', 'Total'];
    final data = items.map((item) {
      return [
        item.quantite.toString(),
        item.designation,
        '${item.prixUnitaire.toStringAsFixed(0)} FCFA',
        '${item.prixTotal.toStringAsFixed(0)} FCFA',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.3),
        verticalInside: pw.BorderSide.none,
        bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
        top: pw.BorderSide(color: PdfColors.black, width: 0.5),
      ),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
        color: PdfColors.black,
      ),
      headerDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
        ),
      ),
      cellStyle: pw.TextStyle(fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: const pw.FixedColumnWidth(40),
        1: const pw.FlexColumnWidth(),
        2: const pw.FixedColumnWidth(100),
        3: const pw.FixedColumnWidth(100),
      },
    );
  }

  pw.Widget _buildTotals(
    double sousTotal,
    double remise,
    double tva,
    double montantTva,
    double total,
  ) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildTotalRow('Sous-total (HT)', '${sousTotal.toStringAsFixed(0)} FCFA'),
          if (remise > 0)
            _buildTotalRow('Remise', '-${remise.toStringAsFixed(0)} FCFA'),
          _buildTotalRow(
              'TVA (${tva.toStringAsFixed(1)}%)', '${montantTva.toStringAsFixed(0)} FCFA'),
          pw.SizedBox(height: 4),
          pw.Container(
            width: 250,
            height: 1,
            color: PdfColors.black,
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: PdfColors.grey100,
            child: pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.SizedBox(
                  width: 120,
                  child: pw.Text(
                    'TOTAL TTC',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                pw.SizedBox(
                  width: 130,
                  child: pw.Text(
                    '${total.toStringAsFixed(0)} FCFA',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTotalRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 9),
            ),
          ),
          pw.SizedBox(
            width: 130,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPaymentInfo(Facture facture) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Statut',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                    letterSpacing: 0.8,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  facture.statut.name,
                  style: pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Montant payé',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                    letterSpacing: 0.8,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '${facture.montantPaye.toStringAsFixed(0)} FCFA',
                  style: pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Reste dû',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                    letterSpacing: 0.8,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '${facture.restantDu.toStringAsFixed(0)} FCFA',
                  style: pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(TechnicienInfo info) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 40),
        pw.Container(height: 0.5, color: PdfColors.grey400),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                'Merci pour votre confiance',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
            if (info.siret.isNotEmpty)
              pw.Text(
                'SIRET: ${info.siret}',
                style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
              ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '${info.entreprise.isNotEmpty ? info.entreprise : AppConstants.companyName} - ${AppConstants.companySlogan}',
          style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _buildPageNumber(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Page ${context.pageNumber} / ${context.pagesCount}',
        style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
      ),
    );
  }
}

class PdfService {
  late final DevisPdfGenerator _devisGenerator;
  late final FacturePdfGenerator _factureGenerator;

  PdfService() {
    _loadMargins();
  }

  void _loadMargins() {
    try {
      final box = Hive.box('ytech_pro');
      _devisGenerator = DevisPdfGenerator(
        marginTop: _marginValue(box, 'setting_pdf_margin_top', 40),
        marginBottom: _marginValue(box, 'setting_pdf_margin_bottom', 40),
        marginLeft: _marginValue(box, 'setting_pdf_margin_left', 48),
        marginRight: _marginValue(box, 'setting_pdf_margin_right', 48),
      );
      _factureGenerator = FacturePdfGenerator(
        marginTop: _marginValue(box, 'setting_pdf_margin_top', 40),
        marginBottom: _marginValue(box, 'setting_pdf_margin_bottom', 40),
        marginLeft: _marginValue(box, 'setting_pdf_margin_left', 48),
        marginRight: _marginValue(box, 'setting_pdf_margin_right', 48),
      );
    } catch (_) {
      _devisGenerator = DevisPdfGenerator();
      _factureGenerator = FacturePdfGenerator();
    }
  }

  double _marginValue(var box, String key, double defaultValue) {
    final val = box.get(key) as String?;
    if (val == null) return defaultValue;
    final parsed = double.tryParse(val);
    return parsed != null && parsed > 0 ? parsed : defaultValue;
  }

  Future<Uint8List> generateDevisPdf(Devis devis) async {
    final info = await _getTechnicienInfo();
    return _devisGenerator.generateDevisPdf(devis, info, devis.lignes);
  }

  Future<Uint8List> generateFacturePdf(Facture facture) async {
    final info = await _getTechnicienInfo();
    return _factureGenerator.generateFacturePdf(facture, info, facture.items);
  }

  Future<TechnicienInfo> _getTechnicienInfo() async {
    try {
      final box = Hive.box('ytech_pro');
      final json = box.get('setting_technicien_info') as String?;
      if (json != null && json.isNotEmpty) {
        return TechnicienInfo.fromJson(
          Map<String, dynamic>.from(jsonDecode(json) as Map),
        );
      }
    } catch (_) {}
    return const TechnicienInfo();
  }

  Future<void> sharePdf(Uint8List pdfBytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename.pdf');
    await file.writeAsBytes(pdfBytes);
    await Share.shareXFiles([XFile(file.path)], text: filename);
  }

  Future<void> printPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }
}
