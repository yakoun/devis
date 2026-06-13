import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/core/extensions/num_extensions.dart';
import 'package:devis/core/extensions/context_extensions.dart';
import 'package:devis/data/models/catalogue_item.dart';
import 'package:devis/data/models/catalogue_data.dart';
import 'package:devis/data/providers/providers.dart';
import 'package:devis/core/utils/enums.dart';

class CataloguePage extends ConsumerStatefulWidget {
  const CataloguePage({super.key});

  @override
  ConsumerState<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends ConsumerState<CataloguePage> {
  String _selectedCategory = 'Tous';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  List<CatalogueItem> get _filteredItems {
    var items = CatalogueData.allItems;
    if (_selectedCategory != 'Tous') {
      items = items.where((i) => i.categorie == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      items = items
          .where((i) =>
              i.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (i.reference?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
          .toList();
    }
    return items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  void _showAddItemDialog(BuildContext context) {
    final nomCtrl = TextEditingController();
    final prixCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    String selectedCategorie = CatalogueData.categories.first;
    Unite selectedUnite = Unite.piece;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Ajouter au catalogue'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PremiumTextField(
                  label: 'Nom',
                  controller: nomCtrl,
                ),
                const SizedBox(height: 12),
                PremiumTextField(
                  label: 'Prix unitaire',
                  controller: prixCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                PremiumTextField(
                  label: 'Référence',
                  controller: refCtrl,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategorie,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    filled: true,
                  ),
                  items: CatalogueData.categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setDialogState(() => selectedCategorie = v);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Unite>(
                  initialValue: selectedUnite,
                  decoration: const InputDecoration(
                    labelText: 'Unité',
                    filled: true,
                  ),
                  items: Unite.values.map((u) {
                    return DropdownMenuItem(value: u, child: Text(u.name));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setDialogState(() => selectedUnite = v);
                    }
                  },
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
              onPressed: () async {
                if (nomCtrl.text.isEmpty || prixCtrl.text.isEmpty) return;
                final item = CatalogueItem(
                  id: 'catalogue_${DateTime.now().millisecondsSinceEpoch}',
                  nom: nomCtrl.text,
                  prixUnitaire:
                      double.tryParse(prixCtrl.text.replaceAll(' ', '')) ?? 0,
                  categorie: selectedCategorie,
                  unite: selectedUnite,
                  reference: refCtrl.text.isNotEmpty ? refCtrl.text : null,
                  stock: 0,
                  isActive: true,
                );
                try {
                  await ref
                      .read(hiveRepositoryProvider)
                      .saveCatalogueItem(item);
                  ref.invalidate(catalogueItemsProvider);
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  if (!context.mounted) return;
                  context.showSnackBar('Article ajouté au catalogue');
                } catch (e) {
                  if (!context.mounted) return;
                  context.showSnackBar('Erreur: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ['Tous', ...CatalogueData.categories];
    final items = _filteredItems;

    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Catalogue',
        showBack: false,
        isDark: isDark,
        actions: [
          CountBadge(count: items.length, isDark: isDark),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajouter'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PremiumTextField(
              hint: 'Rechercher un matériel...',
              prefixIcon: Icons.search_rounded,
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              suffixIcon: _searchQuery.isNotEmpty
                  ? Icons.clear_rounded
                  : null,
              onSuffixTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat),
                    selectedColor:
                        AppColors.electricBlue.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.electricBlue
                          : (isDark
                              ? AppColors.textOnDarkSecondary
                              : AppColors.textSecondary),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    backgroundColor:
                        isDark ? AppColors.darkSurfaceLight : AppColors.lightCard,
                    side: BorderSide.none,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: EmptyState(
                            icon: Icons.inventory_2_outlined,
                            title: 'Aucun article',
                            subtitle: 'Ajoutez des articles à votre catalogue',
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return AnimatedListItem(
                          index: index,
                          child: _CatalogueItemCard(
                            item: item,
                            isDark: isDark,
                            onAdd: () {
                              context.go('/devis/create',
                                  extra: item);
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CatalogueItemCard extends StatelessWidget {
  final CatalogueItem item;
  final bool isDark;
  final VoidCallback onAdd;

  const _CatalogueItemCard({
    required this.item,
    required this.isDark,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return ElectricCard(
      isDark: isDark,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.1),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nom, style: AppTypography.titleMedium),
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
                        color: AppColors.electricPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.categorie,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.electricPurple,
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
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.electricBlue, size: 18),
            ),
          ),
        ],
      ),
    );
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
}
