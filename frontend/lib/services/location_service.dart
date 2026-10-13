import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Categorized location error types for localized, user-friendly display.
enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unknown,
}

/// A structured result representing either successful coordinates or a typed failure.
class LocationResult {
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final bool isSuccess;
  final LocationErrorType? errorType;
  final String? technicalError;

  const LocationResult.success({
    required double this.latitude,
    required double this.longitude,
    this.accuracy,
  })  : isSuccess = true,
        errorType = null,
        technicalError = null;

  const LocationResult.failure({
    required LocationErrorType this.errorType,
    this.technicalError,
  })  : isSuccess = false,
        latitude = null,
        longitude = null,
        accuracy = null;
}

class LocationService {
  /// In-memory cache for location coordinates across screens and steps
  static double? cachedLatitude;
  static double? cachedLongitude;
  static double? cachedAccuracy;

  /// Requests permission if needed, checks service status, and gets current coordinates.
  /// Never returns mock or hard-coded coordinates.
  Future<LocationResult> getCurrentLocation() async {
    try {
      // 1. Check whether location service is enabled on the device / browser
      if (!kIsWeb) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return const LocationResult.failure(
            errorType: LocationErrorType.serviceDisabled,
          );
        }
      }

      // 2. Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult.failure(
            errorType: LocationErrorType.permissionDenied,
          );
        }
      }

      if (!kIsWeb && permission == LocationPermission.deniedForever) {
        return const LocationResult.failure(
          errorType: LocationErrorType.permissionDeniedForever,
        );
      }

      // 3. Obtain current position with fallback for accuracy (desktop browser may lack GNSS hardware)
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('High accuracy location failed, trying medium accuracy: $e');
        }
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 8),
            ),
          );
        } catch (e2) {
          if (kDebugMode) {
            debugPrint('Medium accuracy location failed, trying low accuracy: $e2');
          }
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 8),
            ),
          );
        }
      }

      // Cache obtained location
      cachedLatitude = position.latitude;
      cachedLongitude = position.longitude;
      cachedAccuracy = position.accuracy;

      return LocationResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('Location request timed out: $e');
      }
      if (cachedLatitude != null && cachedLongitude != null) {
        return LocationResult.success(
          latitude: cachedLatitude!,
          longitude: cachedLongitude!,
          accuracy: cachedAccuracy,
        );
      }
      return LocationResult.failure(
        errorType: LocationErrorType.timeout,
        technicalError: e.toString(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Location retrieval error: $e');
      }
      if (cachedLatitude != null && cachedLongitude != null) {
        return LocationResult.success(
          latitude: cachedLatitude!,
          longitude: cachedLongitude!,
          accuracy: cachedAccuracy,
        );
      }
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('denied')) {
        return LocationResult.failure(
          errorType: LocationErrorType.permissionDenied,
          technicalError: e.toString(),
        );
      }
      return LocationResult.failure(
        errorType: LocationErrorType.unknown,
        technicalError: e.toString(),
      );
    }
  }

  /// Helper to open app settings if permission was permanently denied.
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  /// Helper to open device location settings if location service is disabled.
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }
}
