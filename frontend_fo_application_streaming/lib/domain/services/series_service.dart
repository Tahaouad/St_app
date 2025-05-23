import 'dart:convert';
import 'package:http/http.dart' as http;

class SeriesService {
  static const String baseUrl = 'http://localhost:5000/api';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>> getSeries({
    int? categoryId,
    int? genreId,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'type': 'tv',
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        final response = await http.get(
          Uri.parse('$baseUrl/content/search').replace(queryParameters: {
            'query': search,
            'page': '1',
          }),
          headers: _headers,
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final series = (data['results'] as List)
              .where((item) => item['media_type'] == 'tv')
              .toList();
          return {
            'success': true,
            'data': {'rows': series}
          };
        }
      } else {
        final response = await http.get(
          Uri.parse('$baseUrl/content/popular')
              .replace(queryParameters: queryParams),
          headers: _headers,
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return {
            'success': true,
            'data': {'rows': data['results']}
          };
        }
      }

      return {'success': false, 'message': 'Erreur de chargement'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
    }
  }

  Future<Map<String, dynamic>> getFeaturedSeries() async {
    return await getTopRatedSeries();
  }

  Future<Map<String, dynamic>> getPopularSeries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/content/popular').replace(queryParameters: {
          'type': 'tv',
          'page': '1',
        }),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['results']};
      }

      return {'success': false, 'message': 'Erreur de chargement'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
    }
  }

  Future<Map<String, dynamic>> getTopRatedSeries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/content/top-rated').replace(queryParameters: {
          'type': 'tv',
          'page': '1',
        }),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['results']};
      }

      return {'success': false, 'message': 'Erreur de chargement'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
    }
  }

  Future<Map<String, dynamic>> getSeriesDetails(int seriesId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/content/tv/$seriesId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      }

      return {'success': false, 'message': 'Série non trouvée'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
    }
  }

  Future<Map<String, dynamic>> getSeasonDetails(
      int seriesId, int seasonNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/content/tv/$seriesId/season/$seasonNumber'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      }

      return {'success': false, 'message': 'Saison non trouvée'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
    }
  }
}
