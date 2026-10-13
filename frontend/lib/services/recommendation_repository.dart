import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import '../models/recommendation_model.dart';
import 'api_service.dart';

/// Abstract contract for recommendation repository.
/// Allows swapping MockRecommendationRepository with ApiRecommendationRepository
/// without any UI redesign.
abstract class RecommendationRepository {
  Future<RecommendationResponse> getRecommendation({Map<String, dynamic>? inputs});
}

/// Mock implementation providing deterministic sample data for UI development.
class MockRecommendationRepository implements RecommendationRepository {
  final Duration delay;

  const MockRecommendationRepository({this.delay = Duration.zero});

  @override
  Future<RecommendationResponse> getRecommendation({Map<String, dynamic>? inputs}) async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    return RecommendationResponse.mockSample;
  }
}

/// Real API implementation that transforms farmer inputs into FastAPI payload,
/// attaches the produce image, calls ApiService, and parses the response.
class ApiRecommendationRepository implements RecommendationRepository {
  final ApiService _apiService;
  final Map<String, dynamic>? _defaultInputs;
  final Uint8List? _imageBytes;

  ApiRecommendationRepository({
    ApiService? apiService,
    Map<String, dynamic>? inputs,
    Uint8List? imageBytes,
  })  : _apiService = apiService ?? ApiService(),
        _defaultInputs = inputs,
        _imageBytes = imageBytes;

