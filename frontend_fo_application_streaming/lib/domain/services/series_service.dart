import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SeriesService {
  static const String _baseUrl = 'http://localhost:5000/api/series';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  // Obtenir toutes les séries avec filtres
  Future<Map<String, dynamic>> getSeries({
    int? categoryId,
    int? genreId,
    String? search,
    int limit = 10,
    int offset = 0,
    String sortBy = 'createdAt',
    String order = 'DESC',
  }) async {
    try {
      final params = {
        if (categoryId != null) 'categoryId': categoryId.toString(),
        if (genreId != null) 'genreId': genreId.toString(),
        if (search != null) 'search': search,
        'limit': limit.toString(),
        'offset': offset.toString(),
        'sortBy': sortBy,
        'order': order,
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to load series'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
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

  Future<Map<String, dynamic>> getSeasonDetails(
    int seriesId,
    int seasonId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$seriesId/seasons/$seasonId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to load season details'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getEpisodeDetails(
    int seriesId,
    int seasonId,
    int episodeId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$seriesId/seasons/$seasonId/episodes/$episodeId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to load episode details'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
