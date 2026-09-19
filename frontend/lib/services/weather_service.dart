import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Structured representation of weather data obtained from Open-Meteo.
class WeatherData {
  /// Current temperature in Celsius (°C)
  final double temperature;

  /// Relative humidity percentage (%)
  final double humidity;

  /// Current precipitation / rainfall in millimeters (mm)
  final double rainfall;

  /// Wind speed in kilometers per hour (km/h)
  final double windSpeed;

  const WeatherData({
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.windSpeed,
  });

  /// Safely parses JSON response from Open-Meteo API.
  /// Returns null if required data or fields are missing, invalid, or malformed.
  static WeatherData? fromJson(Map<String, dynamic> json) {
    try {
      if (!json.containsKey('current') || json['current'] is! Map<String, dynamic>) {
        return null;
      }
      final current = json['current'] as Map<String, dynamic>;

      final temp = _toDouble(current['temperature_2m'] ?? current['temperature']);
      final humidity = _toDouble(
        current['relative_humidity_2m'] ??
            current['relativehumidity_2m'] ??
            current['humidity'],
      );
      final rainfall = _toDouble(
        current['precipitation'] ?? current['rain'],
      );
      final windSpeed = _toDouble(
        current['wind_speed_10m'] ?? current['windspeed_10m'] ?? current['windspeed'],
      );

      if (temp == null || humidity == null || rainfall == null || windSpeed == null) {
        return null;
      }

      return WeatherData(
        temperature: temp,
        humidity: humidity,
        rainfall: rainfall,
        windSpeed: windSpeed,
      );
    } catch (_) {
      return null;
    }
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  @override
  String toString() =>
      'WeatherData(temperature: $temperature°C, humidity: $humidity%, rainfall: ${rainfall}mm, windSpeed: ${windSpeed}km/h)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherData &&
          runtimeType == other.runtimeType &&
          temperature == other.temperature &&
          humidity == other.humidity &&
          rainfall == other.rainfall &&
          windSpeed == other.windSpeed;

  @override
  int get hashCode =>
      temperature.hashCode ^
      humidity.hashCode ^
      rainfall.hashCode ^
      windSpeed.hashCode;
}

/// Weather service interfacing with Open-Meteo non-commercial Weather API.
/// Retrieves temperature, relative humidity, precipitation, and wind speed
/// based on latitude and longitude coordinates.
class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches the current weather for the provided coordinates.
  /// Uses Open-Meteo API over HTTPS with standard 10-second timeout.
  /// Returns [WeatherData] if successful, or null on timeout, network error, or invalid payload.
  Future<WeatherData?> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m'
        '&wind_speed_unit=kmh',
      );

      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return WeatherData.fromJson(decoded);
        }
      } else {
        if (kDebugMode) {
          debugPrint('[WeatherService] HTTP error: ${response.statusCode}');
        }
      }
      return null;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('[WeatherService] Timeout error: $e');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WeatherService] Error: $e');
      }
      return null;
    }
  }
}
