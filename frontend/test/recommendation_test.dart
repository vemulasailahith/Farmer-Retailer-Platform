import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/recommendation_model.dart';
import 'package:frontend/screens/farmer/recommendation_screen.dart';
import 'package:frontend/services/recommendation_repository.dart';

void main() {
  group('Recommendation Model Tests', () {
    test('1. mockSample matches exact STEP 4 specification', () {
      final sample = RecommendationResponse.mockSample;

      // Supply checks
      expect(sample.supply.commodity, 'Rice');
      expect(sample.supply.state, 'Andhra Pradesh');
      expect(sample.supply.district, 'Guntur');
      expect(sample.supply.farmAreaHa, 5.0);
      expect(sample.supply.predictedYieldKgPerHa, 5451.25);
      expect(sample.supply.expectedSupplyKg, closeTo(27256.2498, 0.001));
      expect(sample.supply.expectedSupplyTonnes, closeTo(27.2562, 0.001));

      // Freshness checks
      expect(sample.freshness.freshProbability, closeTo(0.9231, 0.001));
      expect(sample.freshness.rottenProbability, closeTo(0.0769, 0.001));
      expect(sample.freshness.confidence, closeTo(0.9231, 0.001));

      // Markets checks
      expect(sample.markets.length, 2);

      final guntur = sample.markets.firstWhere((m) => m.market == 'Guntur Market');
      expect(guntur.buyerName, 'Buyer A');
      expect(guntur.route.distanceKm, 2.18);
      expect(guntur.route.travelTimeHours, 0.05);
      expect(guntur.transport.transportCost, 65.40);
      expect(guntur.spoilage.spoilagePercentage, closeTo(14.0968, 0.001));
      expect(guntur.demand.demandKg, 5000.0);
      expect(guntur.demand.availableCapacityKg, 28000.0);
      expect(guntur.demand.demandCoverage, 0.4);
      expect(guntur.price.currentModalPrice, 3300.0);
      expect(guntur.price.predictedFutureModalPrice, 3229.90);
      expect(guntur.price.predictedPricePerKg, 32.30);
      expect(guntur.decision.sellableQuantityKg, 5000.0);
      expect(guntur.decision.grossRevenue, 161500.0);
      expect(guntur.decision.netRevenue, 161434.60);
      expect(guntur.decision.feasible, true);

      final vijayawada = sample.markets.firstWhere((m) => m.market == 'Vijayawada Market');
      expect(vijayawada.buyerName, 'Buyer B');
      expect(vijayawada.route.distanceKm, 35.9);
      expect(vijayawada.route.travelTimeHours, 0.6);
      expect(vijayawada.transport.transportCost, 1077.0);
      expect(vijayawada.spoilage.spoilagePercentage, closeTo(14.326, 0.001));
      expect(vijayawada.demand.demandKg, 6000.0);
      expect(vijayawada.demand.availableCapacityKg, 28000.0);
      expect(vijayawada.demand.demandCoverage, closeTo(0.3333, 0.001));
      expect(vijayawada.price.currentModalPrice, 3400.0);
      expect(vijayawada.price.predictedFutureModalPrice, 3437.81);
      expect(vijayawada.price.predictedPricePerKg, 34.38);
      expect(vijayawada.decision.sellableQuantityKg, 6000.0);
      expect(vijayawada.decision.grossRevenue, 206280.0);
      expect(vijayawada.decision.netRevenue, 205203.0);
      expect(vijayawada.decision.feasible, true);
      expect(vijayawada.decision.isRecommended, true);

      // Recommendation summary
      expect(sample.recommendation.market, 'Vijayawada Market');
      expect(sample.recommendation.buyerName, 'Buyer B');
      expect(sample.recommendedMarket.market, 'Vijayawada Market');
      expect(sample.recommendedMarket.buyerName, 'Buyer B');
    });

    test('2. fromJson and toJson round-trip preserves all nested fields', () {
      final sample = RecommendationResponse.mockSample;
      final json = sample.toJson();
      final parsed = RecommendationResponse.fromJson(json);

      expect(parsed.supply.commodity, sample.supply.commodity);
      expect(parsed.supply.expectedSupplyKg, sample.supply.expectedSupplyKg);
      expect(parsed.freshness.freshProbability, sample.freshness.freshProbability);
      expect(parsed.markets.length, 2);
      expect(parsed.recommendation.market, 'Vijayawada Market');
      expect(parsed.recommendedMarket.decision.netRevenue, 205203.0);
    });

    test('3. MockRecommendationRepository returns mock sample without errors', () async {
      const repo = MockRecommendationRepository();
      final result = await repo.getRecommendation();
      expect(result.recommendedMarket.market, 'Vijayawada Market');
      expect(result.supply.commodity, 'Rice');
    });
  });

  group('RecommendationScreen Widget Tests', () {
    testWidgets('Renders all 11 recommendation sections cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: RecommendationScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Header Banner
      expect(find.text('Farm-to-Market Recommendation'), findsWidgets);
      expect(find.text('Recommended selling option'), findsOneWidget);

      // 2. Analysis Status
      expect(find.text('Analyzing your farm details'), findsOneWidget);
      expect(find.text('Analysis Complete'), findsOneWidget);

      // 3. Recommended Market Card
      expect(find.text('Recommended Market'), findsOneWidget);
      expect(find.text('Vijayawada Market'), findsWidgets);
      expect(find.text('Buyer B'), findsWidgets);
      expect(find.text('₹34.38'), findsOneWidget);
      expect(find.text('₹205,203'), findsWidgets);

      // 4. Supply Summary Card
      expect(find.text('Expected Supply'), findsWidgets);
      expect(find.text('27,256 kg'), findsOneWidget);
      expect(find.text('27.26 tonnes'), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('5 ha'), findsOneWidget);

      // 5. Market Comparison
      expect(find.text('Market Comparison'), findsOneWidget);
      expect(find.text('Guntur Market'), findsOneWidget);
      expect(find.text('Buyer A'), findsOneWidget);

      // 6. Why This Recommendation?
      expect(find.text('Why this recommendation?'), findsOneWidget);

      // 7. Transport Route Card
      expect(find.text('Transport Route'), findsOneWidget);
      expect(find.text('35.9 km'), findsOneWidget);
      expect(find.text('~0.6 hrs'), findsOneWidget);
      expect(find.text('₹1,077'), findsWidgets);

      // 8. Freshness & Spoilage Card
      expect(find.text('Freshness & Spoilage'), findsOneWidget);
      expect(find.text('92.31%'), findsOneWidget);
      expect(find.text('7.69%'), findsOneWidget);

      // 9. Price Details Card
      expect(find.text('Price Analysis'), findsOneWidget);

      // 10. Demand & Buyer Capacity Card
      expect(find.text('Demand & Buyer Capacity'), findsOneWidget);

      // 11. Action Buttons
      expect(find.text('View Market Details'), findsOneWidget);
      expect(find.text('Start New Recommendation'), findsOneWidget);
    });
  });
}
