
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/models/api_models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api'; // Votre backend
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Headers par défaut
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Headers avec authentification
  Future<Map<String, String>> get _authHeaders async {
    final token = await _storage.read(key: 'auth_token');
    final headers = Map<String, String>.from(_headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Gestion des erreurs HTTP
  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      Map<String, dynamic> errorData;
      try {
        errorData = json.decode(response.body);
      } catch (e) {
        errorData = {'message': 'Erreur de format de réponse'};
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: errorData['message'] ?? 'Une erreur est survenue',
        details: errorData,
      );
    }
  }

  // ==========================================
  // AUTHENTIFICATION (adaptée à votre backend)
  // ==========================================

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: _headers,
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      
      // Adaptation à votre structure de réponse
      final user = User.fromJson(data['user']);
      final authResponse = AuthResponse(
        token: 'dummy_token', // Votre backend ne retourne pas de token dans register
        user: user,
        message: data['message'],
      );

      // Après l'inscription, faire la connexion
      final loginRequest = LoginRequest(
        email: request.email,
        password: request.password,
      );
      return await login(loginRequest);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: _headers,
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      // Sauvegarder le token et les données utilisateur
      await _storage.write(key: 'auth_token', value: authResponse.token);
      await _storage.write(
          key: 'user_data', value: json.encode(authResponse.user.toJson()));

      return authResponse;
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/auth/me'),
            headers: await _authHeaders,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      final user = User.fromJson(data);

      // Mettre à jour les données utilisateur stockées
      await _storage.write(key: 'user_data', value: json.encode(user.toJson()));

      return user;
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  // ==========================================
  // CONTENU TMDB (adaptées à votre backend)
  // ==========================================

  Future<Map<String, dynamic>> search(String query, {int page = 1}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/content/search').replace(queryParameters: {
              'query': query,
              'page': page.toString(),
            }),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> getPopularMovies({int page = 1}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/content/popular').replace(queryParameters: {
              'type': 'movie',
              'page': page.toString(),
            }),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> getPopularTV({int page = 1}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/content/popular').replace(queryParameters: {
              'type': 'tv',
              'page': page.toString(),
            }),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> getTrending({
    String type = 'all',
    String time = 'day',
    int page = 1,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/content/trending').replace(queryParameters: {
              'type': type,
              'time': time,
              'page': page.toString(),
            }),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> getTopRated({
    String type = 'movie',
    int page = 1,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/content/top-rated').replace(queryParameters: {
              'type': type,
              'page': page.toString(),
            }),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> getUpcoming({int page = 1}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/content/upcoming').replace(queryParameters: {
              'page': page.toString(),
            }),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/content/movie/$movieId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> getTVDetails(int tvId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/content/tv/$tvId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> getSeasonDetails(int tvId, int seasonNumber) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/content/tv/$tvId/season/$seasonNumber'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> getEpisodeDetails(
      int tvId, int seasonNumber, int episodeNumber) async {
    try {
      final response = await http
          .get(
            Uri.parse(
                '$baseUrl/content/tv/$tvId/season/$seasonNumber/episode/$episodeNumber'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> getGenres({String type = 'movie'}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/content/genres').replace(queryParameters: {
              'type': type,
            }),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> discoverByGenre(
    int genreId, {
    String type = 'movie',
    int page = 1,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/content/genres/$genreId/discover')
                .replace(queryParameters: {
              'type': type,
              'page': page.toString(),
            }),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<StreamResponse> getStreamUrl(
    String type,
    int id, {
    int? season,
    int? episode,
    String? subtitleLang,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (season != null) queryParams['season'] = season.toString();
      if (episode != null) queryParams['episode'] = episode.toString();
      if (subtitleLang != null) queryParams['subtitle_lang'] = subtitleLang;

      final response = await http
          .get(
            Uri.parse('$baseUrl/content/stream/$type/$id')
                .replace(queryParameters: queryParams),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      return StreamResponse.fromJson(data);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  // ==========================================
  // WATCHLIST (adaptées à votre backend)
  // ==========================================

  Future<WatchlistResponse> getWatchlist({
    int page = 1,
    int limit = 20,
    String? mediaType,
    String? sortBy,
    String? order,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (mediaType != null) queryParams['mediaType'] = mediaType;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (order != null) queryParams['order'] = order;

      final response = await http
          .get(
            Uri.parse('$baseUrl/user/watchlist')
                .replace(queryParameters: queryParams),
            headers: await _authHeaders,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      return WatchlistResponse.fromJson(data);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<WatchlistItem> addToWatchlist(AddToWatchlistRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/user/watchlist'),
            headers: await _authHeaders,
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      return WatchlistItem.fromJson(data['item']);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<void> removeFromWatchlist(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/user/watchlist/$id'),
            headers: await _authHeaders,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<bool> checkInWatchlist(int tmdbId, String mediaType) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/user/watchlist/check')
                .replace(queryParameters: {
              'tmdbId': tmdbId.toString(),
              'mediaType': mediaType,
            }),
            headers: await _authHeaders,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      return data['inWatchlist'] as bool;
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  // ==========================================
  // RATINGS (adaptées à votre backend)
  // ==========================================

  Future<Rating> addRating(AddRatingRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/user/ratings'),
            headers: await _authHeaders,
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      return Rating.fromJson(data['rating']);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> getUserRatings({
    int page = 1,
    int limit = 20,
    String? mediaType,
    int? minRating,
    int? maxRating,
    String? sortBy,
    String? order,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (mediaType != null) queryParams['mediaType'] = mediaType;
      if (minRating != null) queryParams['minRating'] = minRating.toString();
      if (maxRating != null) queryParams['maxRating'] = maxRating.toString();
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (order != null) queryParams['order'] = order;

      final response = await http
          .get(
            Uri.parse('$baseUrl/user/ratings')
                .replace(queryParameters: queryParams),
            headers: await _authHeaders,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Rating?> getUserRating(
    int tmdbId,
    String mediaType, {
    int? seasonNumber,
    int? episodeNumber,
  }) async {
    try {
      final queryParams = <String, String>{
        'tmdbId': tmdbId.toString(),
        'mediaType': mediaType,
      };
      if (seasonNumber != null)
        queryParams['seasonNumber'] = seasonNumber.toString();
      if (episodeNumber != null)
        queryParams['episodeNumber'] = episodeNumber.toString();

      final response = await http
          .get(
            Uri.parse('$baseUrl/user/rating')
                .replace(queryParameters: queryParams),
            headers: await _authHeaders,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      return data['rating'] != null ? Rating.fromJson(data['rating']) : null;
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<void> deleteRating(int ratingId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/user/ratings/$ratingId'),
            headers: await _authHeaders,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  // ==========================================
  // WATCH HISTORY (adaptées à votre backend)
  // ==========================================

  Future<WatchHistoryItem> updateWatchHistory(
      UpdateWatchHistoryRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/user/history'),
            headers: await _authHeaders,
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      return WatchHistoryItem.fromJson(data['watchHistory']);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Map<String, dynamic>> getWatchHistory({
    int page = 1,
    int limit = 20,
    String? mediaType,
    bool? completed,
    String? sortBy,
    String? order,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (mediaType != null) queryParams['mediaType'] = mediaType;
      if (completed != null) queryParams['completed'] = completed.toString();
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (order != null) queryParams['order'] = order;

      final response = await http
          .get(
            Uri.parse('$baseUrl/user/history')
                .replace(queryParameters: queryParams),
            headers: await _authHeaders,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Map<String, dynamic>?> getWatchProgress(
    int tmdbId,
    String mediaType, {
    int? seasonNumber,
    int? episodeNumber,
  }) async {
    try {
      final queryParams = <String, String>{
        'tmdbId': tmdbId.toString(),
        'mediaType': mediaType,
      };
      if (seasonNumber != null)
        queryParams['seasonNumber'] = seasonNumber.toString();
      if (episodeNumber != null)
        queryParams['episodeNumber'] = episodeNumber.toString();

      final response = await http
          .get(
            Uri.parse('$baseUrl/user/progress')
                .replace(queryParameters: queryParams),
            headers: await _authHeaders,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      return data['progress'];
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<List<WatchHistoryItem>> getContinueWatching({int limit = 10}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/user/continue-watching')
                .replace(queryParameters: {
              'limit': limit.toString(),
            }),
            headers: await _authHeaders,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      return (data['items'] as List)
          .map((json) => WatchHistoryItem.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<void> clearWatchHistory(
      {String? mediaType, DateTime? beforeDate}) async {
    try {
      final body = <String, dynamic>{};
      if (mediaType != null) body['mediaType'] = mediaType;
      if (beforeDate != null) body['beforeDate'] = beforeDate.toIso8601String();

      final response = await http
          .post(
            Uri.parse('$baseUrl/user/history/clear'),
            headers: await _authHeaders,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  // ==========================================
  // USER STATS (adaptées à votre backend)
  // ==========================================

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/user/stats'),
            headers: await _authHeaders,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      return json.decode(response.body);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  // ==========================================
  // HEALTH CHECK
  // ==========================================

  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // UTILITY METHODS
  // ==========================================

  Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final userData = await _storage.read(key: 'user_data');
      if (userData != null && userData.isNotEmpty) {
        return User.fromJson(json.decode(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: 'auth_token');
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      // Supprimer toutes les données stockées
      await _storage.deleteAll();
    } catch (e) {
      // En cas d'erreur, on supprime quand même les données locales
      await _storage.deleteAll();
    }
  }

  Exception _handleNetworkError(dynamic error) {
    if (error is SocketException) {
      return NetworkException(
          'Problème de connexion internet. Vérifiez votre connexion.');
    } else if (error is http.ClientException) {
      return NetworkException(
          'Erreur de client HTTP. Vérifiez l\'URL du serveur.');
    } else if (error is ApiException) {
      return error;
    } else if (error.toString().contains('TimeoutException')) {
      return NetworkException(
          'Délai d\'attente dépassé. Le serveur ne répond pas.');
    } else {
      return ApiException(
        statusCode: 0,
        message: 'Une erreur inattendue est survenue',
        details: {'error': error.toString()},
      );
    }
  }

  // Helper pour construire des URLs d'images TMDB
  static String buildImageUrl(String? path, {String size = 'w500'}) {
    if (path == null || path.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/$size$path';
  }
}

// ==========================================
// EXCEPTIONS
// ==========================================

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? details;

  ApiException({
    required this.statusCode,
    required this.message,
    this.details,
  });

  bool get isAuthError => statusCode == 401 || statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode >= 500;
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}