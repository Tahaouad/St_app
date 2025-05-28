// lib/domain/services/streaming_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StreamingService {
  static const String baseUrl = 'http://localhost:5000/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Headers avec authentification
  Future<Map<String, String>> get _authHeaders async {
    final token = await _storage.read(key: 'auth_token');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Obtenir l'URL de streaming pour un film
  Future<Map<String, dynamic>> getMovieStreamUrl(int tmdbId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/content/stream/movie/$tmdbId'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ??
              'Erreur lors de la récupération de l\'URL de streaming',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  // Obtenir l'URL de streaming pour un épisode de série
  Future<Map<String, dynamic>> getEpisodeStreamUrl(
    int tmdbId,
    int season,
    int episode,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/content/stream/tv/$tmdbId').replace(
          queryParameters: {
            'season': season.toString(),
            'episode': episode.toString(),
          },
        ),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ??
              'Erreur lors de la récupération de l\'URL de streaming',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  // URLs alternatives de streaming (utilisées localement)
  static List<String> getAlternativeStreamUrls({
    required int tmdbId,
    required String mediaType,
    String? imdbId,
    int? season,
    int? episode,
  }) {
    final List<String> urls = [];

    // VidSrc avec différents domaines
    final vidsrcDomains = [
      'vidsrc.xyz',
      'vidsrc.cc',
      'vidsrc.in',
      'vidsrc.net'
    ];

    for (final domain in vidsrcDomains) {
      if (mediaType == 'movie') {
        if (imdbId != null) {
          urls.add('https://$domain/embed/movie?imdb=$imdbId');
        }
        urls.add('https://$domain/embed/movie?tmdb=$tmdbId');
      } else if (mediaType == 'tv' && season != null && episode != null) {
        if (imdbId != null) {
          urls.add(
              'https://$domain/embed/tv?imdb=$imdbId&season=$season&episode=$episode');
        }
        urls.add(
            'https://$domain/embed/tv?tmdb=$tmdbId&season=$season&episode=$episode');
      }
    }

    // Autres services
    if (mediaType == 'movie') {
      urls.add(
          'https://multiembed.mov/directstream.php?video_id=$tmdbId&tmdb=1');
      urls.add('https://www.2embed.cc/embed/$tmdbId');
    } else if (mediaType == 'tv' && season != null && episode != null) {
      urls.add(
          'https://multiembed.mov/directstream.php?video_id=$tmdbId&tmdb=1&s=$season&e=$episode');
      urls.add('https://www.2embed.cc/embed/tmdb/$tmdbId?s=$season&e=$episode');
    }

    return urls;
  }

  // Vérifier la disponibilité d'une URL
  static Future<bool> checkUrlAvailability(String url) async {
    try {
      final response = await http.head(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
          );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Construire une URL de streaming simple (fallback)
  static String buildStreamUrl({
    required int tmdbId,
    required String mediaType,
    String? imdbId,
    int? season,
    int? episode,
  }) {
    const domain = 'vidsrc.xyz';

    if (mediaType == 'movie') {
      if (imdbId != null) {
        return 'https://$domain/embed/movie?imdb=$imdbId';
      }
      return 'https://$domain/embed/movie?tmdb=$tmdbId';
    } else if (mediaType == 'tv' && season != null && episode != null) {
      if (imdbId != null) {
        return 'https://$domain/embed/tv?imdb=$imdbId&season=$season&episode=$episode';
      }
      return 'https://$domain/embed/tv?tmdb=$tmdbId&season=$season&episode=$episode';
    }

    throw ArgumentError('Invalid parameters for streaming URL');
  }
}

