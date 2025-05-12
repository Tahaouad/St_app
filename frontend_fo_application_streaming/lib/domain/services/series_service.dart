import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SeriesService {
  static const String _baseUrl = 'http://localhost:5000/api/series';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<Map<String, dynamic>> getFeaturedSeries() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/featured'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to load featured series'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getPopularSeries() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/popular'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to load popular series'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getSeriesDetails(int seriesId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$seriesId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to load series details'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
