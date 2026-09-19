import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/weather_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('WeatherService Unit Tests', () {
    const double testLat = 16.3067;
    const double testLon = 80.4365;

    test('1. Successful JSON parsing with valid Open-Meteo response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.scheme, 'https');
        expect(request.url.host, 'api.open-meteo.com');
        expect(request.url.path, '/v1/forecast');
        expect(request.url.queryParameters['latitude'], testLat.toString());
        expect(request.url.queryParameters['longitude'], testLon.toString());
        expect(request.url.queryParameters['wind_speed_unit'], 'kmh');
        expect(
          request.url.queryParameters['current'],
          'temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m',
        );

        final samplePayload = {
          'latitude': 16.31,
          'longitude': 80.44,
          'current_units': {
            'temperature_2m': '°C',
            'relative_humidity_2m': '%',
            'precipitation': 'mm',
            'wind_speed_10m': 'km/h',
          },
          'current': {
            'time': '2026-09-19T01:30',
            'temperature_2m': 28.4,
            'relative_humidity_2m': 72,
            'precipitation': 0.4,
            'wind_speed_10m': 8.0,
          },
        };

        return http.Response(
          jsonEncode(samplePayload),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = WeatherService(client: mockClient);
      final weather = await service.getWeather(latitude: testLat, longitude: testLon);

      expect(weather, isNotNull);
      expect(weather!.temperature, 28.4);
      expect(weather.humidity, 72.0);
      expect(weather.rainfall, 0.4);
      expect(weather.windSpeed, 8.0);
    });

    test('2. Missing fields in JSON returns null safely without throwing', () async {
      // Test missing 'current' object
      final noCurrentClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'latitude': 16.31, 'longitude': 80.44}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final noCurrentService = WeatherService(client: noCurrentClient);
      final result1 = await noCurrentService.getWeather(latitude: testLat, longitude: testLon);
      expect(result1, isNull);

      // Test missing individual required fields (temperature missing)
      final missingTempClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'current': {
              'relative_humidity_2m': 70,
              'precipitation': 1.2,
              'wind_speed_10m': 12.0,
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final missingTempService = WeatherService(client: missingTempClient);
      final result2 = await missingTempService.getWeather(latitude: testLat, longitude: testLon);
      expect(result2, isNull);

      // Test missing precipitation
      final missingPrecipClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'current': {
              'temperature_2m': 30.0,
              'relative_humidity_2m': 65,
              'wind_speed_10m': 5.0,
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final missingPrecipService = WeatherService(client: missingPrecipClient);
      final result3 = await missingPrecipService.getWeather(latitude: testLat, longitude: testLon);
      expect(result3, isNull);
    });

    test('3. Malformed JSON returns null gracefully without crashing', () async {
      final malformedClient = MockClient((request) async {
        return http.Response('<!DOCTYPE html><html><body>Invalid JSON</body></html>', 200);
      });

      final service = WeatherService(client: malformedClient);
      final weather = await service.getWeather(latitude: testLat, longitude: testLon);

      expect(weather, isNull);
    });

    test('4. HTTP errors (400, 404, 500) return null gracefully', () async {
      for (final statusCode in [400, 404, 500, 502]) {
        final errorClient = MockClient((request) async {
          return http.Response('Server Error', statusCode);
        });

        final service = WeatherService(client: errorClient);
        final weather = await service.getWeather(latitude: testLat, longitude: testLon);

        expect(weather, isNull);
      }
    });

    test('5. Network/timeout error returns null gracefully without crashing', () async {
      final timeoutClient = MockClient((request) async {
        throw TimeoutException('Connection timed out');
      });

      final timeoutService = WeatherService(client: timeoutClient);
      final weatherTimeout = await timeoutService.getWeather(latitude: testLat, longitude: testLon);
      expect(weatherTimeout, isNull);

      final socketErrorClient = MockClient((request) async {
        throw http.ClientException('Failed to connect to host');
      });

      final socketService = WeatherService(client: socketErrorClient);
      final weatherSocket = await socketService.getWeather(latitude: testLat, longitude: testLon);
      expect(weatherSocket, isNull);
    });

    test('6. WeatherData model supports fallback property names and string numbers', () {
      final fallbackJson = {
        'current': {
          'temperature': '25.5',
          'humidity': '80',
          'rain': '2.5',
          'windspeed': '14.2',
        }
      };

      final parsed = WeatherData.fromJson(fallbackJson);
      expect(parsed, isNotNull);
      expect(parsed!.temperature, 25.5);
      expect(parsed.humidity, 80.0);
      expect(parsed.rainfall, 2.5);
      expect(parsed.windSpeed, 14.2);
    });
  });
}
