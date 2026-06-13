import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devis/core/extensions/context_extensions.dart';

import 'package:devis/design_system/design_system.dart';
import 'package:devis/data/models/technicien_info.dart';
import 'package:devis/data/providers/providers.dart';

class TechnicienEditPage extends ConsumerStatefulWidget {
  const TechnicienEditPage({super.key});

  @override
  ConsumerState<TechnicienEditPage> createState() => _TechnicienEditPageState();
}

class _TechnicienEditPageState extends ConsumerState<TechnicienEditPage> {
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _entrepriseCtrl = TextEditingController();
  final _siretCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _codePostalCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    try {
      final info = await ref.read(technicienInfoProvider.future);
      if (!mounted) return;
      _nomCtrl.text = info.nom;
      _prenomCtrl.text = info.prenom;
      _entrepriseCtrl.text = info.entreprise;
      _siretCtrl.text = info.siret;
      _telephoneCtrl.text = info.telephone;
      _emailCtrl.text = info.email;
      _adresseCtrl.text = info.adresse;
      _villeCtrl.text = info.ville;
      _codePostalCtrl.text = info.codePostal;
    } catch (_) {}
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
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
      ref.invalidate(technicienInfoProvider);
      if (!mounted) return;
      context.showSnackBar('Informations enregistrées');
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      context.showSnackBar('Erreur: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _entrepriseCtrl.dispose();
    _siretCtrl.dispose();
    _telephoneCtrl.dispose();
    _emailCtrl.dispose();
    _adresseCtrl.dispose();
    _villeCtrl.dispose();
    _codePostalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PremiumAppBar(title: 'Compte professionnel', isDark: isDark),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.electricBlue.withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_rounded,
                            size: 40, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Informations professionnelles',
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.w700,
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
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requis'
                                : null,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PremiumTextField(
                            label: 'Prénom',
                            controller: _prenomCtrl,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requis'
                                : null,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PremiumTextField(
                      label: 'Entreprise',
                      controller: _entrepriseCtrl,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Requis'
                          : null,
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
                    const SizedBox(height: 32),
                    GlowButton(
                      label: 'Enregistrer',
                      icon: Icons.save_rounded,
                      isFullWidth: true,
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
