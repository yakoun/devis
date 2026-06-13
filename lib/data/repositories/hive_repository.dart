import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/client.dart';
import '../models/devis.dart';
import '../models/facture.dart';
import '../models/chantier.dart';
import '../models/transaction.dart';
import '../models/catalogue_data.dart';
import '../models/catalogue_item.dart';
import '../models/technicien_info.dart';
import '../../core/constants/app_constants.dart';

class HiveRepository {
  static HiveRepository? _instance;

  static HiveRepository get instance {
    if (_instance == null) {
      throw StateError(
          'HiveRepository not initialized. Call HiveRepository.ensureInitialized() first.');
    }
    return _instance!;
  }

  static Future<void> ensureInitialized({String? testDir}) async {
    if (_instance != null) return;
    final repo = HiveRepository();
    await repo._init(testDir: testDir);
    _instance = repo;
  }

  late Box _box;

  Future<void> _init({String? testDir}) async {
    try {
      if (testDir != null) {
        Hive.init(testDir);
      } else {
        await Hive.initFlutter();
      }
    } catch (_) {
      // Hive already initialized
    }
    _box = await Hive.openBox(AppConstants.hiveBoxName);
    _seedCatalogue();
  }

  void _seedCatalogue() {
    try {
      if (_box.get('catalogue_seeded') != true) {
        final items = CatalogueData.allItems;
        for (final item in items) {
          _box.put('catalogue_${item.reference}', item.toJson());
        }
        _box.put('catalogue_seeded', true);
      }
    } catch (_) {}
  }

  // Clients
  Future<List<AppClient>> getClients() async {
    try {
      final keys = _box.keys.whereType<String>().where((k) => k.startsWith('client_'));
      return keys.map((k) {
        final data = _box.get(k);
        return AppClient.fromJson(Map<String, dynamic>.from(data));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveClient(AppClient client) async {
    try {
      await _box.put('client_${client.id}', client.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      await _box.delete('client_$id');
    } catch (e) {
      rethrow;
    }
  }

  // Devis
  Future<List<Devis>> getDevis() async {
    try {
      final keys = _box.keys.whereType<String>().where((k) => k.startsWith('devis_'));
      return keys.map((k) {
        final data = _box.get(k);
        return Devis.fromJson(Map<String, dynamic>.from(data));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveDevis(Devis devis) async {
    try {
      await _box.put('devis_${devis.id}', devis.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDevis(String id) async {
    try {
      await _box.delete('devis_$id');
    } catch (e) {
      rethrow;
    }
  }

  // Factures
  Future<List<Facture>> getFactures() async {
    try {
      final keys = _box.keys.whereType<String>().where((k) => k.startsWith('facture_'));
      return keys.map((k) {
        final data = _box.get(k);
        return Facture.fromJson(Map<String, dynamic>.from(data));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveFacture(Facture facture) async {
    try {
      await _box.put('facture_${facture.id}', facture.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFacture(String id) async {
    try {
      await _box.delete('facture_$id');
    } catch (e) {
      rethrow;
    }
  }

  // Chantiers
  Future<List<Chantier>> getChantiers() async {
    try {
      final keys = _box.keys.whereType<String>().where((k) => k.startsWith('chantier_'));
      return keys.map((k) {
        final data = _box.get(k);
        return Chantier.fromJson(Map<String, dynamic>.from(data));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveChantier(Chantier chantier) async {
    try {
      await _box.put('chantier_${chantier.id}', chantier.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteChantier(String id) async {
    try {
      await _box.delete('chantier_$id');
    } catch (e) {
      rethrow;
    }
  }

  // Transactions
  Future<List<Transaction>> getTransactions() async {
    try {
      final keys = _box.keys.whereType<String>().where((k) => k.startsWith('transaction_'));
      return keys.map((k) {
        final data = _box.get(k);
        return Transaction.fromJson(Map<String, dynamic>.from(data));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTransaction(Transaction transaction) async {
    try {
      await _box.put('transaction_${transaction.id}', transaction.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _box.delete('transaction_$id');
    } catch (e) {
      rethrow;
    }
  }

  // Catalogue
  Future<List<CatalogueItem>> getCatalogueItems() async {
    try {
      final keys = _box.keys.whereType<String>().where((k) => k.startsWith('catalogue_') && k != 'catalogue_seeded');
      final stored = keys.map((k) {
        final data = _box.get(k);
        return CatalogueItem.fromJson(Map<String, dynamic>.from(data));
      }).toList();
      final storedRefs = stored.map((e) => 'catalogue_${e.reference}').toSet();
      final missing = CatalogueData.allItems
          .where((e) => !storedRefs.contains('catalogue_${e.reference}'))
          .toList();
      return [...stored, ...missing];
    } catch (e) {
      return CatalogueData.allItems;
    }
  }

  Future<void> saveCatalogueItem(CatalogueItem item) async {
    try {
      await _box.put('catalogue_${item.reference}', item.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Backup
  Future<String> exportJson() async {
    try {
      final data = <String, dynamic>{};
      for (final key in _box.keys) {
        if (key == 'catalogue_seeded') continue;
        data[key.toString()] = _box.get(key);
      }
      return jsonEncode(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> importJson(Map<String, dynamic> data) async {
    try {
      for (final entry in data.entries) {
        await _box.put(entry.key, entry.value);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Settings
  Future<String?> getSetting(String key) async {
    try {
      final val = _box.get('setting_$key');
      return val as String?;
    } catch (e) {
      return null;
    }
  }

  Future<void> setSetting(String key, String value) async {
    try {
      await _box.put('setting_$key', value);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAllSettings() async {
    try {
      final keys = _box.keys.whereType<String>().where((k) => k.startsWith('setting_'));
      final map = <String, dynamic>{};
      for (final k in keys) {
        final settingKey = k.substring('setting_'.length);
        map[settingKey] = _box.get(k);
      }
      return map;
    } catch (e) {
      return {};
    }
  }

  Future<void> clearAll() async {
    try {
      await _box.clear();
    } catch (e) {
      rethrow;
    }
  }

  // Technicien Info
  Future<TechnicienInfo> getTechnicienInfo() async {
    try {
      final json = await getSetting('technicien_info');
      if (json == null || json.isEmpty) return const TechnicienInfo();
      return TechnicienInfo.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return const TechnicienInfo();
    }
  }

  Future<void> saveTechnicienInfo(TechnicienInfo info) async {
    try {
      await setSetting('technicien_info', jsonEncode(info.toJson()));
    } catch (_) {
      rethrow;
    }
  }
}

// NOTE: Sequence counters (Devis._sequence, Facture._factureSeq) are static and reset
// on app restart. To persist sequences across sessions, the counters should be stored
// in Hive settings (e.g., 'devis_sequence', 'facture_sequence') and read on model
// construction. This cannot be fixed without modifying the model constructors, which
// is outside the scope of this change.
