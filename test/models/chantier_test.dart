import 'package:flutter_test/flutter_test.dart';
import 'package:devis/data/models/chantier.dart';
import 'package:devis/core/utils/enums.dart';

void main() {
  group('Chantier', () {
    test('create generates valid chantier', () {
      final chantier = Chantier.create(
        nom: 'Chantier Test',
        description: 'Description',
        clientNom: 'Client A',
        adresse: '123 Rue',
        budget: 5000,
      );

      expect(chantier.nom, 'Chantier Test');
      expect(chantier.description, 'Description');
      expect(chantier.clientNom, 'Client A');
      expect(chantier.budget, 5000);
      expect(chantier.statut, ChantierStatus.planifie);
    });

    test('copyWith updates status and fields', () {
      final c = Chantier.create(nom: 'Test');
      final updated = c.copyWith(
        statut: ChantierStatus.enCours,
        tempsPasse: const Duration(hours: 2),
      );

      expect(updated.statut, ChantierStatus.enCours);
      expect(updated.tempsPasse.inHours, 2);
    });

    test('toJson / fromJson roundtrip', () {
      final c = Chantier.create(
        nom: 'Test',
        description: 'Desc',
        budget: 1000,
      );
      final json = c.toJson();
      final restored = Chantier.fromJson(json);

      expect(restored.id, c.id);
      expect(restored.nom, c.nom);
      expect(restored.budget, c.budget);
      expect(restored.statut, c.statut);
    });
  });

  group('ChecklistItem', () {
    test('create and copy', () {
      final item = ChecklistItem.create('Vérifier câblage');
      expect(item.libelle, 'Vérifier câblage');
      expect(item.isDone, false);

      final done = item.copyWith(isDone: true);
      expect(done.isDone, true);
      expect(done.id, item.id);
    });

    test('toJson / fromJson roundtrip', () {
      final item = ChecklistItem.create('Test');
      final json = item.toJson();
      final restored = ChecklistItem.fromJson(json);
      expect(restored.id, item.id);
      expect(restored.libelle, item.libelle);
    });
  });
}
