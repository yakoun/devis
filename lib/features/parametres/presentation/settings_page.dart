import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/core/constants/app_constants.dart';
import 'package:devis/data/models/app_settings.dart';
import 'package:devis/data/providers/settings_provider.dart';
import 'package:devis/data/providers/providers.dart';
import 'package:devis/services/backup_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late TextEditingController _techNomCtrl;
  late TextEditingController _techPrenomCtrl;
  late TextEditingController _companyCtrl;
  late TextEditingController _sloganCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _phone2Ctrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _taxIdCtrl;
  late TextEditingController _tvaRateCtrl;
  late TextEditingController _expensesCtrl;
  late TextEditingController _marginCtrl;

  String _currency = 'XOF';
  bool _tvaEnabled = false;
  bool _pdfShowLogo = true;
  bool _pdfShowSignature = false;
  String? _logoPath;
  String _themeMode = 'dark';
  bool _securityEnabled = false;
  String _pinCode = '';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(appSettingsProvider);
    _initFromSettings(settings);
  }

  void _initFromSettings(AppSettings s) {
    _techNomCtrl = TextEditingController(text: s.technicianNom);
    _techPrenomCtrl = TextEditingController(text: s.technicianPrenom);
    _companyCtrl = TextEditingController(text: s.companyName);
    _sloganCtrl = TextEditingController(text: s.companySlogan);
    _phoneCtrl = TextEditingController(text: s.phone);
    _phone2Ctrl = TextEditingController(text: s.phoneSecondary);
    _emailCtrl = TextEditingController(text: s.email);
    _addressCtrl = TextEditingController(text: s.address);
    _taxIdCtrl = TextEditingController(text: s.taxId);
    _tvaRateCtrl = TextEditingController(text: s.tvaRate.toString());
    _expensesCtrl = TextEditingController(text: s.defaultExpenses.toString());
    _marginCtrl = TextEditingController(text: s.pdfMarginCm.toString());
    _currency = s.currency;
    _tvaEnabled = s.tvaEnabled;
    _pdfShowLogo = s.pdfShowLogo;
    _pdfShowSignature = s.pdfShowSignature;
    _logoPath = s.logoPath.isEmpty ? null : s.logoPath;
    _themeMode = s.themeMode;
    _securityEnabled = s.securityEnabled;
    _pinCode = s.pinCode;
    _notificationsEnabled = s.notificationsEnabled;
  }

  @override
  void dispose() {
    _techNomCtrl.dispose();
    _techPrenomCtrl.dispose();
    _companyCtrl.dispose();
    _sloganCtrl.dispose();
    _phoneCtrl.dispose();
    _phone2Ctrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _taxIdCtrl.dispose();
    _tvaRateCtrl.dispose();
    _expensesCtrl.dispose();
    _marginCtrl.dispose();
    super.dispose();
  }

  Future<void> _showPinSetupDialog() async {
    final pinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Code PIN'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: pinCtrl,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nouveau code PIN (4 chiffres)',
                ),
                validator: (v) =>
                    v == null || v.length != 4 ? '4 chiffres requis' : null,
              ),
              TextFormField(
                controller: confirmCtrl,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le code PIN',
                ),
                validator: (v) =>
                    v != pinCtrl.text ? 'Les codes ne correspondent pas' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, pinCtrl.text);
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (result != null && result.length == 4) {
      setState(() {
        _securityEnabled = true;
        _pinCode = _hashPin(result);
      });
    }
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
    );
    if (image != null) {
      setState(() => _logoPath = image.path);
    }
  }

  Future<void> _save() async {
    final settings = AppSettings(
      technicianNom: _techNomCtrl.text,
      technicianPrenom: _techPrenomCtrl.text,
      companyName: _companyCtrl.text,
      companySlogan: _sloganCtrl.text,
      phone: _phoneCtrl.text,
      phoneSecondary: _phone2Ctrl.text,
      email: _emailCtrl.text,
      address: _addressCtrl.text,
      taxId: _taxIdCtrl.text,
      logoPath: _logoPath ?? '',
      currency: _currency,
      tvaEnabled: _tvaEnabled,
      tvaRate: double.tryParse(_tvaRateCtrl.text) ?? 18,
      defaultExpenses: double.tryParse(_expensesCtrl.text) ?? 0,
      pdfShowLogo: _pdfShowLogo,
      pdfShowSignature: _pdfShowSignature,
      pdfMarginCm: double.tryParse(_marginCtrl.text.replaceAll(',', '.')) ?? 0.5,
      themeMode: _themeMode,
      securityEnabled: _securityEnabled,
      pinCode: _pinCode,
      notificationsEnabled: _notificationsEnabled,
    );

    await ref.read(appSettingsProvider.notifier).update(settings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paramètres enregistrés')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PremiumAppBar(title: 'Paramètres', isDark: isDark),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            title: 'ENTREPRISE',
            icon: Icons.business_rounded,
            children: [
              GestureDetector(
                onTap: _pickLogo,
                child: Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.electricBlue.withValues(alpha: 0.1),
                    backgroundImage:
                        _logoPath != null ? FileImage(File(_logoPath!)) : null,
                    child: _logoPath == null
                        ? const Icon(Icons.add_a_photo, color: AppColors.electricBlue)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Logo (taper pour upload)',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _companyCtrl,
                  decoration: const InputDecoration(labelText: 'Nom entreprise'),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _sloganCtrl,
                  decoration: const InputDecoration(labelText: 'Slogan'),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _techNomCtrl,
                  decoration: const InputDecoration(labelText: 'Nom technicien'),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _techPrenomCtrl,
                  decoration: const InputDecoration(labelText: 'Prénom technicien'),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Téléphone 1'),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _phone2Ctrl,
                  decoration: const InputDecoration(labelText: 'Téléphone 2'),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(labelText: 'Adresse'),
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _taxIdCtrl,
                  decoration: const InputDecoration(labelText: 'N° ID fiscal'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'APPLICATION',
            icon: Icons.touch_app_rounded,
            children: [
              _SettingsTile(
                icon: Icons.inventory_2_outlined,
                title: 'Catalogue',
                subtitle: 'Gérer le catalogue',
                onTap: () => GoRouter.of(context).push('/settings/materials'),
              ),
              _SettingsTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Finance — Dépenses',
                subtitle: 'Dépenses récurrentes',
                onTap: () => GoRouter.of(context).push('/settings/finance'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.security_rounded,
                        size: 18, color: AppColors.electricBlue),
                    const SizedBox(width: 8),
                    Text('Sécurité',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SwitchListTile(
                  title: const Text('Code PIN'),
                  subtitle: const Text("Protéger l'accès à l'application"),
                  value: _securityEnabled,
                  activeColor: AppColors.electricBlue,
                  contentPadding: const EdgeInsets.only(left: 12),
                  onChanged: (v) {
                    if (v) {
                      _showPinSetupDialog();
                    } else {
                      setState(() {
                        _securityEnabled = false;
                        _pinCode = '';
                      });
                    }
                  },
                ),
              ),
              if (_securityEnabled)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: TextButton.icon(
                    onPressed: _showPinSetupDialog,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label:
                        const Text('Modifier le code PIN', style: TextStyle(fontSize: 13)),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SwitchListTile(
                  title: const Text('Thème sombre'),
                  subtitle: const Text('Basculer entre sombre et clair'),
                  value: _themeMode == 'dark',
                  activeColor: AppColors.electricBlue,
                  secondary: Icon(
                    _themeMode == 'dark' ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppColors.electricBlue,
                  ),
                  contentPadding: const EdgeInsets.only(left: 12),
                  onChanged: (v) {
                    setState(() => _themeMode = v ? 'dark' : 'light');
                    ref.read(themeModeProvider.notifier).state = v;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Rappels devis et factures'),
                  value: _notificationsEnabled,
                  activeColor: AppColors.electricBlue,
                  contentPadding: const EdgeInsets.only(left: 12),
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'DEVIS & PDF',
            icon: Icons.picture_as_pdf_rounded,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  value: _currency,
                  decoration: const InputDecoration(labelText: 'Devise'),
                  items: const [
                    DropdownMenuItem(value: 'XOF', child: Text('XOF (FCFA)')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                    DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                  ],
                  onChanged: (v) => setState(() => _currency = v ?? 'XOF'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SwitchListTile(
                  title: const Text('TVA'),
                  value: _tvaEnabled,
                  activeColor: AppColors.electricBlue,
                  contentPadding: const EdgeInsets.only(left: 12),
                  onChanged: (v) => setState(() => _tvaEnabled = v),
                ),
              ),
              if (_tvaEnabled)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _tvaRateCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'TVA (%)'),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _expensesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Dépenses par défaut (dashboard)',
                  ),
                ),
              ),
              const Divider(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: AppColors.electricBlue),
                  title: Text('Format A4'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SwitchListTile(
                  title: const Text('Logo dans le PDF'),
                  value: _pdfShowLogo,
                  activeColor: AppColors.electricBlue,
                  contentPadding: const EdgeInsets.only(left: 12),
                  onChanged: (v) => setState(() => _pdfShowLogo = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SwitchListTile(
                  title: const Text('Signature dans le PDF'),
                  value: _pdfShowSignature,
                  activeColor: AppColors.electricBlue,
                  contentPadding: const EdgeInsets.only(left: 12),
                  onChanged: (v) => setState(() => _pdfShowSignature = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _marginCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Marges PDF (cm)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'DONNÉES',
            icon: Icons.cloud_sync_rounded,
            children: [
              _SettingsTile(
                icon: Icons.file_download_outlined,
                title: 'Exporter',
                subtitle: 'Devis, clients, dépenses',
                onTap: () => GoRouter.of(context).push('/settings/export'),
              ),
              _SettingsTile(
                icon: Icons.cloud_outlined,
                title: 'Sauvegarde',
                subtitle: 'Google Drive',
                onTap: () => GoRouter.of(context).push('/settings/drive'),
              ),
              _SettingsTile(
                icon: Icons.upload_file,
                title: 'Exporter complète',
                subtitle: 'Sauvegarde complète locale',
                onTap: _exportBackup,
              ),
              _SettingsTile(
                icon: Icons.download,
                title: 'Importer',
                subtitle: 'Restaurer les données locales',
                onTap: _importBackup,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'À PROPOS',
            icon: Icons.info_outline_rounded,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.bolt_rounded,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.appName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Version ${AppConstants.appVersion}',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _aboutRow(
                      Icons.person_outline,
                      'Développeur',
                      'YAKOUN Ouniboryabi',
                    ),
                    const SizedBox(height: 8),
                    _aboutRow(
                      Icons.email_outlined,
                      'Email',
                      'yakounouniboryabi@gmail.com',
                    ),
                    const SizedBox(height: 8),
                    _aboutRow(
                      Icons.phone_outlined,
                      'Téléphone',
                      '+228 97 53 33 07',
                    ),
                    const SizedBox(height: 8),
                    _aboutRow(
                      Icons.location_on_outlined,
                      'Adresse',
                      'Lomé, Togo',
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Text(
                      'Application de gestion de devis, factures, interventions et catalogue matériel.\n'
                      'Électricité, Informatique, Réseaux & Solaire.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.electricBlue.withValues(alpha: 0.1),
                  AppColors.electricPurple.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.electricBlue.withValues(alpha: 0.2),
              ),
            ),
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.electricBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Enregistrer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _aboutRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.electricBlue),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }

  Future<void> _exportBackup() async {
    final repo = ref.read(hiveRepositoryProvider);
    final backup = BackupService(repo);
    final json = await backup.exportJsonString();
    await Share.share(json, subject: 'YTech Pro — Sauvegarde');
  }

  Future<void> _importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'txt'],
    );
    if (result == null || result.files.single.path == null) return;

    try {
      final content = await File(result.files.single.path!).readAsString();
      final repo = ref.read(hiveRepositoryProvider);
      final backup = BackupService(repo);
      await backup.importJsonData(content);

      ref.invalidate(clientsProvider);
      ref.invalidate(devisProvider);
      ref.invalidate(facturesProvider);
      ref.invalidate(chantiersProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(catalogueItemsProvider);
      ref.read(appSettingsProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import réussi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur import: $e')),
        );
      }
    }
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.electricBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.electricBlue,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkCard
                : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
            ),
            boxShadow: AppShadows.md,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.electricBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppColors.electricBlue),
      ),
      title: Text(title, style: TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(subtitle,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      trailing: Icon(Icons.chevron_right,
          color: AppColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }
}
