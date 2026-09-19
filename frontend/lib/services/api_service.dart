import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<Map<String, dynamic>> getRecommendation({
    required Map<String, dynamic> data,
    required File imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/recommend');

    try {
      final request = http.MultipartRequest('POST', uri);

      // Add the recommendation JSON payload as a multipart form field named 'data'
      request.fields['data'] = jsonEncode(data);

      // Attach produce image as multipart file field named 'image'
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
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

      // Handle non-2xx responses
      throw HttpException(
        'Recommendation API failed with HTTP ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    } on TimeoutException catch (e) {
      throw TimeoutException(
        'Request to recommendation API timed out after 60 seconds: ${e.message}',
      );
    } on SocketException catch (e) {
      throw SocketException(
        'Network error connecting to recommendation API at $baseUrl: ${e.message}',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'HTTP client error during recommendation request: ${e.message}',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Unexpected error during recommendation request: $e');
    }
  }
}
