import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/screens/farmer/recommendation_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/recommendation_repository.dart';

void main() async {
  late Uint8List sampleImageBytes;
  var isBackendAvailable = false;

  try {
    final client = HttpClient();
    final request = await client
        .getUrl(Uri.parse('http://127.0.0.1:8000/health'))
        .timeout(const Duration(seconds: 2));
    final response = await request.close().timeout(const Duration(seconds: 2));
    isBackendAvailable = (response.statusCode == 200);
    client.close();
  } catch (_) {
    isBackendAvailable = false;
  }

  group('Real Live FastAPI Integration Tests (STEP 5B.3)', () {
    setUpAll(() async {
      HttpOverrides.global = null;
      ApiService.overrideBaseUrl = 'http://127.0.0.1:8000';
      // Ensure produce image bytes are loaded for test runner
      sampleImageBytes = await ApiRecommendationRepository.getSampleProduceImageBytes();
      expect(sampleImageBytes.isNotEmpty, true);
    });

    tearDownAll(() {
      ApiService.overrideBaseUrl = null;
    });

    setUp(() {
      HttpOverrides.global = null;
    });

    test('1. Verify live FastAPI backend /health is running and returns HTTP 200', () async {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('http://127.0.0.1:8000/health'));
      final response = await request.close();
      expect(response.statusCode, 200);
      client.close();
    }, skip: !isBackendAvailable ? 'FastAPI backend is not running at http://127.0.0.1:8000' : null);

    test('2. Potato Flow (STEP 5E): calls real FastAPI backend, returns ml_model prediction', () async {
      final repo = ApiRecommendationRepository(
        apiService: ApiService(),
        inputs: {
          'crop': 'Potato',
          'area_ha': 5.0,
          'state_name': 'Andhra Pradesh',
          'dist_name': 'Guntur',
          'latitude': 16.3067,
          'longitude': 80.4365,
          'year': 2020,
          'season': 'Rabi',
          'rainfall_mm': 850.0,
          'temperature_c': 22.0,
          'max_temperature': 28.0,
          'min_temperature': 16.0,
          'humidity_percent': 70.0,
          'ph': 7.0,
          'wind_speed_m_s': 3.0,
          'solar_radiation_mj_m2_day': 18.0,
        },
        imageBytes: sampleImageBytes,
      );

      final response = await repo.getRecommendation();

      // Verify real ML model output
      expect(response.supply.commodity, 'Potato');
      expect(response.supply.predictionSource, 'ml_model');
      expect(response.supply.isDemoPrediction, false);
      expect(response.supply.farmAreaHa, 5.0);
      expect(response.supply.expectedSupplyKg, closeTo(38950.5, 1.0));
      expect(response.markets.length, 2);

      // Verify routing, transport, spoilage, price, demand, decision are present
      for (final m in response.markets) {
        expect(m.route.distanceKm, greaterThanOrEqualTo(0));
        expect(m.transport.transportCost, greaterThan(0));
        expect(m.spoilage.spoilagePercentage, greaterThan(0));
        expect(m.price.predictedPricePerKg, greaterThan(0));
        expect(m.demand.demandKg, greaterThan(0));
        expect(m.decision.netRevenue, isNotNull);
      }

      expect(response.recommendedMarket.market, isNotEmpty);
      expect(response.recommendedMarket.buyerName, isNotEmpty);
    }, skip: !isBackendAvailable ? 'FastAPI backend is not running at http://127.0.0.1:8000' : null);

    testWidgets('3. Potato Flow: RecommendationScreen renders real API response with ML Prediction badge', (WidgetTester tester) async {
      HttpOverrides.global = null;
      final repo = ApiRecommendationRepository(
        apiService: ApiService(),
        inputs: {
          'crop': 'Potato',
          'area_ha': 5.0,
          'state_name': 'Andhra Pradesh',
          'dist_name': 'Guntur',
          'latitude': 16.3067,
          'longitude': 80.4365,
          'year': 2020,
          'season': 'Rabi',
          'rainfall_mm': 850.0,
          'temperature_c': 22.0,
          'max_temperature': 28.0,
          'min_temperature': 16.0,
        },
        imageBytes: sampleImageBytes,
      );

      final realResponse = (await tester.runAsync(() => repo.getRecommendation()))!;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: RecommendationScreen(recommendationData: realResponse),
        ),
      );

      await tester.pumpAndSettle();

      // Verify ML Prediction badge is rendered
      expect(find.text('ML Prediction'), findsOneWidget);
      expect(find.text('Potato'), findsOneWidget);
      expect(find.text('5 ha'), findsOneWidget);
      expect(find.text(realResponse.recommendedMarket.market), findsWidgets);
      expect(find.text(realResponse.recommendedMarket.buyerName), findsWidgets);
    }, skip: !isBackendAvailable);

    test('4. Tomato Flow (STEP 5E): calls real FastAPI backend, returns demo_fallback prediction', () async {
      final repo = ApiRecommendationRepository(
        apiService: ApiService(),
        inputs: {
          'crop': 'Tomato',
          'area_ha': 2.5,
          'state_name': 'Andhra Pradesh',
          'dist_name': 'Guntur',
          'latitude': 16.3067,
          'longitude': 80.4365,
          'year': 2024,
          'season': 'Rabi',
          'rainfall_mm': 850.0,
          'temperature_c': 28.0,
        },
        imageBytes: sampleImageBytes,
      );

      final response = await repo.getRecommendation();

      // Verify demo fallback output
      expect(response.supply.commodity, 'Tomato');
      expect(response.supply.predictionSource, 'demo_fallback');
      expect(response.supply.isDemoPrediction, true);
      expect(response.supply.farmAreaHa, 2.5);
      expect(response.supply.expectedSupplyKg, closeTo(50000.0, 1.0));
      expect(response.markets.length, 2);
    }, skip: !isBackendAvailable);

    testWidgets('5. Tomato Flow: RecommendationScreen renders real API response with Demo Estimate badge', (WidgetTester tester) async {
      HttpOverrides.global = null;
      final repo = ApiRecommendationRepository(
        apiService: ApiService(),
        inputs: {
          'crop': 'Tomato',
          'area_ha': 2.5,
          'state_name': 'Andhra Pradesh',
          'dist_name': 'Guntur',
          'latitude': 16.3067,
          'longitude': 80.4365,
          'year': 2024,
          'season': 'Rabi',
          'rainfall_mm': 850.0,
          'temperature_c': 28.0,
        },
        imageBytes: sampleImageBytes,
      );

      final realResponse = (await tester.runAsync(() => repo.getRecommendation()))!;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: RecommendationScreen(recommendationData: realResponse),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Demo Estimate badge is rendered
      expect(find.text('Demo Estimate'), findsOneWidget);
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('2.5 ha'), findsOneWidget);
    }, skip: !isBackendAvailable);
  });
}
