import 'package:flutter/material.dart';
import 'package:devis/data/models/devis.dart';
import 'package:devis/features/devis/presentation/widgets/devis_viewer.dart';
import 'package:devis/services/pdf_devis_generator.dart';

final devisExemple = Devis(
  id: 'DEV-2025-001',
  numero: '2025/001',
  date: DateTime(2025, 3, 15),
  client: Client(
    nom: 'PAPA LUC',
    prenom: '',
    contact: '90 21 86 50',
  ),
  technicien: Technicien(
    nom: 'YAKOUN',
    prenom: 'Ouniboryabi',
  ),
  description:
      'Installation électrique de deux chambres salon, cuisine, terrasse et WC-douche',
  lignes: [
    LigneDevis(quantite: 1, designation: 'Mikrotik RB951', prixUnitaire: 38000),
    LigneDevis(quantite: 1, designation: 'Tenda VENAVI M2', prixUnitaire: 28000),
    LigneDevis(quantite: 1, designation: 'Tuyau Galva 20/27', prixUnitaire: 5000),
    LigneDevis(quantite: 10, designation: 'Connecteur RJ45', prixUnitaire: 100),
    LigneDevis(quantite: 20, designation: 'Cables RJ45', prixUnitaire: 200),
  ],
  mainOeuvre: 15000,
);

class DevisPreviewPage extends StatelessWidget {
  const DevisPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aperçu Devis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Exporter PDF',
            onPressed: () => PdfDevisGenerator.generate(devisExemple),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: DevisViewer(devis: devisExemple),
      ),
    );
  }
}
