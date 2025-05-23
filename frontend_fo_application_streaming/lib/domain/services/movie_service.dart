import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieService {
  static const String baseUrl = 'http://localhost:5000/api';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>> getMovies({
    int? categoryId,
    int? genreId,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'type': 'movie',
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
          final movies = (data['results'] as List)
              .where((item) => item['media_type'] == 'movie')
              .toList();
          return {
            'success': true,
            'data': {'rows': movies}
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

  Future<Map<String, dynamic>> getFeaturedMovies() async {
    return await getTopRatedMovies();
  }

  Future<Map<String, dynamic>> getPopularMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/content/popular').replace(queryParameters: {
          'type': 'movie',
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

  Future<Map<String, dynamic>> getTopRatedMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/content/top-rated').replace(queryParameters: {
          'type': 'movie',
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

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/content/movie/$movieId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      }

      return {'success': false, 'message': 'Film non trouvé'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
    }
  }

  Future<Map<String, dynamic>> getRelatedMovies(int movieId) async {
    return await getPopularMovies();
  }
}
