import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/reverse_geocoding_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ReverseGeocodingService', () {
    test('successfully parses village, district, state from Nominatim JSON', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'address': {
              'village': 'Brodipet',
              'state_district': 'Guntur',
              'state': 'Andhra Pradesh',
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ReverseGeocodingService(client: mockClient);
      final details = await service.reverseGeocode(
        latitude: 16.3067,
        longitude: 80.4365,
      );

      expect(details, isNotNull);
      expect(details!.village, 'Brodipet');
      expect(details.district, 'Guntur');
      expect(details.state, 'Andhra Pradesh');
    });

    test('falls back to town/county when village/state_district not present', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'address': {
              'town': 'Narasaraopeta',
              'county': 'Palnadu',
              'state': 'Andhra Pradesh',
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ReverseGeocodingService(client: mockClient);
      final details = await service.reverseGeocode(
        latitude: 16.2160,
        longitude: 80.0400,
      );

      expect(details, isNotNull);
      expect(details!.village, 'Narasaraopeta');
      expect(details.district, 'Palnadu');
      expect(details.state, 'Andhra Pradesh');
    });

    test('returns null gracefully on network failure or 500 error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = ReverseGeocodingService(client: mockClient);
      final details = await service.reverseGeocode(
        latitude: 16.2160,
        longitude: 80.0400,
      );

      expect(details, isNull);
    });
  });
}
