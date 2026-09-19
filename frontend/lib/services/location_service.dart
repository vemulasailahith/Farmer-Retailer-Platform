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
  /// Requests permission if needed, checks service status, and gets current coordinates.
  /// Never returns mock or hard-coded coordinates.
  Future<LocationResult> getCurrentLocation() async {
    try {
      // 1. Check whether location service is enabled on the device / browser
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult.failure(
          errorType: LocationErrorType.serviceDisabled,
        );
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

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.failure(
          errorType: LocationErrorType.permissionDeniedForever,
        );
      }

      // 3. Obtain current position with 15-second timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      return LocationResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('Location request timed out: $e');
      }
      return LocationResult.failure(
        errorType: LocationErrorType.timeout,
        technicalError: e.toString(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Location retrieval error: $e');
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
