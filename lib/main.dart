import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:devis/services/notification_service.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/core/router/app_router.dart';
import 'package:devis/data/providers/providers.dart';
import 'package:devis/data/repositories/hive_repository.dart';
import 'package:devis/core/utils/enums.dart';

const _periodicTaskName = 'com.devis.check_notifications';
const _periodicTaskTag = 'checkNotifications';

@pragma('vm:entry-point')
void callbackDispatcher() async {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        await initializeDateFormatting('fr_FR');
      } catch (_) {
        await initializeDateFormatting();
      }
      await HiveRepository.ensureInitialized();
      final repo = HiveRepository.instance;

      final devis = await repo.getDevis();
      final factures = await repo.getFactures();
      final chantiers = await repo.getChantiers();

      final now = DateTime.now();

      for (final d in devis) {
        if (d.statut == 'envoyé' &&
            now.difference(d.date).inDays >= 7) {
          await showNotification(
            id: 1,
            title: 'Devis en attente',
            body: 'Le devis ${d.numero} est en attente depuis plus de 7 jours.',
          );
        }
      }

      for (final f in factures) {
        if ((f.statut == FactureStatus.impayee ||
                f.statut == FactureStatus.partielle) &&
            now.isAfter(f.dateEcheance)) {
          await showNotification(
            id: 2,
            title: 'Facture impayée',
            body: 'La facture ${f.numero} est en retard de paiement.',
          );
        }
      }

      for (final c in chantiers) {
        if (c.statut == ChantierStatus.enCours &&
            now.difference(c.updatedAt).inDays >= 3) {
          await showNotification(
            id: 3,
            title: 'Chantier sans activité',
            body: 'Le chantier ${c.nom} est sans activité depuis 3 jours.',
          );
        }
      }
    } catch (_) {}
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  try {
    await initializeDateFormatting('fr_FR');
  } catch (_) {
    await initializeDateFormatting();
  }
  await HiveRepository.ensureInitialized();

  try {
    await initNotifications();
  } catch (_) {}
  try {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      _periodicTaskName,
      _periodicTaskTag,
      frequency: const Duration(hours: 1),
      constraints: Constraints(networkType: NetworkType.notRequired),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  } catch (_) {}

  runApp(const ProviderScope(child: YTechProApp()));
}

class YTechProApp extends ConsumerWidget {
  const YTechProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        AppThemePremium.systemOverlay(isDarkMode),
      );
    });

    return MaterialApp.router(
      title: 'YTech Pro',
      debugShowCheckedModeBanner: false,
      theme: AppThemePremium.lightTheme,
      darkTheme: AppThemePremium.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
