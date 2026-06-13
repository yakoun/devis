import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/hive_repository.dart';
import '../models/client.dart';
import '../models/devis.dart';
import '../models/facture.dart';
import '../models/chantier.dart';
import '../models/transaction.dart';
import '../models/catalogue_item.dart';
import '../models/technicien_info.dart';

final hiveRepositoryProvider = Provider<HiveRepository>((ref) {
  return HiveRepository.instance;
});

// Theme
final themeModeProvider = StateProvider<bool>((ref) => true);

// Search
final searchQueryProvider = StateProvider<String>((ref) => '');

// Clients
final clientsProvider = FutureProvider<List<AppClient>>((ref) async {
  final repo = ref.read(hiveRepositoryProvider);
  return repo.getClients();
});

// Devis
final devisProvider = FutureProvider<List<Devis>>((ref) async {
  final repo = ref.read(hiveRepositoryProvider);
  return repo.getDevis();
});

// Factures
final facturesProvider = FutureProvider<List<Facture>>((ref) async {
  final repo = ref.read(hiveRepositoryProvider);
  return repo.getFactures();
});

// Chantiers
final chantiersProvider = FutureProvider<List<Chantier>>((ref) async {
  final repo = ref.read(hiveRepositoryProvider);
  return repo.getChantiers();
});

// Transactions
final transactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final repo = ref.read(hiveRepositoryProvider);
  return repo.getTransactions();
});

// Catalogue
final catalogueItemsProvider = FutureProvider<List<CatalogueItem>>((ref) async {
  final repo = ref.read(hiveRepositoryProvider);
  return repo.getCatalogueItems();
});

// Technicien Info
final technicienInfoProvider = FutureProvider<TechnicienInfo>((ref) async {
  final repo = ref.read(hiveRepositoryProvider);
  return repo.getTechnicienInfo();
});

// Family providers for fetching single entities
final clientProvider = FutureProvider.family<AppClient?, String>((ref, id) async {
  final repo = ref.read(hiveRepositoryProvider);
  final clients = await repo.getClients();
  try {
    return clients.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});

final devisProviderById = FutureProvider.family<Devis?, String>((ref, id) async {
  final repo = ref.read(hiveRepositoryProvider);
  final devisList = await repo.getDevis();
  try {
    return devisList.firstWhere((d) => d.id == id);
  } catch (_) {
    return null;
  }
});

final factureProviderById = FutureProvider.family<Facture?, String>((ref, id) async {
  final repo = ref.read(hiveRepositoryProvider);
  final factures = await repo.getFactures();
  try {
    return factures.firstWhere((f) => f.id == id);
  } catch (_) {
    return null;
  }
});

final chantierProviderById = FutureProvider.family<Chantier?, String>((ref, id) async {
  final repo = ref.read(hiveRepositoryProvider);
  final chantiers = await repo.getChantiers();
  try {
    return chantiers.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});

final isSetupCompleteProvider = FutureProvider<bool>((ref) async {
  final repo = ref.read(hiveRepositoryProvider);
  final hasPin = await repo.getSetting('pin_hash') != null;
  final info = await repo.getTechnicienInfo();
  return hasPin && !info.isEmpty;
});

void invalidateAllProviders(WidgetRef ref) {
  ref.invalidate(clientsProvider);
  ref.invalidate(devisProvider);
  ref.invalidate(facturesProvider);
  ref.invalidate(chantiersProvider);
  ref.invalidate(transactionsProvider);
  ref.invalidate(catalogueItemsProvider);
}
