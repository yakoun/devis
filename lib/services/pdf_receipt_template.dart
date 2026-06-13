import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:devis/data/models/app_settings.dart';
import 'package:devis/data/models/devis.dart';
import 'package:devis/core/extensions/num_extensions.dart';

class PdfReceiptTemplate {
  static Future<Uint8List> generate({
    required Devis devis,
    required AppSettings settings,
    required int amountPaid,
    String amountWords = '',
  }) async {
    final pdf = pw.Document();
    final red = PdfColor.fromInt(0xFFB91C1C);
    final redLight = PdfColor.fromInt(0xFFFEE2E2);
    final dark = PdfColor.fromInt(0xFF0F172A);
    final muted = PdfColor.fromInt(0xFF64748B);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(340, 500),
        margin: const pw.EdgeInsets.all(8),
        build: (ctx) => pw.Stack(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: red, width: 1.2),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              ),
              child: pw.Column(
                children: [
                  _header(settings, red, dark, muted),
                  pw.SizedBox(height: 6),
                  pw.Container(height: 1, color: redLight),
                  pw.SizedBox(height: 10),
                  _title(red),
                  pw.SizedBox(height: 12),
                  _amount(amountPaid, red, dark),
                  pw.SizedBox(height: 14),
                  _row('Client', devis.client.nomComplet, muted, dark),
                  pw.SizedBox(height: 8),
                  _row('Motif', devis.description.isNotEmpty ? devis.description : 'Prestation', muted, dark),
                  pw.SizedBox(height: 8),
                  _row('Date', _dateStr(), muted, dark),
                  pw.SizedBox(height: 8),
                  _row('N°', devis.numero, muted, dark, bold: false),
                  pw.SizedBox(height: 12),
                  pw.Container(height: 0.5, color: muted),
                  pw.SizedBox(height: 8),
                  _footer(settings, muted, dark),
                ],
              ),
            ),
            pw.Positioned(
              right: 10,
              bottom: 60,
              child: _buildStamp(red),
            ),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  static pw.Widget _header(AppSettings s, PdfColor red, PdfColor dark, PdfColor muted) {
    return pw.Row(
      children: [
        pw.Container(
          width: 28, height: 28,
          decoration: pw.BoxDecoration(
            color: red,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Center(
            child: pw.Text(s.companyName.isNotEmpty ? s.companyName.substring(0, 1).toUpperCase() : 'Y',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFFFFFFFF))),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(s.companyName, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: dark)),
              if (s.phone.isNotEmpty)
                pw.Text(s.phone, style: pw.TextStyle(fontSize: 7, color: muted)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _title(PdfColor red) {
    return pw.Column(
      children: [
        pw.Text('R E Ç U  D E  P A I E M E N T',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: red, letterSpacing: 2)),
        pw.SizedBox(height: 2),
        pw.Container(width: 80, height: 1.5, color: red),
      ],
    );
  }

  static pw.Widget _amount(int amount, PdfColor red, PdfColor dark) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: pw.BoxDecoration(
        color: red,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text('MONTANT  ',
              style: pw.TextStyle(fontSize: 7, color: PdfColor.fromInt(0xFFFFFFFF), letterSpacing: 1)),
          pw.Text(amount.formattedCurrency,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFFFFFFFF))),
        ],
      ),
    );
  }

  static pw.Widget _row(String label, String value, PdfColor muted, PdfColor dark, {bool bold = true}) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 40,
          child: pw.Text('$label :',
              style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: muted)),
        ),
        pw.Expanded(
          child: pw.Text(value,
              style: pw.TextStyle(fontSize: 7, color: dark, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ),
      ],
    );
  }

  static pw.Widget _footer(AppSettings s, PdfColor muted, PdfColor dark) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        if (s.email.isNotEmpty)
          pw.Text(s.email, style: pw.TextStyle(fontSize: 6, color: muted)),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.SizedBox(height: 12),
            pw.Container(width: 60, height: 0.5, color: muted),
            pw.SizedBox(height: 2),
            pw.Text('Signature', style: pw.TextStyle(fontSize: 5, color: muted)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildStamp(PdfColor red) {
    final white = PdfColor.fromInt(0xFFFFFFFF);
    return pw.Container(
      width: 80,
      height: 80,
      child: pw.Stack(
        alignment: pw.Alignment.center,
        children: [
          pw.Container(
            width: 78, height: 78,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: PdfColor.fromInt(0xFFFFF8F5),
              border: pw.Border.all(color: red, width: 2),
            ),
          ),
          pw.Container(
            width: 68, height: 68,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: red, width: 1),
            ),
          ),
          pw.Container(
            width: 34, height: 34,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: red, width: 1.2),
            ),
          ),
          pw.Transform.rotate(
            angle: -0.1,
            child: pw.Text('PAYÉ',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: red, letterSpacing: 2)),
          ),
        ],
      ),
    );
  }

  static String _dateStr() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }
}
