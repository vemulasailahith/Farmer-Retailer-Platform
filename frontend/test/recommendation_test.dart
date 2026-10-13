import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/recommendation_model.dart';
import 'package:frontend/screens/farmer/farmer_input_screen.dart';
import 'package:frontend/screens/farmer/recommendation_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/recommendation_repository.dart';

/// Test mock for ApiService that intercepts HTTP calls
class FakeApiService extends ApiService {
  Map<String, dynamic>? lastDataSent;
  List<int>? lastImageSent;
  Map<String, dynamic> responseToReturn;

  FakeApiService({required this.responseToReturn});

  @override
  Future<Map<String, dynamic>> getRecommendation({
    required Map<String, dynamic> data,
    required List<int> imageBytes,
  }) async {
    lastDataSent = data;
    lastImageSent = imageBytes;
    return responseToReturn;
  }
}

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
      expect(sample.supply.predictionSource, 'ml_model');
      expect(sample.supply.isDemoPrediction, false);

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

    test('3. MockRecommendationRepository returns mock sample without errors (PART 14.10)', () async {
      const repo = MockRecommendationRepository();
      final result = await repo.getRecommendation();
      expect(result.recommendedMarket.market, 'Vijayawada Market');
      expect(result.supply.commodity, 'Rice');
    });

    test('4. ML prediction source parses correctly (PART 14.8)', () {
      final json = RecommendationResponse.mockSample.toJson();
      (json['supply'] as Map<String, dynamic>)['prediction_source'] = 'ml_model';
      (json['supply'] as Map<String, dynamic>)['is_demo_prediction'] = false;

      final parsed = RecommendationResponse.fromJson(json);
      expect(parsed.supply.predictionSource, 'ml_model');
      expect(parsed.supply.isDemoPrediction, false);
    });

    test('5. Demo fallback prediction source parses correctly (PART 14.9)', () {
      final json = RecommendationResponse.mockSample.toJson();
      (json['supply'] as Map<String, dynamic>)['prediction_source'] = 'demo_fallback';
      (json['supply'] as Map<String, dynamic>)['is_demo_prediction'] = true;

      final parsed = RecommendationResponse.fromJson(json);
      expect(parsed.supply.predictionSource, 'demo_fallback');
      expect(parsed.supply.isDemoPrediction, true);
    });
  });

  group('ApiRecommendationRepository Tests (PART 14)', () {
    test('1. ApiRecommendationRepository can construct the correct nested payload (PART 14.1)', () {
      final payload = ApiRecommendationRepository.buildPayload(
        crop: 'Tomato',
        areaHa: 2.5,
        stateName: 'Andhra Pradesh',
        distName: 'Guntur',
        latitude: 16.3067,
        longitude: 80.4365,
        year: 2026,
        temperatureC: 29.5,
        humidityPercent: 68.0,
      );

      expect(payload, isA<Map<String, dynamic>>());
      expect(payload['price_unit'], 'INR/kg');
    });

    test('2. Payload contains supply with all required fields (PART 14.2)', () {
      final payload = ApiRecommendationRepository.buildPayload(
        crop: 'Tomato',
        areaHa: 3.0,
        stateName: 'Andhra Pradesh',
        distName: 'Guntur',
        latitude: 16.3067,
        longitude: 80.4365,
        year: 2026,
      );

      expect(payload.containsKey('supply'), true);
      final supply = payload['supply'] as Map<String, dynamic>;
      expect(supply['crop'], 'Tomato');
      expect(supply['area_ha'], 3.0);
      expect(supply['state_name'], 'Andhra Pradesh');
      expect(supply['dist_name'], 'Guntur');
      expect(supply['year'], 2026);
      expect(supply.containsKey('n_req_kg_per_ha'), true);
      expect(supply.containsKey('p_req_kg_per_ha'), true);
      expect(supply.containsKey('k_req_kg_per_ha'), true);
      expect(supply.containsKey('temperature_c'), true);
      expect(supply.containsKey('humidity_percent'), true);
      expect(supply.containsKey('ph'), true);
      expect(supply.containsKey('rainfall_mm'), true);
      expect(supply.containsKey('wind_speed_m_s'), true);
      expect(supply.containsKey('solar_radiation_mj_m2_day'), true);
    });

    test('3. Payload contains farmer_location (PART 14.3)', () {
      final payload = ApiRecommendationRepository.buildPayload(
        crop: 'Onion',
        areaHa: 1.5,
        stateName: 'Telangana',
        distName: 'Warangal',
        latitude: 17.9689,
        longitude: 79.5941,
        year: 2026,
      );

      expect(payload.containsKey('farmer_location'), true);
      final loc = payload['farmer_location'] as Map<String, dynamic>;
      expect(loc['latitude'], 17.9689);
      expect(loc['longitude'], 79.5941);
    });

    test('4. Payload contains spoilage (PART 14.4)', () {
      final payload = ApiRecommendationRepository.buildPayload(
        crop: 'Brinjal',
        areaHa: 2.0,
        stateName: 'Andhra Pradesh',
        distName: 'Krishna',
        latitude: 16.5062,
        longitude: 80.6480,
        year: 2026,
        temperatureC: 30.0,
        humidityPercent: 75.0,
      );

      expect(payload.containsKey('spoilage'), true);
      final spoilage = payload['spoilage'] as Map<String, dynamic>;
      expect(spoilage['shelf_life_hours'], 72.0);
      expect(spoilage['temperature_c'], 30.0);
      expect(spoilage['humidity_percent'], 75.0);
    });

    test('5. Payload contains two markets with candidate buyers (PART 14.5)', () {
      final payload = ApiRecommendationRepository.buildPayload(
        crop: 'Tomato',
        areaHa: 4.0,
        stateName: 'Andhra Pradesh',
        distName: 'Guntur',
        latitude: 16.3067,
        longitude: 80.4365,
        year: 2026,
      );

      expect(payload.containsKey('markets'), true);
      final markets = payload['markets'] as List<dynamic>;
      expect(markets.length, 2);

      final m1 = markets[0] as Map<String, dynamic>;
      expect(m1['market'], 'Guntur Market');
      expect(m1['buyer_name'], 'Buyer A');
      expect((m1['demand'] as Map)['demand_kg'], 5000.0);
      expect((m1['demand'] as Map)['buyer_capacity_kg'], 30000.0);

      final m2 = markets[1] as Map<String, dynamic>;
      expect(m2['market'], 'Vijayawada Market');
      expect(m2['buyer_name'], 'Buyer B');
      expect((m2['demand'] as Map)['demand_kg'], 6000.0);
      expect((m2['demand'] as Map)['buyer_capacity_kg'], 30000.0);
    });

    test('6. Tomato payload is accepted and processed by repository (PART 14.6)', () async {
      final fakeApi = FakeApiService(
        responseToReturn: RecommendationResponse.mockSample.toJson(),
      );

      final repo = ApiRecommendationRepository(
        apiService: fakeApi,
        inputs: {
          'crop': 'Tomato',
          'area_ha': 2.0,
          'latitude': 16.3067,
          'longitude': 80.4365,
          'state_name': 'Andhra Pradesh',
          'dist_name': 'Guntur',
        },
      );

      final response = await repo.getRecommendation();
      expect(response, isNotNull);
      expect(fakeApi.lastDataSent!['supply']['crop'], 'Tomato');
      expect(fakeApi.lastDataSent!['supply']['area_ha'], 2.0);
    });

    test('7. Potato payload is accepted and processed by repository (PART 14.7)', () async {
      final fakeApi = FakeApiService(
        responseToReturn: RecommendationResponse.mockSample.toJson(),
      );

      final repo = ApiRecommendationRepository(
        apiService: fakeApi,
        inputs: {
          'crop': 'Potato',
          'area_ha': 4.5,
          'latitude': 16.3067,
          'longitude': 80.4365,
          'state_name': 'Andhra Pradesh',
          'dist_name': 'Guntur',
        },
      );

      final response = await repo.getRecommendation();
      expect(response, isNotNull);
      expect(fakeApi.lastDataSent!['supply']['crop'], 'Potato');
      expect(fakeApi.lastDataSent!['supply']['area_ha'], 4.5);
    });
  });

  group('RecommendationScreen Widget Tests', () {
    testWidgets('Renders all 11 recommendation sections cleanly with ML badge', (WidgetTester tester) async {
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

      // 4. Supply Summary Card & ML badge
      expect(find.text('Expected Supply'), findsWidgets);
      expect(find.text('ML Prediction'), findsOneWidget);
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

    testWidgets('Renders Demo Estimate badge when isDemoPrediction is true', (WidgetTester tester) async {
      final demoSample = RecommendationResponse(
        supply: const SupplyData(
          commodity: 'Tomato',
          state: 'Andhra Pradesh',
          district: 'Guntur',
          farmAreaHa: 2.0,
          predictedYieldKgPerHa: 4000.0,
          expectedSupplyKg: 8000.0,
          expectedSupplyTonnes: 8.0,
          predictionSource: 'demo_fallback',
          isDemoPrediction: true,
        ),
        freshness: RecommendationResponse.mockSample.freshness,
        priceUnit: 'INR/kg',
        markets: RecommendationResponse.mockSample.markets,
        recommendation: RecommendationResponse.mockSample.recommendation,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: RecommendationScreen(recommendationData: demoSample),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Demo Estimate'), findsOneWidget);
      expect(find.text('Tomato'), findsOneWidget);
    });
  });

  group('FarmerInputScreen Season Selection Tests (STEP 5D)', () {
    testWidgets('1. Season dropdown renders and defaults to Whole Year', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: FarmerInputScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Step 4 (Details) in Stepper to expand Step 4
      await tester.tap(find.text('Details').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('season_dropdown')));
      await tester.pumpAndSettle();

      // Verify Season dropdown renders
      final dropdownFinder = find.byKey(const Key('season_dropdown'));
      expect(dropdownFinder, findsOneWidget);

      // Verify Whole Year is the default
      expect(find.text('Whole Year'), findsOneWidget);
    });

    testWidgets('2. User can select Rabi from Season dropdown', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: FarmerInputScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Step 4 (Details)
      await tester.tap(find.text('Details').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('season_dropdown')));
      await tester.pumpAndSettle();

      // Tap on Season dropdown to open menu
      await tester.tap(find.byKey(const Key('season_dropdown')));
      await tester.pumpAndSettle();

      // Verify dropdown menu options are displayed
      expect(find.text('Rabi').last, findsOneWidget);

      // Tap on Rabi option
      await tester.tap(find.text('Rabi').last);
      await tester.pumpAndSettle();

      // Verify Rabi is now selected
      expect(find.text('Rabi'), findsWidgets);
    });

    test('3. Selected season reaches recommendation payload via buildPayload and buildPayloadFromInputMap', () {
      // Default Whole Year
      final defaultPayload = ApiRecommendationRepository.buildPayload(
        crop: 'Potato',
        areaHa: 5.0,
        stateName: 'Andhra Pradesh',
        distName: 'Guntur',
        latitude: 16.3067,
        longitude: 80.4365,
        year: 2026,
      );
      expect((defaultPayload['supply'] as Map)['season'], 'Whole Year');

      // Custom Rabi
      final rabiPayload = ApiRecommendationRepository.buildPayload(
        crop: 'Potato',
        areaHa: 5.0,
        stateName: 'Andhra Pradesh',
        distName: 'Guntur',
        latitude: 16.3067,
        longitude: 80.4365,
        year: 2026,
        season: 'Rabi',
      );
      expect((rabiPayload['supply'] as Map)['season'], 'Rabi');

      // buildPayloadFromInputMap with season: Rabi
      final mapPayload = ApiRecommendationRepository.buildPayloadFromInputMap({
        'crop': 'Potato',
        'area_ha': 5.0,
        'state_name': 'Andhra Pradesh',
        'dist_name': 'Guntur',
        'latitude': 16.3067,
        'longitude': 80.4365,
        'year': 2026,
        'season': 'Rabi',
      });
      expect((mapPayload['supply'] as Map)['season'], 'Rabi');
    });
  });
}
