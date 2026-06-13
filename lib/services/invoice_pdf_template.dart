import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:devis/data/models/devis.dart';
import 'package:devis/data/models/facture.dart';
import 'package:devis/data/models/technicien_info.dart';
import 'package:devis/data/models/app_settings.dart';
import 'package:devis/core/extensions/num_extensions.dart';
import 'package:devis/core/extensions/date_extensions.dart';
import 'package:devis/core/utils/enums.dart';

class InvoicePdfTemplate {
  InvoicePdfTemplate._();

  static const PdfColor _blue = PdfColor.fromInt(0xFF2563EB);
  static const PdfColor _blueLight = PdfColor.fromInt(0xFFDBEAFE);
  static const PdfColor _darkBg = PdfColor.fromInt(0xFF0F172A);
  static const PdfColor _gray = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor _white = PdfColor.fromInt(0xFFFFFFFF);
  static const PdfColor _text = PdfColor.fromInt(0xFF1E293B);
  static const PdfColor _sub = PdfColor.fromInt(0xFF64748B);
  static const PdfColor _muted = PdfColor.fromInt(0xFF94A3B8);
  static const PdfColor _line = PdfColor.fromInt(0xFFDBEAFE);

  static const double _cm = 28.35;

  static Future<pw.Document> buildDevisDocument({
    required Devis devis,
    required TechnicienInfo info,
    required AppSettings settings,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(1 * _cm),
        build: (ctx) => pw.Column(
          children: [
            _buildHeader(settings, 6 * _cm),
            pw.SizedBox(height: 1 * _cm),
            _buildTitle('DEVIS ESTIMATIF', devis.numero),
            pw.SizedBox(height: 1 * _cm),
            _buildClientInfo(devis.client, 5 * _cm),
            pw.SizedBox(height: 0.5 * _cm),
            _buildDescription(devis.description),
            pw.SizedBox(height: 1 * _cm),
            _buildItemsTable(devis.lignes),
            pw.SizedBox(height: 0.5 * _cm),
            _buildTotals(devis.totalAchat, devis.mainOeuvre, devis.netAPayer),
            pw.SizedBox(height: 0.5 * _cm),
            _buildFooter(devis.technicien, settings),
          ],
        ),
      ),
    );
    return doc;
  }

  static Future<pw.Document> buildFactureDocument({
    required Facture facture,
    required TechnicienInfo info,
    required AppSettings settings,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(1 * _cm),
        build: (ctx) => pw.Column(
          children: [
            _buildHeader(settings, 6 * _cm),
            pw.SizedBox(height: 1 * _cm),
            _buildTitle('FACTURE', facture.numero),
            pw.SizedBox(height: 1 * _cm),
            _buildClientInfoFacture(facture, 5 * _cm),
            pw.SizedBox(height: 0.5 * _cm),
            pw.SizedBox(height: 1 * _cm),
            _buildItemsTable(facture.items),
            pw.SizedBox(height: 0.5 * _cm),
            _buildInvoiceTotals(facture),
            pw.SizedBox(height: 0.5 * _cm),
            _buildFooter(Technicien(nom: '', prenom: ''), settings),
          ],
        ),
      ),
    );
    return doc;
  }

  static pw.Widget _buildHeader(AppSettings settings, double height) {
    final hasLogo = settings.logoPath.isNotEmpty && File(settings.logoPath).existsSync();
    return pw.Container(
      height: height,
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (hasLogo)
                pw.Container(
                  width: 48, height: 48,
                  child: pw.Image(
                    pw.MemoryImage(File(settings.logoPath).readAsBytesSync()),
                    fit: pw.BoxFit.contain,
                  ),
                ),
              if (hasLogo) pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(settings.companyName.isNotEmpty ? settings.companyName : 'YTech Pro',
                        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _darkBg)),
                    if (settings.phone.isNotEmpty || settings.address.isNotEmpty)
                      pw.SizedBox(height: 4),
                    if (settings.phone.isNotEmpty)
                      pw.Text(settings.phone,
                          style: pw.TextStyle(fontSize: 9, color: _sub)),
                    if (settings.address.isNotEmpty)
                      pw.Text(settings.address,
                          style: pw.TextStyle(fontSize: 9, color: _sub)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Container(height: 1.5, color: _line),
        ],
      ),
    );
  }

  static pw.Widget _buildTitle(String title, String numero) {
    return pw.Column(
      children: [
        pw.Text(title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _darkBg, letterSpacing: 4)),
        pw.SizedBox(height: 0.5 * _cm),
        pw.Text('N° $numero',
            style: pw.TextStyle(fontSize: 11, color: _sub)),
      ],
    );
  }

  static pw.Widget _buildClientInfo(Client client, double height) {
    return pw.Container(
      height: height,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: _gray,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
        border: pw.Border.all(color: _line, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: [
          pw.Text('Client', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _blue, letterSpacing: 1)),
          pw.SizedBox(height: 4),
          pw.Text('Nom : ${client.nomComplet}', style: pw.TextStyle(fontSize: 10, color: _text)),
          if (client.contact.isNotEmpty)
            pw.Text('Numéro : ${client.contact}', style: pw.TextStyle(fontSize: 10, color: _text)),
        ],
      ),
    );
  }

  static pw.Widget _buildClientInfoFacture(Facture facture, double height) {
    return pw.Container(
      height: height,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: _gray,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
        border: pw.Border.all(color: _line, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: [
          pw.Text('Client', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _blue, letterSpacing: 1)),
          pw.Text(facture.clientNom, style: pw.TextStyle(fontSize: 10, color: _text)),
        ],
      ),
    );
  }

  static pw.Widget _buildDescription(String description) {
    if (description.isEmpty) return pw.SizedBox();
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Description du travail : ',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _sub)),
        pw.Expanded(
          child: pw.Text(description,
              style: pw.TextStyle(fontSize: 9, color: _text)),
        ),
      ],
    );
  }

  static pw.Widget _buildItemsTable(List<LigneDevis> items) {
    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(color: _darkBg),
        children: [
          _cell('DÉSIGNATION', bold: true, color: _white, fontSize: 8),
          _cell('QTÉ', bold: true, color: _white, align: pw.TextAlign.center, fontSize: 8),
          _cell('P.U', bold: true, color: _white, align: pw.TextAlign.right, fontSize: 8),
          _cell('TOTAL', bold: true, color: _white, align: pw.TextAlign.right, fontSize: 8),
        ],
      ),
    ];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final bg = i.isEven ? _white : _gray;
      rows.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: bg),
        children: [
          _cell(item.designation, fontSize: 8),
          _cell('${item.quantite}', align: pw.TextAlign.center, fontSize: 8),
          _cell(item.prixUnitaire.formattedCurrency, align: pw.TextAlign.right, fontSize: 8),
          _cell(item.prixTotal.formattedCurrency, align: pw.TextAlign.right, bold: true, fontSize: 8),
        ],
      ));
    }

    return pw.Table(
      border: pw.TableBorder.all(color: _line, width: 0.3),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FixedColumnWidth(30),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
      },
      children: rows,
    );
  }

  static pw.Widget _buildTotals(int totalAchat, int mainOeuvre, int netAPayer) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _totalLine('Total matériel', totalAchat.formattedCurrency),
        _totalLine('Main d\'œuvre', mainOeuvre.formattedCurrency),
        pw.SizedBox(height: 4),
        pw.Container(width: 160, height: 0.5, color: _line),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: pw.BoxDecoration(
            color: _darkBg,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text('NET À PAYER',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _white, letterSpacing: 1)),
              pw.SizedBox(width: 16),
              pw.Text(netAPayer.formattedCurrency,
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _white)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceTotals(Facture facture) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _totalLine('Sous-total', facture.sousTotal.formattedCurrency),
        if (facture.remise > 0) _totalLine('Remise', '-${facture.remise.formattedCurrency}'),
        if (facture.tva > 0) _totalLine('TVA (${facture.tva.toStringAsFixed(0)}%)', facture.montantTva.formattedCurrency),
        pw.SizedBox(height: 4),
        pw.Container(width: 160, height: 0.5, color: _line),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: pw.BoxDecoration(
            color: _darkBg,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text('TOTAL',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _white, letterSpacing: 1)),
              pw.SizedBox(width: 16),
              pw.Text(facture.total.formattedCurrency,
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _white)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(Technicien technicien, AppSettings settings) {
    return pw.Container(
      height: 8 * _cm,
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.SizedBox(height: 20),
                  pw.Container(width: 140, height: 0.5, color: _line),
                  pw.SizedBox(height: 4),
                  pw.Text(technicien.nomComplet.toUpperCase(),
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _blue)),
                  pw.Text(settings.phone,
                      style: pw.TextStyle(fontSize: 8, color: _sub)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _totalLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text('$label : ', style: pw.TextStyle(fontSize: 8, color: _sub)),
          pw.Text(value, style: pw.TextStyle(fontSize: 8, color: _text)),
        ],
      ),
    );
  }

  static pw.Widget _cell(String text,
      {pw.TextAlign align = pw.TextAlign.left, bool bold = false, PdfColor? color, double fontSize = 8}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: pw.Text(text,
          textAlign: align,
          style: pw.TextStyle(fontSize: fontSize, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color)),
    );
  }
}