  /// Helper to build the nested FastAPI request payload from farmer inputs
  static Map<String, dynamic> buildPayload({
    required String crop,
    required double areaHa,
    required String stateName,
    required String distName,
    required double latitude,
    required double longitude,
    required int year,
    String season = 'Whole Year',
    double nReqKgPerHa = 0.0,
    double pReqKgPerHa = 0.0,
    double kReqKgPerHa = 0.0,
    double temperatureC = 0.0,
    double humidityPercent = 0.0,
    double ph = 7.0,
    double rainfallMm = 0.0,
    double windSpeedMS = 0.0,
    double solarRadiation = 0.0,
    double? maxTemperature,
    double? minTemperature,
    double? fertilizer,
    double? pesticide,
  }) {
    final supplyMap = <String, dynamic>{
      'state_name': stateName,
      'dist_name': distName,
      'crop': crop,
      'area_ha': areaHa,
      'year': year,
      'season': season,
      'n_req_kg_per_ha': nReqKgPerHa,
      'p_req_kg_per_ha': pReqKgPerHa,
      'k_req_kg_per_ha': kReqKgPerHa,
      'temperature_c': temperatureC,
      'humidity_percent': humidityPercent,
      'ph': ph,
      'rainfall_mm': rainfallMm,
      'wind_speed_m_s': windSpeedMS,
      'solar_radiation_mj_m2_day': solarRadiation,
    };
    if (maxTemperature != null) supplyMap['max_temperature'] = maxTemperature;
    if (minTemperature != null) supplyMap['min_temperature'] = minTemperature;
    if (fertilizer != null) supplyMap['fertilizer'] = fertilizer;
    if (pesticide != null) supplyMap['pesticide'] = pesticide;

    return {
      'price_unit': 'INR/kg',
      'supply': supplyMap,
      'farmer_location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'spoilage': {
        'shelf_life_hours': 72.0,
        'temperature_c': temperatureC,
        'humidity_percent': humidityPercent,
      },
      'markets': [
        {
          'market': 'Guntur Market',
          'buyer_name': 'Buyer A',
          'latitude': 16.3000,
          'longitude': 80.4500,
          'price_unit': 'INR/kg',
          'price': {
            'State': stateName,
            'District': distName,
            'Market': 'Guntur',
            'Commodity': crop,
            'Variety': 'Common',
            'Grade': 'FAQ',
            'Date': '2025-04-16',
            'Min_Price': 2000.0,
            'Max_Price': 2600.0,
            'Modal_Price': 2300.0,
            'Previous_Price': 2250.0,
            'Rolling_Mean_3': 2280.0,
            'Rolling_Mean_7': 2300.0,
            'Commodity_Code': 82,
          },
          'demand': {
            'commodity': crop,
            'demand_kg': 5000.0,
            'buyer_capacity_kg': 30000.0,
            'current_supply_kg': 2000.0,
          },
          'transport': {
            'cost_per_km': 30.0,
          },
          'shelf_life_hours': 72.0,
          'temperature_c': temperatureC,
          'humidity_percent': humidityPercent,
        },
        {
          'market': 'Vijayawada Market',
          'buyer_name': 'Buyer B',
          'latitude': 16.5193,
          'longitude': 80.6305,
          'price_unit': 'INR/kg',
          'price': {
            'State': stateName,
            'District': 'Krishna',
            'Market': 'Vijayawada',
            'Commodity': crop,
            'Variety': 'Common',
            'Grade': 'FAQ',
            'Date': '2025-04-16',
            'Min_Price': 2100.0,
            'Max_Price': 2700.0,
            'Modal_Price': 2400.0,
            'Previous_Price': 2350.0,
            'Rolling_Mean_3': 2380.0,
            'Rolling_Mean_7': 2400.0,
            'Commodity_Code': 82,
          },
          'demand': {
            'commodity': crop,
            'demand_kg': 6000.0,
            'buyer_capacity_kg': 30000.0,
            'current_supply_kg': 2000.0,
          },
          'transport': {
            'cost_per_km': 30.0,
          },
          'shelf_life_hours': 72.0,
          'temperature_c': temperatureC,
          'humidity_percent': humidityPercent,
        },
      ],
    };
  }

  /// Helper to convert a flat or nested input map into the nested FastAPI payload
  static Map<String, dynamic> buildPayloadFromInputMap(Map<String, dynamic> map) {
    if (map.containsKey('supply') && map.containsKey('farmer_location')) {
      return map;
    }
    return buildPayload(
      crop: map['crop']?.toString() ?? 'Tomato',
      areaHa: (map['area_ha'] is num)
          ? (map['area_ha'] as num).toDouble()
          : (double.tryParse(map['area_ha']?.toString() ?? '') ?? 1.0),
      stateName: map['state_name']?.toString() ?? 'Andhra Pradesh',
      distName: map['dist_name']?.toString() ?? 'Guntur',
      latitude: (map['latitude'] is num)
          ? (map['latitude'] as num).toDouble()
          : (double.tryParse(map['latitude']?.toString() ?? '') ?? 16.3067),
      longitude: (map['longitude'] is num)
          ? (map['longitude'] as num).toDouble()
          : (double.tryParse(map['longitude']?.toString() ?? '') ?? 80.4365),
      year: (map['year'] is int)
          ? (map['year'] as int)
          : (int.tryParse(map['year']?.toString() ?? '') ?? DateTime.now().year),
      season: map['season']?.toString() ?? 'Whole Year',
      nReqKgPerHa: (map['n_req_kg_per_ha'] is num)
          ? (map['n_req_kg_per_ha'] as num).toDouble()
          : (double.tryParse(map['n_req_kg_per_ha']?.toString() ?? '') ?? 0.0),
      pReqKgPerHa: (map['p_req_kg_per_ha'] is num)
          ? (map['p_req_kg_per_ha'] as num).toDouble()
          : (double.tryParse(map['p_req_kg_per_ha']?.toString() ?? '') ?? 0.0),
      kReqKgPerHa: (map['k_req_kg_per_ha'] is num)
          ? (map['k_req_kg_per_ha'] as num).toDouble()
          : (double.tryParse(map['k_req_kg_per_ha']?.toString() ?? '') ?? 0.0),
      temperatureC: (map['temperature_c'] is num)
          ? (map['temperature_c'] as num).toDouble()
          : (double.tryParse(map['temperature_c']?.toString() ?? '') ?? 28.0),
      humidityPercent: (map['humidity_percent'] is num)
          ? (map['humidity_percent'] as num).toDouble()
          : (double.tryParse(map['humidity_percent']?.toString() ?? '') ?? 70.0),
      ph: (map['ph'] is num)
          ? (map['ph'] as num).toDouble()
          : (double.tryParse(map['ph']?.toString() ?? '') ?? 7.0),
      rainfallMm: (map['rainfall_mm'] is num)
          ? (map['rainfall_mm'] as num).toDouble()
          : (double.tryParse(map['rainfall_mm']?.toString() ?? '') ?? 0.0),
      windSpeedMS: (map['wind_speed_m_s'] is num)
          ? (map['wind_speed_m_s'] as num).toDouble()
          : (double.tryParse(map['wind_speed_m_s']?.toString() ?? '') ?? 0.0),
      solarRadiation: (map['solar_radiation_mj_m2_day'] is num)
          ? (map['solar_radiation_mj_m2_day'] as num).toDouble()
          : (double.tryParse(map['solar_radiation_mj_m2_day']?.toString() ?? '') ?? 0.0),
      maxTemperature: (map['max_temperature'] is num)
          ? (map['max_temperature'] as num).toDouble()
          : (double.tryParse(map['max_temperature']?.toString() ?? '') ??
              double.tryParse(map['max_temp_c']?.toString() ?? '')),
      minTemperature: (map['min_temperature'] is num)
          ? (map['min_temperature'] as num).toDouble()
          : (double.tryParse(map['min_temperature']?.toString() ?? '') ??
              double.tryParse(map['min_temp_c']?.toString() ?? '')),
      fertilizer: (map['fertilizer'] is num)
          ? (map['fertilizer'] as num).toDouble()
          : (double.tryParse(map['fertilizer']?.toString() ?? '') ??
              double.tryParse(map['fertilizer_total_kg']?.toString() ?? '')),
      pesticide: (map['pesticide'] is num)
          ? (map['pesticide'] as num).toDouble()
          : (double.tryParse(map['pesticide']?.toString() ?? '') ??
              double.tryParse(map['pesticide_total_kg']?.toString() ?? '')),
    );
  }

  /// Retrieves asset sample produce image as in-memory Uint8List bytes
  static Future<Uint8List> getSampleProduceImageBytes() async {
    try {
      final byteData = await rootBundle.load(
        'assets/images/sample_produce.jpg',
      );

      return byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
    } catch (_) {
      // Fallback: minimal valid JPEG bytes if asset loading is unavailable (e.g. headless unit tests)
      return Uint8List.fromList(const [
        0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
        0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
        0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
        0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
        0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
        0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
        0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
        0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01,
        0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x1F, 0x00, 0x00,
        0x01, 0x05, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x09, 0x0A, 0x0B, 0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3F,
        0x00, 0xBF, 0x00, 0xFF, 0xD9,
      ]);
    }
  }

  @override
  Future<RecommendationResponse> getRecommendation({Map<String, dynamic>? inputs}) async {
    final effectiveInputs = inputs ?? _defaultInputs ?? {};
    final payload = buildPayloadFromInputMap(effectiveInputs);
    final imageBytes = _imageBytes ?? await getSampleProduceImageBytes();

    final responseMap = await _apiService.getRecommendation(
      data: payload,
      imageBytes: imageBytes,
    );

    return RecommendationResponse.fromJson(responseMap);
  }
}
