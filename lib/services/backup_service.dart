import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../data/repositories/hive_repository.dart';
import '../core/extensions/date_extensions.dart';
import '../core/constants/app_constants.dart';

class BackupService {
  final HiveRepository _repository;

  BackupService(this._repository);

  Future<String> exportJson() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${AppConstants.backupFileName}');
    final data = await _repository.exportJson();
    await file.writeAsString(data);
    return file.path;
  }

  Future<void> shareBackup() async {
    final path = await exportJson();
    await Share.shareXFiles([XFile(path)], text: 'Sauvegarde YTech Pro');
  }

  Future<void> importJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      await _repository.importJson(data);
    }
  }

  Future<void> importJsonData(String content) async {
    final data = jsonDecode(content) as Map<String, dynamic>;
    await _repository.importJson(data);
  }

  Future<void> exportCsv() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/ytech_pro_export.csv');
    final buffer = StringBuffer();
    buffer.writeln('Export YTech Pro - ${DateTime.now().formatted}');

    buffer.writeln('\n=== CLIENTS ===');
    buffer.writeln('Nom,Email,Téléphone,Adresse,Ville');
    final clients = await _repository.getClients();
    for (final client in clients) {
      buffer.writeln(
          '${client.nom},${client.email ?? ''},${client.telephone},${client.adresse ?? ''},${client.ville ?? ''}');
    }

    buffer.writeln('\n=== DEVIS ===');
    buffer.writeln('Numéro,Client,Total,Statut,Date');
    final devis = await _repository.getDevis();
    for (final d in devis) {
      buffer.writeln(
          '${d.numero},${d.client.nomComplet},${d.netAPayer},${d.statut},${d.date.toIso8601String()}');
    }

    buffer.writeln('\n=== FACTURES ===');
    buffer.writeln('Numéro,Client,Total,Payé,Statut,Échéance');
    final factures = await _repository.getFactures();
    for (final f in factures) {
      buffer.writeln(
          '${f.numero},${f.clientNom},${f.total},${f.montantPaye},${f.statut.name},${f.dateEcheance.toIso8601String()}');
    }

    await file.writeAsString(buffer.toString());
    await Share.shareXFiles([XFile(file.path)], text: 'Export CSV');
  }

  Future<String> exportJsonString() async {
    return await _repository.exportJson();
  }
}
