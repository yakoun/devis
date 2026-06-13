import 'package:flutter_test/flutter_test.dart';
import 'package:devis/data/models/client.dart';
import 'package:devis/core/utils/enums.dart';

void main() {
  group('Client', () {
    test('create generates valid client', () {
      final client = AppClient.create(
        nom: 'Dupont',
        telephone: '0123456789',
        email: 'test@test.com',
        category: ClientCategory.entreprise,
      );

      expect(client.nom, 'Dupont');
      expect(client.telephone, '0123456789');
      expect(client.email, 'test@test.com');
      expect(client.category, ClientCategory.entreprise);
      expect(client.isArchived, false);
    });

    test('copyWith updates fields', () {
      final client = AppClient.create(nom: 'Dupont', telephone: '01');
      final archived = client.copyWith(isArchived: true, nom: 'Martin');

      expect(archived.nom, 'Martin');
      expect(archived.isArchived, true);
      expect(archived.id, client.id);
    });

    test('toJson / fromJson roundtrip', () {
      final client = AppClient.create(
        nom: 'Martin',
        telephone: '06',
        email: 'm@test.com',
        adresse: 'Rue de Paris',
        ville: 'Paris',
        siret: '123456789',
      );
      final json = client.toJson();
      final restored = AppClient.fromJson(json);

      expect(restored.id, client.id);
      expect(restored.nom, client.nom);
      expect(restored.email, client.email);
      expect(restored.adresse, client.adresse);
      expect(restored.siret, client.siret);
    });
  });
}
