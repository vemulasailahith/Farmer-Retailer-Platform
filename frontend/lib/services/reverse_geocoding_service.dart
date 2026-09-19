import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Structured representation of address details obtained from reverse geocoding.
class AddressDetails {
  final String? village;
  final String? district;
  final String? state;

  const AddressDetails({
    this.village,
    this.district,
    this.state,
  });

  bool get isEmpty =>
      (village == null || village!.trim().isEmpty) &&
      (district == null || district!.trim().isEmpty) &&
      (state == null || state!.trim().isEmpty);
}

/// Reverse geocoding service using OpenStreetMap Nominatim.
/// Works consistently across Web, Android, iOS, and Desktop with zero native plugin conflicts.
class ReverseGeocodingService {
  final http.Client _client;

  ReverseGeocodingService({http.Client? client}) : _client = client ?? http.Client();

  /// Queries OpenStreetMap Nominatim for the given coordinates.
  /// Never throws an exception; returns null on network timeout, parsing error, or failure.
  Future<AddressDetails?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=$latitude&lon=$longitude&format=jsonv2&addressdetails=1',
      );

      final response = await _client.get(
        uri,
        headers: {
          'User-Agent': 'YarinFarmToMarket/1.0 (contact: support@yarin.app)',
          'Accept': 'application/json',
          'Accept-Language': 'en',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('address')) {
          final address = decoded['address'] as Map<String, dynamic>;

          // Priority for village/locality: village -> hamlet -> town -> suburb -> neighbourhood -> city
          final village = address['village'] ??
              address['hamlet'] ??
              address['town'] ??
              address['suburb'] ??
              address['neighbourhood'] ??
              address['city_district'] ??
              address['city'];

          // Priority for district: state_district -> county -> district
          final district = address['state_district'] ??
              address['county'] ??
              address['district'];

          final state = address['state'];

          final result = AddressDetails(
            village: village?.toString().trim(),
            district: district?.toString().trim(),
            state: state?.toString().trim(),
          );

          if (!result.isEmpty) {
            return result;
          }
        }
      }
      return null;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('[ReverseGeocodingService] Timeout: $e');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ReverseGeocodingService] Error: $e');
      }
      return null;
    }
  }
}
