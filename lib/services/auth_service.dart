import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/hive_repository.dart';
import '../data/providers/providers.dart';

class AuthService {
  final HiveRepository _repository;

  AuthService(this._repository);

  Future<bool> hasPin() async {
    final pin = await _repository.getSetting('pin_hash');
    return pin != null && pin.isNotEmpty;
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = await _repository.getSetting('pin_hash');
    if (storedHash == null) return false;
    final hash = _hashPin(pin);
    return hash == storedHash;
  }

  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    await _repository.setSetting('pin_hash', hash);
  }

  Future<void> removePin() async {
    await _repository.setSetting('pin_hash', '');
  }

  Future<bool> hasBiometrics() async {
    return await _repository.getSetting('biometrics') == 'true';
  }

  Future<void> setBiometrics(bool enabled) async {
    await _repository.setSetting('biometrics', enabled.toString());
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode('YTechPro_$pin');
    return sha256.convert(bytes).toString();
  }

  // Generate a random secure string for backup
  String generateRecoveryCode() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final repo = ref.read(hiveRepositoryProvider);
  return AuthService(repo);
});

final hasPinProvider = FutureProvider<bool>((ref) async {
  final auth = ref.read(authServiceProvider);
  return auth.hasPin();
});

final isUnlockedProvider = StateProvider<bool>((ref) => true);
