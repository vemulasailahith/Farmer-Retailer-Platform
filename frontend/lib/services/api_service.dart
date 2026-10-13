import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Web-compatible exception for API HTTP failures (replaces dart:io HttpException)
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Uri? uri;

  ApiException(this.message, {this.statusCode, this.uri});

  @override
  String toString() => message;
}

class ApiService {
  static String? overrideBaseUrl;

  static String get baseUrl {
    if (overrideBaseUrl != null) return overrideBaseUrl!;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  Future<Map<String, dynamic>> getRecommendation({
    required Map<String, dynamic> data,
    required List<int> imageBytes,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/recommend');

    try {
      final request = http.MultipartRequest('POST', uri);

      // Add the recommendation JSON payload as a multipart form field named 'data'
      request.fields['data'] = jsonEncode(data);

      // Attach produce image as multipart file field named 'image'
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'produce.jpg',
      );
      request.files.add(multipartFile);

      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );

      final response = await http.Response.fromStream(streamedResponse);

      // Handle HTTP 200 OK
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        } else {
          throw FormatException(
            'Expected JSON object from API, but received ${decoded.runtimeType}.',
          );
        }
      }

      // Handle non-2xx responses using web-safe ApiException instead of dart:io HttpException
      throw ApiException(
        'Recommendation API failed with HTTP ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
        uri: uri,
      );
    } on TimeoutException catch (e) {
      throw TimeoutException(
        'Request to recommendation API timed out after 60 seconds: ${e.message}',
      );
    } on http.ClientException catch (e) {
      throw http.ClientException(
        'Network error connecting to recommendation API at $baseUrl: ${e.message}',
        uri,
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Unexpected error during recommendation request: $e');
    }
  }
}
