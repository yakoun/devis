import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/core/extensions/context_extensions.dart';
import 'package:devis/data/models/technicien_info.dart';
import 'package:devis/data/providers/providers.dart';
import 'package:devis/services/auth_service.dart';

class SetupWizardPage extends ConsumerStatefulWidget {
  const SetupWizardPage({super.key});

  @override
  ConsumerState<SetupWizardPage> createState() => _SetupWizardPageState();
}

class _SetupWizardPageState extends ConsumerState<SetupWizardPage>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _notificationsEnabled = true;
  bool _biometricsEnabled = false;

  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _entrepriseCtrl = TextEditingController();
  final _siretCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _codePostalCtrl = TextEditingController();

  final _pinCtrl = TextEditingController();
  final _pinConfirmCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  late AnimationController _animController;

  final _totalSteps = 6;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _entrepriseCtrl.dispose();
    _siretCtrl.dispose();
    _telephoneCtrl.dispose();
    _emailCtrl.dispose();
    _adresseCtrl.dispose();
    _villeCtrl.dispose();
    _codePostalCtrl.dispose();
    _pinCtrl.dispose();
    _pinConfirmCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 3) {
      if (!_formKey.currentState!.validate()) return;
    }
    if (_currentStep == 4) {
      if (_pinCtrl.text.length != 4) {
        context.showSnackBar('Le PIN doit faire 4 chiffres');
        return;
      }
      if (_pinCtrl.text != _pinConfirmCtrl.text) {
        context.showSnackBar('Les PIN ne correspondent pas');
        return;
      }
    }
    setState(() => _currentStep++);
    _animController.reset();
    _animController.forward();
  }

  void _prevStep() {
    setState(() => _currentStep--);
    _animController.reset();
    _animController.forward();
  }

  Future<void> _finishSetup() async {
    try {
      final repo = ref.read(hiveRepositoryProvider);
      final info = TechnicienInfo(
        nom: _nomCtrl.text.trim(),
        prenom: _prenomCtrl.text.trim(),
        entreprise: _entrepriseCtrl.text.trim(),
        siret: _siretCtrl.text.trim(),
        telephone: _telephoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        adresse: _adresseCtrl.text.trim(),
        ville: _villeCtrl.text.trim(),
        codePostal: _codePostalCtrl.text.trim(),
      );
      await repo.saveTechnicienInfo(info);
      if (_pinCtrl.text.isNotEmpty) {
        final auth = ref.read(authServiceProvider);
        await auth.setPin(_pinCtrl.text);
      }
      if (_biometricsEnabled) {
        final auth = ref.read(authServiceProvider);
        await auth.setBiometrics(true);
      }
      ref.invalidate(technicienInfoProvider);
      ref.invalidate(isSetupCompleteProvider);
      if (!mounted) return;
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      context.showSnackBar('Erreur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark ? AppGradients.darkBackground : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFEEF2FF), Color(0xFFFEF9C3)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: StepTransition(
                  step: _currentStep,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.06,
                      vertical: 16,
                    ),
                    child: _buildStepContent(size),
                  ),
                ),
              ),
              _buildBottomNav(size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: AnimatedStepIndicator(
        currentStep: _currentStep,
        totalSteps: _totalSteps,
      ),
    );
  }

  Widget _buildStepContent(Size size) {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep(size);
      case 1:
        return _buildNotificationsStep(size);
      case 2:
        return _buildBiometricsStep(size);
      case 3:
        return _buildInfoStep(size);
      case 4:
        return _buildPinStep(size);
      case 5:
        return _buildCompleteStep(size);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWelcomeStep(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.electricBlue.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.bolt_rounded, size: 64, color: Colors.black),
        ),
        SizedBox(height: size.height * 0.05),
        Text(
          'YTech Pro',
          style: AppTypography.displayLarge.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configuration initiale',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: size.height * 0.03),
        Text(
          'Bienvenue sur YTech Pro, votre ERP\nprofessionnel pour artisans et PME.\n\nConfigurons votre espace de travail\nen quelques étapes.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsStep(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.electricCyan.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.notifications_active_rounded,
              size: 56, color: Colors.black),
        ),
        SizedBox(height: size.height * 0.04),
        Text(
          'Notifications',
          style: AppTypography.headlineLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Text(
          'Restez informé de vos devis, factures\net rappels en temps réel.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: size.height * 0.04),
        ElectricCard(
          isDark: Theme.of(context).brightness == Brightness.dark,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Activer les notifications',
                        style: AppTypography.titleLarge),
                    Text('Devis, factures, rappels',
                        style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
                activeTrackColor: AppColors.electricCyan,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricsStep(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.electricPurple.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.fingerprint_rounded,
              size: 56, color: Colors.black),
        ),
        SizedBox(height: size.height * 0.04),
        Text(
          'Sécurité biométrique',
          style: AppTypography.headlineLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Text(
          'Utilisez votre empreinte digitale pour\ndéverrouiller l\'application rapidement\net en toute sécurité.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: size.height * 0.04),
        ElectricCard(
          isDark: Theme.of(context).brightness == Brightness.dark,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Activer la biométrie',
                        style: AppTypography.titleLarge),
                    Text('Déverrouillage par empreinte',
                        style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _biometricsEnabled,
                onChanged: (v) => setState(() => _biometricsEnabled = v),
                activeTrackColor: AppColors.electricPurple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoStep(Size size) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.02),
            Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppGradients.orange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricOrange.withValues(alpha: 0.3),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.badge_rounded,
                    size: 40, color: Colors.black),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              'Informations professionnelles',
              style: AppTypography.headlineLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ces informations figureront sur vos devis et factures.',
              style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: PremiumTextField(
                    label: 'Nom',
                    controller: _nomCtrl,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Requis' : null,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PremiumTextField(
                    label: 'Prénom',
                    controller: _prenomCtrl,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Requis' : null,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PremiumTextField(
              label: 'Entreprise',
              controller: _entrepriseCtrl,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requis' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            PremiumTextField(
              label: 'SIRET',
              controller: _siretCtrl,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PremiumTextField(
                    label: 'Téléphone',
                    controller: _telephoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PremiumTextField(
                    label: 'Email',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        if (!v.contains('@')) return 'Email invalide';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PremiumTextField(
              label: 'Adresse',
              controller: _adresseCtrl,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PremiumTextField(
                    label: 'Ville',
                    controller: _villeCtrl,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PremiumTextField(
                    label: 'Code Postal',
                    controller: _codePostalCtrl,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinStep(Size size) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: size.height * 0.04),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricBlue.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.lock_rounded, size: 56, color: Colors.black),
          ),
          SizedBox(height: size.height * 0.04),
          Text(
            'Code PIN de sécurité',
            style: AppTypography.headlineLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Protégez l\'accès à votre application\navec un code PIN à 4 chiffres.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: size.height * 0.04),
          PremiumTextField(
            label: 'Code PIN (4 chiffres)',
            controller: _pinCtrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          PremiumTextField(
            label: 'Confirmer le PIN',
            controller: _pinConfirmCtrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            'Vous pourrez modifier ou supprimer\nce code dans les paramètres.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteStep(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            return CustomPaint(
              size: Size(200, 200),
              painter: _ConfettiPainter(
                progress: _animController.value,
                random: Random(42),
              ),
            );
          },
        ),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: AppGradients.green,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.electricGreen.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, size: 64, color: Colors.black),
        ),
        SizedBox(height: size.height * 0.04),
        Text(
          'Configuration terminée !',
          style: AppTypography.displaySmall.copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Votre espace de travail est prêt.\nVous pouvez maintenant commencer\nà gérer vos devis et factures.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(Size size) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0 && _currentStep < _totalSteps - 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: AppColors.electricBlue.withValues(alpha: 0.5)),
                ),
                child: const Text('Retour',
                    style: TextStyle(color: AppColors.electricBlue)),
              ),
            ),
          if (_currentStep > 0 && _currentStep < _totalSteps - 1)
            const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _currentStep == _totalSteps - 1
                ? GlowButton(
                    label: 'Accéder à l\'application',
                    icon: Icons.arrow_forward_rounded,
                    isFullWidth: true,
                    onPressed: _finishSetup,
                  )
                : GlowButton(
                    label: _currentStep == 0 ? 'Commencer' : 'Suivant',
                    icon: Icons.arrow_forward_rounded,
                    isFullWidth: true,
                    onPressed: _nextStep,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final Random random;

  _ConfettiPainter({required this.progress, required this.random});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final colors = [
      AppColors.electricBlue,
      AppColors.electricPurple,
      AppColors.electricGreen,
      AppColors.electricOrange,
      AppColors.electricYellow,
      AppColors.electricRed,
    ];

    for (int i = 0; i < 30; i++) {
      final angle = (i * 137.5) % 360;
      final dist = 40 + (sin(progress * pi * 2 + i) * 0.5 + 0.5) * 60;
      final x = center.dx + cos(angle * pi / 180) * dist * progress;
      final y = center.dy + sin(angle * pi / 180) * dist * progress;
      final size_ = 4 + (random.nextDouble() * 4);
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(
          alpha: (1 - progress * 0.5).clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), size_, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}
