import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/screens/farmer/farmer_home_screen.dart';

void main() {
  Widget createTestWidget({int initialIndex = 0}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: FarmerHomeScreen(initialIndex: initialIndex),
    );
  }

  testWidgets('FarmerHomeScreen renders all 5 Stitch navigation tabs', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify all 5 tab labels are visible in the bottom navigation bar
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Recommend'), findsOneWidget);
    expect(find.text('Results'), findsOneWidget);
    expect(find.text('Shipments'), findsWidgets);
    expect(find.text('Orders'), findsWidgets);

    // Verify initial dashboard contents
    expect(find.text('Namaste, Ramesh Rao!'), findsOneWidget);
    expect(find.text('Ready for Harvest? Get Market Recommendation'), findsOneWidget);
    expect(find.text('LAND AREA'), findsOneWidget);
  });

  testWidgets('Switching to Orders tab displays orders and settlements view', (tester) async {
    await tester.pumpWidget(createTestWidget(initialIndex: 4));
    await tester.pumpAndSettle();

    // Verify Orders tab content
    expect(find.text('TOTAL SETTLED REALIZATION'), findsOneWidget);
    expect(find.text('₹6,51,380'), findsOneWidget);
    expect(find.text('#FV-8410'), findsOneWidget);
  });

  testWidgets('Switching to Shipments tab displays live GPS transit view', (tester) async {
    await tester.pumpWidget(createTestWidget(initialIndex: 3));
    await tester.pumpAndSettle();

    // Verify Shipments tab content
    expect(find.text('Transit On Schedule'), findsOneWidget);
    expect(find.text('TRK-TEL-9082'), findsOneWidget);
    expect(find.text('Ashok Leyland Dost'), findsOneWidget);
    expect(find.text('K. Venkatesh'), findsOneWidget);
  });

  testWidgets('Tapping Recommend tab changes screen to assessment wizard', (tester) async {
    await tester.pumpWidget(createTestWidget(initialIndex: 0));
    await tester.pumpAndSettle();

    // Tap the Recommend tab
    await tester.tap(find.text('Recommend'));
    await tester.pumpAndSettle();

    // Verify the Assessment Wizard title
    expect(find.text('Crop Assessment Wizard'), findsOneWidget);
  });
}
