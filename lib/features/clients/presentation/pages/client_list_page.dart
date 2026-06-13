import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devis/design_system/design_system.dart';
import 'package:devis/core/widgets/searchable_list.dart';
import 'package:devis/data/models/client.dart';
import 'package:devis/data/providers/providers.dart';

class ClientListPage extends ConsumerStatefulWidget {
  const ClientListPage({super.key});

  @override
  ConsumerState<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends ConsumerState<ClientListPage> {
  Future<void> _refresh() async {
    ref.invalidate(clientsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Clients',
        showBack: false,
        isDark: isDark,
        actions: [
          if (clientsAsync.asData?.value case final clients?)
            CountBadge(count: clients.length, isDark: isDark),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClientDialog(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: clientsAsync.when(
        loading: () => ShimmerLoading(
          isDark: isDark,
          itemCount: 4,
          itemBuilder: (index) => SkeletonClientCard(isDark: isDark),
        ),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (clients) {
          if (clients.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: EmptyState(
                      icon: Icons.people_outlined,
                      title: 'Aucun client',
                      subtitle: 'Ajoutez votre premier client pour commencer',
                      actionLabel: 'Ajouter un premier client',
                      onAction: () => _showAddClientDialog(context, ref),
                    ),
                  ),
                ],
              ),
            );
          }
          return SearchableList<AppClient>(
            items: clients,
            searchKey: (c) => '${c.nom} ${c.email ?? ''} ${c.telephone}',
            hintText: 'Rechercher un client...',
            header: (filtered) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text('${filtered.length} clients',
                  style: AppTypography.caption),
            ),
            itemBuilder: (c, index) => AnimatedListItem(
              index: index,
              child: _ClientCard(client: c, isDark: isDark),
            ),
          );
        },
      ),
    );
  }

  void _showAddClientDialog(BuildContext context, WidgetRef ref) {
    final nomCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final adresseCtrl = TextEditingController();
    final villeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4895EF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_add_rounded, color: Color(0xFF4895EF), size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Nouveau client', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        content: SizedBox(
          width: MediaQuery.of(ctx).size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PremiumTextField(label: 'Nom *', controller: nomCtrl),
                const SizedBox(height: 12),
                PremiumTextField(label: 'Téléphone *', controller: telCtrl, keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                PremiumTextField(label: 'Email', controller: emailCtrl, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                PremiumTextField(label: 'Adresse', controller: adresseCtrl),
                const SizedBox(height: 12),
                PremiumTextField(label: 'Ville', controller: villeCtrl),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          GlowButton(
            label: 'AJOUTER',
            onPressed: () async {
              if (nomCtrl.text.isEmpty || telCtrl.text.isEmpty) {
                AppSnackbar.error(context, 'Nom et téléphone requis');
                return;
              }
              final client = AppClient.create(
                nom: nomCtrl.text,
                email: emailCtrl.text.isNotEmpty ? emailCtrl.text : null,
                telephone: telCtrl.text,
                adresse: adresseCtrl.text.isNotEmpty ? adresseCtrl.text : null,
                ville: villeCtrl.text.isNotEmpty ? villeCtrl.text : null,
              );
              final repo = ref.read(hiveRepositoryProvider);
              await repo.saveClient(client);
              if (!ctx.mounted) return;
              ref.invalidate(clientsProvider);
              Navigator.pop(ctx);
              if (!context.mounted) return;
              AppSnackbar.success(context, 'Client ajouté avec succès');
            },
          ),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final AppClient client;
  final bool isDark;
  const _ClientCard({required this.client, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ElectricCard(
      isDark: isDark,
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => GoRouter.of(context).push('/clients/${client.id}'),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              client.nom[0].toUpperCase(),
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.nom, style: AppTypography.titleMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone_rounded,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(client.telephone, style: AppTypography.bodySmall),
                  ],
                ),
                if (client.email != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.email_rounded,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(client.email!, style: AppTypography.bodySmall),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              client.category.name,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.electricBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
