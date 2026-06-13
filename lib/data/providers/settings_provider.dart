import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import 'providers.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _load();
    return const AppSettings();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(hiveRepositoryProvider);
      final json = await repo.getSetting('app_settings');
      if (json != null && json.isNotEmpty) {
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        state = AppSettings.fromJson(decoded);
      }
    } catch (_) {}
  }

  Future<void> update(AppSettings settings) async {
    state = settings;
    try {
      final repo = ref.read(hiveRepositoryProvider);
      await repo.setSetting('app_settings', jsonEncode(settings.toJson()));
    } catch (_) {}
  }

  Future<void> refresh() async {
    await _load();
  }
}

final appSettingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
