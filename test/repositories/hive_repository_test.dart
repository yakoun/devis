import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:devis/data/repositories/hive_repository.dart';
import 'package:devis/data/models/client.dart';
import 'package:devis/data/models/devis.dart';
import 'package:devis/data/models/facture.dart';
import 'package:devis/data/models/chantier.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:devis/core/constants/app_constants.dart';

void main() {
  setUpAll(() async {
    Hive.init('test_hive_dir');
    await Hive.openBox(AppConstants.hiveBoxName);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk(AppConstants.hiveBoxName);
    await Hive.deleteFromDisk();
  });

  group('HiveRepository', () {
    late HiveRepository repo;

    setUp(() async {
      await HiveRepository.ensureInitialized();
      repo = HiveRepository.instance;
      await repo.clearAll();
    });

    test('save and get clients', () async {
      final client = AppClient.create(nom: 'Test', telephone: '01');
      await repo.saveClient(client);

      final clients = await repo.getClients();
      expect(clients.length, 1);
      expect(clients.first.nom, 'Test');
    });

    test('save and get devis', () async {
      final devis = Devis(
        id: 'd1',
        numero: 'DEV-001',
        date: DateTime(2025, 1, 1),
        client: Client(nom: 'Client', contact: 'c1'),
        technicien: Technicien(nom: 'Tech', prenom: 'Jean'),
        description: 'test',
        lignes: [LigneDevis(quantite: 1, designation: 'Item', prixUnitaire: 100)],
        mainOeuvre: 0,
      );
      await repo.saveDevis(devis);

      final devisList = await repo.getDevis();
      expect(devisList.length, 1);
      expect(devisList.first.numero, devis.numero);
    });

    test('save and get factures', () async {
      final facture = Facture.create(
        clientId: 'c1',
        clientNom: 'Client',
        items: [],
      );
      await repo.saveFacture(facture);

      final factures = await repo.getFactures();
      expect(factures.length, 1);
    });

    test('save and get chantiers', () async {
      final chantier = Chantier.create(nom: 'Test Chantier');
      await repo.saveChantier(chantier);

      final chantiers = await repo.getChantiers();
      expect(chantiers.length, 1);
      expect(chantiers.first.nom, 'Test Chantier');
    });

    test('delete client', () async {
      final client = AppClient.create(nom: 'Test', telephone: '01');
      await repo.saveClient(client);
      await repo.deleteClient(client.id);

      final clients = await repo.getClients();
      expect(clients, isEmpty);
    });

    test('export/import json roundtrip', () async {
      final client = AppClient.create(nom: 'Test', telephone: '01');
      await repo.saveClient(client);

      final jsonStr = await repo.exportJson();
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      await repo.clearAll();

      final clientsAfterClear = await repo.getClients();
      expect(clientsAfterClear, isEmpty);

      await repo.importJson(data);
      final clientsAfterImport = await repo.getClients();
      expect(clientsAfterImport.length, 1);
      expect(clientsAfterImport.first.nom, 'Test');
    });
  });
}
