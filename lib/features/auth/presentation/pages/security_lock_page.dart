import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/services/auth_service.dart';

class SecurityLockPage extends ConsumerStatefulWidget {
  const SecurityLockPage({super.key});

  @override
  ConsumerState<SecurityLockPage> createState() => _SecurityLockPageState();
}

class _SecurityLockPageState extends ConsumerState<SecurityLockPage> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  final _localAuth = LocalAuthentication();
  String? _error;
  bool _isLoading = false;
  bool _isBiometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final available = await _localAuth.canCheckBiometrics;
      final enrolled = await _localAuth.isDeviceSupported();
      if (mounted) {
        setState(() => _isBiometricsAvailable = available && enrolled);
      }
    } catch (_) {}
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Déverrouiller YTech Pro',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated && mounted) {
        ref.read(isUnlockedProvider.notifier).state = true;
        context.go('/dashboard');
      } else if (mounted) {
        setState(() {
          _isLoading = false;
          _focusNode.requestFocus();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Authentification biométrique indisponible';
          _isLoading = false;
        });
        _focusNode.requestFocus();
      }
    }
  }

  Future<void> _verify() async {
    final pin = _pinController.text;
    if (pin.length < 4) {
      setState(() => _error = 'Code PIN à 4 chiffres requis');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final auth = ref.read(authServiceProvider);
    final valid = await auth.verifyPin(pin);
    if (!mounted) return;
    if (valid) {
      ref.read(isUnlockedProvider.notifier).state = true;
      context.go('/dashboard');
    } else {
      setState(() {
        _error = 'Code PIN incorrect';
        _isLoading = false;
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkBackground),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 48,
                    color: AppColors.electricBlue,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'YTech Pro',
                  style: AppTypography.headlineMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Entrez votre code PIN',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textOnDarkSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _pinController,
                    focusNode: _focusNode,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(4),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      letterSpacing: 16,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.glassWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      hintText: '••••',
                      hintStyle: TextStyle(
                        fontSize: 32,
                        letterSpacing: 16,
                        color: AppColors.textOnDarkSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                    onSubmitted: (_) => _verify(),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.electricRed),
                  ),
                ],
                if (_isBiometricsAvailable) ...[
                  IconButton(
                    onPressed: _isLoading ? null : _authenticateWithBiometrics,
                    iconSize: 48,
                    icon: Icon(
                      Icons.fingerprint_rounded,
                      color: _isLoading
                          ? AppColors.textOnDarkSecondary
                          : AppColors.electricBlue,
                    ),
                    tooltip: 'Authentification biométrique',
                  ),
                  const SizedBox(height: 16),
                ],
                if (_isLoading)
                  const CircularProgressIndicator(color: AppColors.electricBlue)
                else
                  GlowButton(
                    label: 'DÉVERROUILLER',
                    isFullWidth: true,
                    onPressed: _verify,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
