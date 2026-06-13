import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:devis/data/repositories/hive_repository.dart';
import 'package:devis/core/utils/enums.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: onNotificationTap,
  );
}

void onNotificationTap(NotificationResponse response) {
  // Handle notification tap - navigate to relevant page
}

Future<void> showNotification({
  required int id,
  required String title,
  required String body,
  String? payload,
}) async {
  final androidDetails = AndroidNotificationDetails(
    'ytech_pro_channel',
    'YTech Pro',
    channelDescription: 'Notifications YTech Pro',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
    enableVibration: true,
    playSound: true,
  );
  const iosDetails = DarwinNotificationDetails();
  final details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );
  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    details,
    payload: payload,
  );
}

Future<void> checkAndNotify() async {
  final repo = HiveRepository.instance;
  final now = DateTime.now();

  final devis = await repo.getDevis();
  for (final d in devis) {
    if (d.statut == 'envoyé' &&
        now.difference(d.date).inDays >= 7) {
      await showNotification(
        id: 100 + devis.indexOf(d),
        title: 'Devis en attente',
        body: 'Le devis ${d.numero} est en attente depuis plus de 7 jours.',
        payload: 'devis_${d.id}',
      );
    }
    if (d.statut == 'brouillon') {
      await showNotification(
        id: 200 + devis.indexOf(d),
        title: 'Devis expiré',
        body: 'Le devis ${d.numero} a expiré.',
        payload: 'devis_${d.id}',
      );
    }
  }

  final factures = await repo.getFactures();
  for (final f in factures) {
    if ((f.statut == FactureStatus.impayee ||
            f.statut == FactureStatus.partielle) &&
        now.isAfter(f.dateEcheance)) {
      final daysLate = now.difference(f.dateEcheance).inDays;
      await showNotification(
        id: 300 + factures.indexOf(f),
        title: 'Facture impayée',
        body: 'La facture ${f.numero} est en retard de $daysLate jours.',
        payload: 'facture_${f.id}',
      );
    }
  }

  final chantiers = await repo.getChantiers();
  for (final c in chantiers) {
    if (c.statut == ChantierStatus.enCours &&
        now.difference(c.updatedAt).inDays >= 3) {
      await showNotification(
        id: 400 + chantiers.indexOf(c),
        title: 'Chantier sans activité',
        body: 'Le chantier ${c.nom} est sans activité depuis 3 jours.',
        payload: 'chantier_${c.id}',
      );
    }
  }
}
