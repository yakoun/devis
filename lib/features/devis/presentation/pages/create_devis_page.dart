import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/core/extensions/num_extensions.dart';
import 'package:devis/core/extensions/date_extensions.dart';
import 'package:devis/core/extensions/context_extensions.dart';
import 'package:devis/data/models/devis.dart';
import 'package:devis/data/models/client.dart';
import 'package:devis/data/models/catalogue_item.dart';
import 'package:devis/data/providers/providers.dart';

class CreateDevisPage extends ConsumerStatefulWidget {
  final CatalogueItem? initialItem;
  final Devis? editDevis;
  const CreateDevisPage({super.key, this.initialItem, this.editDevis});

  @override
  ConsumerState<CreateDevisPage> createState() => _CreateDevisPageState();
}

class _CreateDevisPageState extends ConsumerState<CreateDevisPage> {
  final _formKey = GlobalKey<FormState>();
  AppClient? _selectedClient;
  final _lignes = <LigneDevis>[];
  final _notesController = TextEditingController();
  final _mainOeuvreController = TextEditingController(text: '0');
  double _remise = 0;
  double _tva = 20;
  bool _isSaving = false;
  Devis? _editingDevis;

  @override
  void initState() {
    super.initState();
    final editDevis = widget.editDevis;
    if (editDevis != null) {
      _editingDevis = editDevis;
      _selectedClient = AppClient.create(
        nom: editDevis.client.nomComplet,
        telephone: editDevis.client.contact,
      );
      _lignes.addAll(editDevis.lignes);
      _notesController.text = editDevis.description;
      _mainOeuvreController.text = editDevis.mainOeuvre.toString();
    }
    final initialItem = widget.initialItem;
    if (initialItem != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showItemConfigDialog(initialItem);
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int get _mainOeuvre =>
      int.tryParse(_mainOeuvreController.text.replaceAll(' ', '')) ?? 0;
  int get _sousTotal =>
      _lignes.fold<int>(0, (sum, ligne) => sum + ligne.prixTotal);
  int get _baseHT => _sousTotal + _mainOeuvre;
  double get _montantTva => _baseHT * (_tva / 100);
  double get _total => _baseHT - _remise + _montantTva;

  void _showItemConfigDialog(CatalogueItem item) {
    final qteController = TextEditingController(text: '1');
    final puController =
        TextEditingController(text: item.prixUnitaire.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) {
        double qte = 1;
        double pu = item.prixUnitaire;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final total = qte * pu;

            return AlertDialog(
              title: Text(item.nom),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PremiumTextField(
                      label: 'Quantité',
                      hint: '1',
                      keyboardType: TextInputType.number,
                      controller: qteController,
                      onChanged: (v) {
                        setDialogState(() {
                          qte = double.tryParse(v) ?? 1;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    PremiumTextField(
                      label: 'Prix unitaire',
                      hint: item.prixUnitaire.toString(),
                      keyboardType: TextInputType.number,
                      controller: puController,
                      onChanged: (v) {
                        setDialogState(() {
                          pu = double.tryParse(v) ?? item.prixUnitaire;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total ligne',
                              style: AppTypography.titleMedium),
                          Text(total.formattedCurrency,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.electricBlue,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler'),
                ),
                GlowButton(
                  label: 'AJOUTER',
                  onPressed: () {
                    setState(() {
                      _lignes.add(LigneDevis(
                        designation: item.nom,
                        quantite: qte.toInt(),
                        prixUnitaire: pu.toInt(),
                      ));
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _save() async {
    if (_selectedClient == null) {
      context.showSnackBar('Veuillez sélectionner un client');
      return;
    }
    if (_lignes.isEmpty) {
      context.showSnackBar('Ajoutez au moins un article');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final existing = _editingDevis;
      final devis = Devis(
        id: existing?.id ?? const Uuid().v4(),
        numero: existing?.numero ?? 'DEV-${DateTime.now().millisecondsSinceEpoch}',
        date: existing?.date ?? DateTime.now(),
        client: Client(
          nom: _selectedClient!.nom,
          prenom: null,
          contact: _selectedClient!.telephone,
        ),
        technicien: existing?.technicien ?? Technicien(nom: 'À définir', prenom: ''),
        description: _notesController.text,
        lignes: _lignes,
        mainOeuvre: _mainOeuvre,
        statut: existing?.statut ?? 'brouillon',
      );

      final repo = ref.read(hiveRepositoryProvider);
      await repo.saveDevis(devis);
      ref.invalidate(devisProvider);
      if (!mounted) return;
      context.pop();
      if (existing == null) _showPostSaveOptions(devis);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      context.showSnackBar('Erreur: $e');
    }
  }

  void _showPostSaveOptions(Devis devis) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Devis créé avec succès'),
        content: const Text('Que souhaitez-vous faire ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text('Partager sur WhatsApp'),
            onPressed: () {
              Navigator.pop(ctx);
              _shareOnWhatsApp(devis);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _shareOnWhatsApp(Devis devis) async {
    try {
      final text = 'Devis ${devis.numero}\n'
          'Client: ${devis.client.nomComplet}\n'
          'Total: ${devis.netAPayer.formattedCurrency}\n'
          'Créé le: ${devis.date.formatted}\n'
          'Merci pour votre confiance !';
      final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        context.showSnackBar('WhatsApp n\'est pas installé');
      }
    } catch (e) {
      if (!mounted) return;
      context.showSnackBar('Erreur: $e');
    }
  }

  void _showPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _DevisPreviewSheet(
        client: _selectedClient,
        items: _lignes,
        sousTotal: _sousTotal.toDouble(),
        mainOeuvre: _mainOeuvre.toDouble(),
        baseHT: _baseHT.toDouble(),
        remise: _remise,
        tva: _tva,
        montantTva: _montantTva,
        total: _total,
        notes: _notesController.text,
      ),
    );
  }

  void _showCatalogueSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _CatalogueSelectorSheet(
        onItemSelected: (item) {
          Navigator.pop(ctx);
          _showItemConfigDialog(item);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Nouveau devis',
        isDark: isDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_rounded),
            tooltip: 'Aperçu',
            onPressed: _lignes.isNotEmpty ? _showPreview : null,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'Client'),
              clientsAsync.when(
                data: (clients) => ElectricCard(
                  isDark: isDark,
                  onTap: _showClientPicker,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: AppColors.electricBlue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedClient?.nom ??
                                  'Sélectionner un client',
                              style: AppTypography.titleMedium,
                            ),
                            if (_selectedClient != null) ...[
                              const SizedBox(height: 2),
                              Text(_selectedClient!.telephone,
                                  style: AppTypography.caption),
                              if (_selectedClient!.email != null)
                                Text(_selectedClient!.email!,
                                    style: AppTypography.caption),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
                loading: () => const Center(
                    child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )),
                error: (e, _) => Text('Erreur: $e'),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Articles',
                actionLabel: 'Ajouter',
                onAction: _showCatalogueSelector,
              ),
              if (_lignes.isEmpty)
                ElectricCard(
                  isDark: isDark,
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.add_shopping_cart_outlined,
                            size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        Text('Aucun article',
                            style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _showCatalogueSelector,
                          child: const Text('Ajouter un article'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._lignes.map((ligne) => ElectricCard(
                      isDark: isDark,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ligne.designation,
                                    style: AppTypography.titleMedium),
                                Text(
                                  '${ligne.quantite} x ${ligne.prixUnitaire.formattedCurrency}',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(ligne.prixTotal.formattedCurrency,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  )),
                              Text('/ligne',
                                  style: AppTypography.caption),
                            ],
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _lignes.remove(ligne)),
                            child: const Icon(Icons.close_rounded,
                                color: AppColors.electricRed, size: 20),
                          ),
                        ],
                      ),
                    )),
              const SizedBox(height: 24),
              SectionHeader(title: 'Paramètres'),
              ElectricCard(
                isDark: isDark,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Remise'),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _remise,
                      min: 0,
                      max: _sousTotal > 0 ? _sousTotal.toDouble() : 1,
                      divisions: 100,
                      activeColor: AppColors.electricBlue,
                      label: _remise.formattedCurrency,
                      onChanged: (v) => setState(() => _remise = v),
                    ),
                    Text(_remise.formattedCurrency,
                        style: AppTypography.labelLarge),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<double>(
                      initialValue: _tva,
                      decoration: const InputDecoration(
                        labelText: 'TVA (%)',
                        filled: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 0.0, child: Text('0%')),
                        DropdownMenuItem(value: 5.5, child: Text('5.5%')),
                        DropdownMenuItem(value: 10.0, child: Text('10%')),
                        DropdownMenuItem(value: 20.0, child: Text('20%')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _tva = v);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PremiumTextField(
                label: 'Description du devis',
                hint: 'Ajouter une description...',
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElectricCard(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4A261).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.handyman_rounded, color: Color(0xFFF4A261), size: 16),
                        ),
                        const SizedBox(width: 10),
                        Text('Main-d\'œuvre', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textOnDark : AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PremiumTextField(
                      label: 'Montant main-d\'œuvre (€)',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      controller: _mainOeuvreController,
                      onChanged: (_) => setState(() {}),
                    ),
                    if (_mainOeuvre > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${_mainOeuvre.formattedCurrency} ajouté au sous-total',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.textOnDarkTertiary : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElectricCard(
                isDark: isDark,
                child: Column(
                  children: [
                    _TotalRow('Matériel', _sousTotal.formattedCurrency),
                    if (_mainOeuvre > 0)
                      _TotalRow('Main-d\'œuvre', _mainOeuvre.formattedCurrency),
                    _TotalRow('Sous-total HT', _baseHT.formattedCurrency),
                    if (_remise > 0)
                      _TotalRow('Remise', '-${_remise.formattedCurrency}'),
                    _TotalRow('TVA (${_tva.toStringAsFixed(1)}%)',
                        _montantTva.formattedCurrency),
                    const Divider(),
                    _TotalRow('Total TTC', _total.formattedCurrency, isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GlowButton(
            label: _isSaving ? 'CRÉATION...' : 'CRÉER LE DEVIS',
            isFullWidth: true,
            icon: _isSaving ? Icons.hourglass_empty_rounded : Icons.check_rounded,
            onPressed: _isSaving ? null : _save,
            isLoading: _isSaving,
          ),
        ),
      ),
    );
  }

  void _showClientPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _ClientPickerSheet(
        onClientSelected: (client) {
          setState(() => _selectedClient = client);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _TotalRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              )),
          Text(value,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
                color: isBold ? AppColors.electricBlue : null,
              )),
        ],
      ),
    );
  }
}

class _DevisPreviewSheet extends StatelessWidget {
  final AppClient? client;
  final List<LigneDevis> items;
  final double sousTotal;
  final double mainOeuvre;
  final double baseHT;
  final double remise;
  final double tva;
  final double montantTva;
  final double total;
  final String notes;

  const _DevisPreviewSheet({
    required this.client,
    required this.items,
    required this.sousTotal,
    required this.mainOeuvre,
    required this.baseHT,
    required this.remise,
    required this.tva,
    required this.montantTva,
    required this.total,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Aperçu du devis', style: AppTypography.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElectricCard(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Client',
                                style: AppTypography.caption),
                            StatusBadge(
                              label: 'BROUILLON',
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(client?.nom ?? 'Non sélectionné',
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                        if (client?.telephone != null) ...[
                          const SizedBox(height: 4),
                          Text(client!.telephone,
                              style: AppTypography.bodySmall),
                        ],
                        if (client?.email != null)
                          Text(client!.email!,
                              style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Articles (${items.length})',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 8),
                  ...items.map((ligne) => ElectricCard(
                        isDark: isDark,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ligne.designation,
                                      style: AppTypography.titleMedium),
                                  Text('Qté: ${ligne.quantite} x ${ligne.prixUnitaire.formattedCurrency}',
                                      style: AppTypography.bodySmall),
                                ],
                              ),
                            ),
                            Text(ligne.prixTotal.formattedCurrency,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                  ElectricCard(
                    isDark: isDark,
                    child: Column(
                      children: [
                        _TotalRow('Matériel', sousTotal.formattedCurrency),
                        if (mainOeuvre > 0)
                          _TotalRow('Main-d\'œuvre', mainOeuvre.formattedCurrency),
                        _TotalRow('Sous-total HT', baseHT.formattedCurrency),
                        if (remise > 0)
                          _TotalRow('Remise', '-${remise.formattedCurrency}'),
                        _TotalRow('TVA (${tva.toStringAsFixed(1)}%)',
                            montantTva.formattedCurrency),
                        const Divider(),
                        _TotalRow('Total TTC', total.formattedCurrency,
                            isBold: true),
                      ],
                    ),
                  ),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ElectricCard(
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notes', style: AppTypography.caption),
                          const SizedBox(height: 4),
                          Text(notes, style: AppTypography.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientPickerSheet extends StatefulWidget {
  final void Function(AppClient) onClientSelected;
  const _ClientPickerSheet({required this.onClientSelected});

  @override
  State<_ClientPickerSheet> createState() => _ClientPickerSheetState();
}

class _ClientPickerSheetState extends State<_ClientPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sélectionner un client',
                    style: AppTypography.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PremiumTextField(
              hint: 'Rechercher un client...',
              prefixIcon: Icons.search_rounded,
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              suffixIcon:
                  _searchQuery.isNotEmpty ? Icons.clear_rounded : null,
              onSuffixTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final clientsAsync = ref.watch(clientsProvider);
                return clientsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Erreur: $e')),
                  data: (clients) {
                    var filtered = clients;
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      filtered = clients
                          .where((c) =>
                              c.nom.toLowerCase().contains(q) ||
                              c.telephone.toLowerCase().contains(q) ||
                              (c.email?.toLowerCase().contains(q) ?? false) ||
                              (c.siret?.toLowerCase().contains(q) ?? false))
                          .toList();
                    }
                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text('Aucun client trouvé'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final client = filtered[index];
                        return ElectricCard(
                          isDark: isDark,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () =>
                                widget.onClientSelected(client),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.electricBlue
                                      .withValues(alpha: 0.15),
                                  child: Text(
                                    client.nom.isNotEmpty
                                        ? client.nom[0].toUpperCase()
                                        : '?',
                                    style: AppTypography.titleLarge.copyWith(
                                      color: AppColors.electricBlue,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(client.nom,
                                          style: AppTypography.titleMedium
                                              .copyWith(
                                            fontWeight: FontWeight.w600,
                                          )),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone_rounded,
                                              size: 12,
                                              color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(client.telephone,
                                              style: AppTypography.bodySmall),
                                        ],
                                      ),
                                      if (client.email != null) ...[
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.email_rounded,
                                                size: 12,
                                                color: AppColors.textSecondary),
                                            const SizedBox(width: 4),
                                            Text(client.email!,
                                                style: AppTypography.bodySmall),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogueSelectorSheet extends StatefulWidget {
  final void Function(CatalogueItem) onItemSelected;
  const _CatalogueSelectorSheet({required this.onItemSelected});

  @override
  State<_CatalogueSelectorSheet> createState() =>
      _CatalogueSelectorSheetState();
}

class _CatalogueSelectorSheetState extends State<_CatalogueSelectorSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Électricité':
        return Icons.bolt_rounded;
      case 'Luminaire':
        return Icons.light_rounded;
      case 'Industriel':
        return Icons.factory_rounded;
      case 'Informatique':
        return Icons.computer_rounded;
      case 'Télécom':
        return Icons.phone_rounded;
      case 'WiFi':
        return Icons.wifi_rounded;
      case 'Routeurs':
        return Icons.router_rounded;
      case 'Fibre optique':
        return Icons.cable_rounded;
      case 'Réseau':
        return Icons.lan_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ajouter un article',
                    style: AppTypography.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PremiumTextField(
              hint: 'Rechercher un article...',
              prefixIcon: Icons.search_rounded,
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              suffixIcon:
                  _searchQuery.isNotEmpty ? Icons.clear_rounded : null,
              onSuffixTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final itemsAsync = ref.watch(catalogueItemsProvider);
                return itemsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Erreur: $e')),
                  data: (items) {
                    var filtered = items;
                    if (_searchQuery.isNotEmpty) {
                      filtered = items
                          .where((i) =>
                              i.nom
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()) ||
                              (i.reference
                                      ?.toLowerCase()
                                      .contains(_searchQuery.toLowerCase()) ??
                                  false))
                          .toList();
                    }
                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text('Aucun article trouvé'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return ElectricCard(
                          isDark: isDark,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => widget.onItemSelected(item),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.electricBlue
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(item.categorie),
                                    color: AppColors.electricBlue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.nom,
                                          style: AppTypography.titleMedium),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          if (item.reference != null) ...[
                                            Text(item.reference!,
                                                style: AppTypography.caption),
                                            const SizedBox(width: 8),
                                          ],
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.electricPurple
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item.categorie,
                                              style: const TextStyle(
                                                fontSize: 9,
                                                color:
                                                    AppColors.electricPurple,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      item.prixUnitaire.formattedCurrency,
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.electricGreen,
                                      ),
                                    ),
                                    Text('/${item.unite.name}',
                                        style: AppTypography.caption),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.electricBlue
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.add_rounded,
                                      color: AppColors.electricBlue, size: 18),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
