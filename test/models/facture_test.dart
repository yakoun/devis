import 'package:flutter_test/flutter_test.dart';
import 'package:devis/data/models/devis.dart';
import 'package:devis/data/models/facture.dart';
import 'package:devis/core/utils/enums.dart';

void main() {
  group('Facture', () {
    test('fromDevis creates facture from devis', () {
      final devis = Devis(
        id: 'c1',
        numero: 'DEV-001',
        date: DateTime(2025, 1, 1),
        client: Client(nom: 'Client', contact: 'c1'),
        technicien: Technicien(nom: 'Tech', prenom: 'Jean'),
        description: 'test',
        lignes: [LigneDevis(quantite: 2, designation: 'Item', prixUnitaire: 100)],
        mainOeuvre: 0,
      );

      final facture = Facture.fromDevis(devis);

      expect(facture.devisId, devis.id);
      expect(facture.clientId, devis.client.contact);
      expect(facture.total, devis.netAPayer.toDouble());
      expect(facture.statut, FactureStatus.impayee);
      expect(facture.numero, startsWith('FAC-'));
    });

    test('copyWith updates payment fields', () {
      final facture = Facture.create(
        clientId: 'c1',
        clientNom: 'Client',
        items: [],
      );

      final paid = facture.copyWith(
        montantPaye: 500,
        statut: FactureStatus.partielle,
        modePaiement: PaiementMode.virement,
        datePaiement: DateTime(2025, 1, 1),
      );

      expect(paid.montantPaye, 500);
      expect(paid.statut, FactureStatus.partielle);
      expect(paid.modePaiement, PaiementMode.virement);
      expect(paid.datePaiement, DateTime(2025, 1, 1));
    });

    test('restantDu is correct', () {
      final facture = Facture(
        id: 'f1',
        numero: 'FAC-001',
        clientId: 'c1',
        clientNom: 'C',
        items: [],
        sousTotal: 1000,
        montantTva: 200,
        total: 1200,
        montantPaye: 300,
        statut: FactureStatus.partielle,
        dateEmission: DateTime(2025, 1, 1),
        dateEcheance: DateTime(2025, 1, 31),
        updatedAt: DateTime(2025, 1, 1),
      );

      expect(facture.restantDu, 900);
    });

    test('toJson / fromJson roundtrip', () {
      final facture = Facture.create(
        clientId: 'c1',
        clientNom: 'Client',
        items: [
          LigneDevis(quantite: 1, designation: 'Item', prixUnitaire: 100),
        ],
        notes: 'Test',
      );
      final json = facture.toJson();
      final restored = Facture.fromJson(json);

      expect(restored.id, facture.id);
      expect(restored.numero, facture.numero);
      expect(restored.total, facture.total);
      expect(restored.notes, 'Test');
    });
  });
}
