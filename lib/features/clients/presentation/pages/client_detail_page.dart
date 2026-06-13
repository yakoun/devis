import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/core/extensions/num_extensions.dart';
import 'package:devis/core/extensions/string_extensions.dart';
import 'package:devis/data/models/client.dart';
import 'package:devis/data/models/devis.dart';
import 'package:devis/data/models/facture.dart';
import 'package:devis/data/providers/providers.dart';
import 'package:devis/core/utils/enums.dart';
import 'package:devis/core/extensions/date_extensions.dart';

class ClientDetailPage extends ConsumerStatefulWidget {
  final String clientId;
  const ClientDetailPage({super.key, required this.clientId});

  @override
  ConsumerState<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends ConsumerState<ClientDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteClient(AppClient client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ${client.nom} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Color(0xFFEF476F))),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(hiveRepositoryProvider).deleteClient(client.id);
        ref.invalidate(clientsProvider);
        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la suppression : $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clientsAsync = ref.watch(clientsProvider);
    final devisAsync = ref.watch(devisProvider);
    final facturesAsync = ref.watch(facturesProvider);

    return clientsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
      data: (clients) {
        final matches = clients.where((c) => c.id == widget.clientId).toList();
        if (matches.isEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_off_rounded, size: 48, color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                  const SizedBox(height: 16),
                  Text('Client introuvable', style: TextStyle(fontSize: 16, color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151))),
                ],
              ),
            ),
          );
        }
        final c = matches.first;
        final devis = devisAsync.asData?.value ?? [];
        final factures = facturesAsync.asData?.value ?? [];
        final clientDevis = devis.where((d) => d.client.contact == widget.clientId).toList();
        final clientFactures = factures.where((f) => f.clientId == widget.clientId).toList();

        final totalDepense = clientFactures
            .where((f) => f.statut == FactureStatus.payee)
            .fold<double>(0, (sum, f) => sum + f.total);
        final totalImpaye = clientFactures
            .where((f) => f.statut == FactureStatus.impayee || f.statut == FactureStatus.partielle)
            .fold<double>(0, (sum, f) => sum + (f.total - f.montantPaye));

        return Scaffold(
          appBar: PremiumAppBar(
            title: c.nom,
            isDark: isDark,
            actions: [
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'devis', child: ListTile(leading: Icon(Icons.description_rounded, size: 20), title: Text('Nouveau devis'), dense: true)),
                  const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_rounded, size: 20), title: Text('Modifier'), dense: true)),
                  const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_rounded, size: 20, color: Color(0xFFEF476F)), title: Text('Supprimer', style: TextStyle(color: Color(0xFFEF476F))), dense: true)),
                ],
                onSelected: (value) {
                  if (value == 'devis') context.push('/devis/create');
                  if (value == 'delete') _deleteClient(c);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              _buildClientHeader(isDark, c, clientDevis.length, clientFactures.length, totalDepense, totalImpaye),
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF4895EF),
                labelColor: const Color(0xFF4895EF),
                unselectedLabelColor: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                tabs: [
                  Tab(text: 'Devis (${clientDevis.length})'),
                  Tab(text: 'Factures (${clientFactures.length})'),
                  const Tab(text: 'Infos'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDevisTab(isDark, clientDevis),
                    _buildFactureTab(isDark, clientFactures),
                    _buildInfoTab(isDark, c),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClientHeader(bool isDark, AppClient c, int devisCount, int factureCount, double totalDepense, double totalImpaye) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF132042).withValues(alpha: 0.6), const Color(0xFF0F1A2E).withValues(alpha: 0.3)]
              : [const Color(0xFFFFFFFF).withValues(alpha: 0.9), const Color(0xFFF8F9FA).withValues(alpha: 0.6)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (isDark ? const Color(0xFF1E2D50) : const Color(0xFFE5E7EB)).withValues(alpha: 0.5), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(gradient: AppGradients.primary, shape: BoxShape.circle),
            child: Text(c.nom[0].toUpperCase(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.nom, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone_rounded, size: 12, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(c.telephone, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                  ],
                ),
                if (c.email != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.email_rounded, size: 12, color: Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      Text(c.email!, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF4895EF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(c.category.name.capitalize, style: const TextStyle(fontSize: 10, color: Color(0xFF4895EF), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildDevisTab(bool isDark, List<Devis> devis) {
    if (devis.isEmpty) {
      return _emptyTab(isDark, Icons.description_outlined, 'Aucun devis', 'Créez un devis pour ce client');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: devis.length,
      itemBuilder: (context, index) {
        final d = devis[index];
        return _DevisFactureCard(
          isDark: isDark,
          title: d.numero,
          subtitle: d.date.formatted,
          value: d.netAPayer.formattedCurrency,
          status: d.statut.capitalize,
          statusColor: d.statut == 'accepté' ? const Color(0xFF06D6A0) : d.statut == 'refusé' ? const Color(0xFFEF476F) : const Color(0xFF4895EF),
          icon: Icons.description_rounded,
          onTap: () => context.push('/devis/${d.id}'),
        );
      },
    );
  }

  Widget _buildFactureTab(bool isDark, List<Facture> factures) {
    if (factures.isEmpty) {
      return _emptyTab(isDark, Icons.receipt_outlined, 'Aucune facture', 'Créez une facture depuis un devis');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: factures.length,
      itemBuilder: (context, index) {
        final f = factures[index];
        return _DevisFactureCard(
          isDark: isDark,
          title: f.numero,
          subtitle: f.dateEmission.formatted,
          value: f.total.formattedCurrency,
          status: f.statut.name.capitalize,
          statusColor: f.statut == FactureStatus.payee ? const Color(0xFF06D6A0) : f.statut == FactureStatus.impayee ? const Color(0xFFEF476F) : const Color(0xFFF4A261),
          icon: Icons.receipt_rounded,
          onTap: () => context.push('/factures/${f.id}'),
        );
      },
    );
  }

  Widget _buildInfoTab(bool isDark, AppClient c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InfoRow(isDark: isDark, icon: Icons.phone_rounded, label: 'Téléphone', value: c.telephone),
          if (c.email != null) _InfoRow(isDark: isDark, icon: Icons.email_rounded, label: 'Email', value: c.email!),
          if (c.adresse != null) _InfoRow(isDark: isDark, icon: Icons.location_on_rounded, label: 'Adresse', value: c.adresse!),
          if (c.ville != null) _InfoRow(isDark: isDark, icon: Icons.location_city_rounded, label: 'Ville', value: c.ville!),
          if (c.siret != null) _InfoRow(isDark: isDark, icon: Icons.business_rounded, label: 'SIRET', value: c.siret!),
          if (c.notes != null) _InfoRow(isDark: isDark, icon: Icons.notes_rounded, label: 'Notes', value: c.notes!),
        ],
      ),
    );
  }

  Widget _emptyTab(bool isDark, IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151))),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _DevisFactureCard extends StatelessWidget {
  final bool isDark;
  final String title, subtitle, value, status;
  final Color statusColor;
  final IconData icon;
  final VoidCallback onTap;

  const _DevisFactureCard({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF132042).withValues(alpha: 0.5), const Color(0xFF0F1A2E).withValues(alpha: 0.3)]
                  : [const Color(0xFFFFFFFF), const Color(0xFFF8F9FA)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: (isDark ? const Color(0xFF1E2D50) : const Color(0xFFE5E7EB)).withValues(alpha: 0.3), width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: statusColor)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(status, style: TextStyle(fontSize: 8, color: statusColor, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label, value;

  const _InfoRow({required this.isDark, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF132042).withValues(alpha: 0.5), const Color(0xFF0F1A2E).withValues(alpha: 0.3)]
              : [const Color(0xFFFFFFFF), const Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (isDark ? const Color(0xFF1E2D50) : const Color(0xFFE5E7EB)).withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF4895EF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: const Color(0xFF4895EF)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 9, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937))),
            ],
          ),
        ],
      ),
    );
  }
}
