import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:devis/data/providers/providers.dart';
import 'package:devis/design_system/design_system.dart';

class ExportImportDialog extends ConsumerWidget {
  const ExportImportDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ExportImportDialog(),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(hiveRepositoryProvider);
      final json = await repo.exportJson();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/ytechpro_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(json);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Sauvegarde YTech Pro',
      );

      if (context.mounted) {
        AppSnackbar.success(context, 'Export réussi');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.error(context, 'Erreur export: $e');
      }
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.first.path!);
      final json = await file.readAsString();
      final data = jsonDecode(json) as Map<String, dynamic>;

      final repo = ref.read(hiveRepositoryProvider);
      await repo.importJson(data);
      invalidateAllProviders(ref);

      if (context.mounted) {
        AppSnackbar.success(context, 'Import réussi');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.error(context, 'Erreur import: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: const Text('Sauvegarde des données'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElectricCard(
            isDark: isDark,
            onTap: () => _export(context, ref),
            child: const ListTile(
              leading: Icon(Icons.upload_rounded, color: AppColors.electricBlue),
              title: Text('Exporter les données'),
              subtitle: Text('Partager un fichier JSON'),
            ),
          ),
          const SizedBox(height: 12),
          ElectricCard(
            isDark: isDark,
            onTap: () => _import(context, ref),
            child: const ListTile(
              leading:
                  Icon(Icons.download_rounded, color: AppColors.electricGreen),
              title: Text('Importer des données'),
              subtitle: Text('Restaurer depuis un fichier JSON'),
            ),
          ),
          const SizedBox(height: 12),
          ElectricCard(
            isDark: isDark,
            onTap: () async {
              final repo = ref.read(hiveRepositoryProvider);
              await repo.clearAll();
              invalidateAllProviders(ref);
              if (context.mounted) {
                AppSnackbar.success(context, 'Données effacées');
                Navigator.pop(context);
              }
            },
            child: const ListTile(
              leading: Icon(Icons.delete_forever_rounded, color: AppColors.electricRed),
              title: Text('Tout effacer'),
              subtitle: Text('Supprimer toutes les données'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
