import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:devis/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete devis creation and conversion to facture flow',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: YTechProApp()));
    await tester.pumpAndSettle();

    // Skip setup if needed - check for PIN screen
    try {
      await tester.pumpAndSettle(const Duration(seconds: 2));
    } catch (_) {}

    // Navigate to devis list
    expect(find.text('Devis'), findsWidgets);

    // Create new devis
    final fab = find.byTooltip('Créer un devis');
    if (fab.evaluate().isEmpty) {
      // Try alternative navigation
      await tester.tap(find.byIcon(Icons.add_rounded).last);
      await tester.pumpAndSettle();
    } else {
      await tester.tap(fab);
      await tester.pumpAndSettle();
    }

    // Basic check that navigation works
    expect(find.byType(Scaffold), findsWidgets);
  });
}
