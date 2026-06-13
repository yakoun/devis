import 'package:flutter_test/flutter_test.dart';
import 'package:devis/data/models/devis.dart';

void main() {
  group('Devis', () {
    test('create generates valid devis', () {
      final ligne = LigneDevis(quantite: 2, designation: 'Test', prixUnitaire: 100);
      final devis = Devis(
        id: 'd1',
        numero: 'DEV-001',
        date: DateTime(2025, 1, 1),
        client: Client(nom: 'Test', prenom: 'Client', contact: 'client1'),
        technicien: Technicien(nom: 'Tech', prenom: 'Jean'),
        description: 'Description test',
        lignes: [ligne],
        mainOeuvre: 0,
      );

      expect(devis.client.nomComplet, 'Client Test');
      expect(devis.lignes.length, 1);
      expect(devis.totalAchat, 200);
      expect(devis.netAPayer, 200);
      expect(devis.statut, 'brouillon');
      expect(devis.numero, startsWith('DEV-'));
    });

    test('copyWith preserves fields', () {
      final devis = Devis(
        id: 'c1',
        numero: 'DEV-001',
        date: DateTime(2025, 1, 1),
        client: Client(nom: 'Client', contact: 'c1'),
        technicien: Technicien(nom: 'Tech', prenom: 'Jean'),
        description: 'test',
        lignes: [],
        mainOeuvre: 0,
      );
      final updated = devis.copyWith(statut: 'envoye', description: 'updated');

      expect(updated.statut, 'envoye');
      expect(updated.description, 'updated');
      expect(updated.id, devis.id);
      expect(updated.client.nomComplet, devis.client.nomComplet);
    });

    test('toJson / fromJson roundtrip', () {
      final devis = Devis(
        id: 'c1',
        numero: 'DEV-001',
        date: DateTime(2025, 1, 1),
        client: Client(nom: 'Client', contact: 'c1'),
        technicien: Technicien(nom: 'Tech', prenom: 'Jean'),
        description: 'test',
        lignes: [LigneDevis(quantite: 1, designation: 'Item', prixUnitaire: 50)],
        mainOeuvre: 0,
      );
      final json = devis.toJson();
      final restored = Devis.fromJson(json);

      expect(restored.id, devis.id);
      expect(restored.numero, devis.numero);
      expect(restored.netAPayer, devis.netAPayer);
      expect(restored.statut, devis.statut);
      expect(restored.lignes.length, devis.lignes.length);
    });
  });

  group('LigneDevis', () {
    test('prixTotal is calculated correctly', () {
      final item = LigneDevis(quantite: 3, designation: 'Service', prixUnitaire: 150);

      expect(item.prixTotal, 450);
      expect(item.designation, 'Service');
    });

    test('toJson / fromJson roundtrip', () {
      final item = LigneDevis(quantite: 2, designation: 'Item', prixUnitaire: 75);
      final json = item.toJson();
      final restored = LigneDevis.fromJson(json);

      expect(restored.prixTotal, item.prixTotal);
      expect(restored.designation, item.designation);
      expect(restored.quantite, 2);
    });
  });
}
