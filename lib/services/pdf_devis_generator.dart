import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:devis/data/models/devis.dart';

class PdfDevisGenerator {
  static Future<void> generate(Devis devis) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('ETECH SERVICE',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text('Electricite, Informatique, Reseau Telecom'),
                pw.Text('97 53 33 07 / 91 05 55 72'),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text('DEVIS',
                      style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          decoration: pw.TextDecoration.underline)),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Client',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Nom : ${devis.client.nom}'),
                          if (devis.client.prenom != null && devis.client.prenom!.isNotEmpty)
                            pw.Text('Prénom : ${devis.client.prenom}'),
                          pw.Text('Contact : ${devis.client.contact}'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Technicien',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Nom : ${devis.technicien.nom}'),
                          pw.Text('Prénom : ${devis.technicien.prenom}'),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text('Description : ${devis.description}'),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  headers: ['Qte', 'Désignation', 'Prix unitaire', 'Prix total'],
                  data: devis.lignes.map((l) => [
                    '${l.quantite}',
                    l.designation,
                    '${l.prixUnitaire} FCFA',
                    '${l.prixTotal} FCFA',
                  ]).toList(),
                  border: pw.TableBorder.all(),
                ),
                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Total achat : ${devis.totalAchat} FCFA'),
                      pw.Text('Main d\u2019œuvre : ${devis.mainOeuvre} FCFA'),
                      pw.Divider(),
                      pw.Text('Net à payer : ${devis.netAPayer} FCFA',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'devis_${devis.numero}.pdf');
  }
}
