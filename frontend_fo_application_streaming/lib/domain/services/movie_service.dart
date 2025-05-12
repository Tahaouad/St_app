import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MovieService {
  static const String _baseUrl = 'http://localhost:5000/api/movies';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<Map<String, dynamic>> getFeaturedMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/featured'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to load featured movies'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getPopularMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/popular'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to load popular movies'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$movieId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to load movie details'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
