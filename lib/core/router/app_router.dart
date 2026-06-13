import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:devis/features/splash/presentation/splash_page.dart';
import 'package:devis/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:devis/features/devis/presentation/pages/devis_list_page.dart';
import 'package:devis/features/devis/presentation/pages/devis_detail_page.dart';
import 'package:devis/features/devis/presentation/pages/create_devis_page.dart';
import 'package:devis/features/devis/presentation/pages/devis_preview_page.dart';
import 'package:devis/features/factures/presentation/pages/facture_list_page.dart';
import 'package:devis/features/factures/presentation/pages/facture_detail_page.dart';
import 'package:devis/features/clients/presentation/pages/client_list_page.dart';
import 'package:devis/features/clients/presentation/pages/client_detail_page.dart';
import 'package:devis/features/catalogue/presentation/pages/catalogue_page.dart';
import 'package:devis/features/chantier/presentation/pages/chantier_list_page.dart';
import 'package:devis/features/chantier/presentation/pages/chantier_detail_page.dart';
import 'package:devis/features/finance/presentation/pages/finance_page.dart';
import 'package:devis/features/activity/presentation/pages/activity_page.dart';
import 'package:devis/features/parametres/presentation/settings_page.dart';
import 'package:devis/features/auth/presentation/pages/security_lock_page.dart';
import 'package:devis/features/setup/presentation/setup_wizard_page.dart';
import 'package:devis/features/parametres/presentation/technicien_edit_page.dart';
import 'package:devis/core/extensions/responsive_extensions.dart';
import 'package:devis/data/models/devis.dart';
import 'package:devis/data/models/catalogue_item.dart';
import 'package:devis/design_system/widgets/quantum_background.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

Page<dynamic> _buildPageWithTransition(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/lock',
      builder: (context, state) => const SecurityLockPage(),
    ),
    GoRoute(
      path: '/setup',
      builder: (context, state) => const SetupWizardPage(),
    ),
    GoRoute(
      path: '/settings/technicien',
      builder: (context, state) => const TechnicienEditPage(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => _buildPageWithTransition(
            const DashboardPage(),
          ),
        ),
        GoRoute(
          path: '/activities',
          pageBuilder: (context, state) => _buildPageWithTransition(
            const ActivityPage(),
          ),
        ),
        GoRoute(
          path: '/devis',
          pageBuilder: (context, state) => _buildPageWithTransition(
            const DevisListPage(),
          ),
        ),
        GoRoute(
          path: '/devis/create',
          builder: (context, state) => CreateDevisPage(
            initialItem: state.extra as CatalogueItem?,
          ),
        ),
        GoRoute(
          path: '/devis/edit/:id',
          builder: (context, state) => CreateDevisPage(
            editDevis: state.extra as Devis?,
          ),
        ),
        GoRoute(
          path: '/devis/preview',
          builder: (context, state) => const DevisPreviewPage(),
        ),
        GoRoute(
          path: '/devis/:id',
          builder: (context, state) => DevisDetailPage(
            devisId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/factures',
          pageBuilder: (context, state) => _buildPageWithTransition(
            const FactureListPage(),
          ),
        ),
        GoRoute(
          path: '/factures/:id',
          builder: (context, state) => FactureDetailPage(
            factureId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/clients',
          pageBuilder: (context, state) => _buildPageWithTransition(
            const ClientListPage(),
          ),
        ),
        GoRoute(
          path: '/clients/:id',
          builder: (context, state) => ClientDetailPage(
            clientId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/catalogue',
          pageBuilder: (context, state) => _buildPageWithTransition(
            const CataloguePage(),
          ),
        ),
        GoRoute(
          path: '/chantiers',
          pageBuilder: (context, state) => _buildPageWithTransition(
            const ChantierListPage(),
          ),
        ),
        GoRoute(
          path: '/chantiers/:id',
          builder: (context, state) => ChantierDetailPage(
            chantierId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/finance',
          pageBuilder: (context, state) => _buildPageWithTransition(
            const FinancePage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => _buildPageWithTransition(
            const SettingsPage(),
          ),
        ),
      ],
    ),
  ],
);

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final _destinations = const [
    ('Tableau de bord', Icons.dashboard_rounded, Icons.dashboard_outlined),
    ('Catalogue', Icons.inventory_2_rounded, Icons.inventory_2_outlined),
  ];

  final _routes = [
    '/dashboard',
    '/catalogue',
  ];

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return QuantumBackground(
      child: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
              context.go(_routes[index]);
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: const Color(0xFF0F1A2E),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _showQuickActions(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4895EF), Color(0xFF7B61FF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Actions',
                      style: TextStyle(fontSize: 9, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            selectedIconTheme: const IconThemeData(color: Color(0xFF4895EF)),
            unselectedIconTheme: IconThemeData(
              color: const Color(0xFF6B7280).withValues(alpha: 0.5),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2_rounded),
                label: Text('Catalogue'),
              ),
            ],
          ),
          const VerticalDivider(width: 1, color: Color(0xFF1E2D50)),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    final items = [
      (Icons.description_rounded, 'Devis', const Color(0xFF4895EF), '/devis'),
      (Icons.receipt_rounded, 'Facture', const Color(0xFF7B61FF), '/factures'),
      (Icons.people_rounded, 'Client', const Color(0xFF06D6A0), '/clients'),
      (Icons.construction_rounded, 'Chantier', const Color(0xFFF4A261), '/chantiers'),
      (Icons.account_balance_wallet_rounded, 'Finance', const Color(0xFF06D6A0), '/finance'),
      (Icons.timeline_rounded, 'Activité', const Color(0xFFF4A261), '/activities'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Navigation rapide',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: items.map((item) {
                  final (icon, label, color, route) = item;
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 56) / 3,
                    child: _QuickActionItem(
                      icon: icon,
                      label: label,
                      color: color,
                      onTap: () { Navigator.pop(ctx); context.push(route); },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: QuantumBackground(
        child: widget.child,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark
                  ? const Color(0xFF1E2D50).withValues(alpha: 0.5)
                  : const Color(0xFFE5E7EB),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            context.go(_routes[index]);
          },
          backgroundColor:
              isDark ? const Color(0xFF0F1A2E) : const Color(0xFFFFFFFF),
          selectedItemColor: const Color(0xFF4895EF),
          unselectedItemColor: isDark
              ? const Color(0xFF6B7280)
              : const Color(0xFF9CA3AF),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            letterSpacing: 0.3,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            letterSpacing: 0.3,
          ),
          items: [
            ..._destinations.map((d) => BottomNavigationBarItem(
                  icon: Icon(d.$2),
                  activeIcon: Icon(d.$3),
                  label: d.$1,
                )),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          onPressed: () => _showQuickActions(context),
          backgroundColor: const Color(0xFF4895EF),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
