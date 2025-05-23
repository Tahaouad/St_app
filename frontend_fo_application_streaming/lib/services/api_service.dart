// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/api_models.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:5000/api'; // Changez selon votre config
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
  // AUTHENTIFICATION
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

  Future<void> logout() async {
    try {
      // Supprimer toutes les données stockées
      await _storage.deleteAll();
    } catch (e) {
      // En cas d'erreur, on supprime quand même les données locales
      await _storage.deleteAll();
    }
  }

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

  // ==========================================
  // CONTENU (TMDB)
  // ==========================================

  Future<TMDBResponse<dynamic>> search(String query, {int page = 1}) async {
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

      final data = json.decode(response.body);
      return TMDBResponse.fromJson(data, (json) {
        if (json is Map<String, dynamic>) {
          final mediaType = json['media_type'] as String?;
          if (mediaType == 'movie') {
            return Movie.fromJson(json);
          } else if (mediaType == 'tv') {
            return TVShow.fromJson(json);
          }
        }
        return json;
      });
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<TMDBResponse<Movie>> getPopularMovies({int page = 1}) async {
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

      final data = json.decode(response.body);
      return TMDBResponse.fromJson(
          data, (json) => Movie.fromJson(json as Map<String, dynamic>));
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<TMDBResponse<TVShow>> getPopularTVShows({int page = 1}) async {
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

      final data = json.decode(response.body);
      return TMDBResponse.fromJson(
          data, (json) => TVShow.fromJson(json as Map<String, dynamic>));
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<TMDBResponse<dynamic>> getTrending({
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

      final data = json.decode(response.body);
      return TMDBResponse.fromJson(data, (json) {
        if (json is Map<String, dynamic>) {
          final mediaType = json['media_type'] as String?;
          if (mediaType == 'movie') {
            return Movie.fromJson(json);
          } else if (mediaType == 'tv') {
            return TVShow.fromJson(json);
          }
        }
        return json;
      });
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<TMDBResponse<dynamic>> getTopRated({
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

      final data = json.decode(response.body);
      return TMDBResponse.fromJson(data, (json) {
        if (json is Map<String, dynamic>) {
          final mediaType = json['media_type'] ?? type;
          if (mediaType == 'movie') {
            return Movie.fromJson(json);
          } else if (mediaType == 'tv') {
            return TVShow.fromJson(json);
          }
        }
        return json;
      });
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<TMDBResponse<Movie>> getUpcoming({int page = 1}) async {
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

      final data = json.decode(response.body);
      return TMDBResponse.fromJson(
          data, (json) => Movie.fromJson(json as Map<String, dynamic>));
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/content/movie/$movieId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      return Movie.fromJson(data);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<TVShow> getTVShowDetails(int tvId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/content/tv/$tvId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      return TVShow.fromJson(data);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Season> getSeasonDetails(int tvId, int seasonNumber) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/content/tv/$tvId/season/$seasonNumber'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      return Season.fromJson(data);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<Episode> getEpisodeDetails(
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

      final data = json.decode(response.body);
      return Episode.fromJson(data);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<List<Genre>> getGenres({String type = 'movie'}) async {
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

      final data = json.decode(response.body);
      final genres =
          (data['genres'] as List).map((json) => Genre.fromJson(json)).toList();
      return genres;
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<TMDBResponse<dynamic>> discoverByGenre(
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

      final data = json.decode(response.body);
      return TMDBResponse.fromJson(data, (json) {
        if (json is Map<String, dynamic>) {
          if (type == 'movie') {
            return Movie.fromJson(json);
          } else if (type == 'tv') {
            return TVShow.fromJson(json);
          }
        }
        return json;
      });
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
  // WATCHLIST
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
  // RATINGS
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

  Future<RatingsResponse> getUserRatings({
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

      final data = json.decode(response.body);
      return RatingsResponse.fromJson(data);
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
  // WATCH HISTORY
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

  Future<WatchHistoryResponse> getWatchHistory({
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

      final data = json.decode(response.body);
      return WatchHistoryResponse.fromJson(data);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Future<WatchProgress?> getWatchProgress(
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
      return data['progress'] != null
          ? WatchProgress.fromJson(data['progress'])
          : null;
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
  // USER STATS
  // ==========================================

  Future<UserStats> getUserStats() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/user/stats'),
            headers: await _authHeaders,
          )
          .timeout(const Duration(seconds: 30));

      _handleError(response);

      final data = json.decode(response.body);
      return UserStats.fromJson(data);
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

  // Helper pour formater la durée
  static String formatDuration(int? runtime) {
    if (runtime == null || runtime == 0) return '';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  // Helper pour formater les dates
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Helper pour formater les notes
  static String formatRating(double? rating) {
    if (rating == null) return '';
    return rating.toStringAsFixed(1);
  }
}

// ==========================================
// MODÈLES DE RÉPONSE ADDITIONNELS
// ==========================================

@JsonSerializable()
class RatingsResponse {
  final List<Rating> ratings;
  final Pagination pagination;
  final RatingsStats stats;

  RatingsResponse({
    required this.ratings,
    required this.pagination,
    required this.stats,
  });

  factory RatingsResponse.fromJson(Map<String, dynamic> json) =>
      _$RatingsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RatingsResponseToJson(this);
}

@JsonSerializable()
class RatingsStats {
  @JsonKey(name: 'averageRating')
  final String averageRating;
  @JsonKey(name: 'totalRatings')
  final int totalRatings;
  @JsonKey(name: 'ratingDistribution')
  final List<RatingDistribution> ratingDistribution;

  RatingsStats({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  factory RatingsStats.fromJson(Map<String, dynamic> json) =>
      _$RatingsStatsFromJson(json);
  Map<String, dynamic> toJson() => _$RatingsStatsToJson(this);
}

@JsonSerializable()
class RatingDistribution {
  final int rating;
  final int count;

  RatingDistribution({
    required this.rating,
    required this.count,
  });

  factory RatingDistribution.fromJson(Map<String, dynamic> json) =>
      _$RatingDistributionFromJson(json);
  Map<String, dynamic> toJson() => _$RatingDistributionToJson(this);
}

@JsonSerializable()
class WatchHistoryResponse {
  final List<WatchHistoryItem> history;
  final Pagination pagination;
  final WatchHistoryStatsResponse stats;

  WatchHistoryResponse({
    required this.history,
    required this.pagination,
    required this.stats,
  });

  factory WatchHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$WatchHistoryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WatchHistoryResponseToJson(this);
}

@JsonSerializable()
class WatchHistoryStatsResponse {
  @JsonKey(name: 'totalWatched')
  final int totalWatched;
  @JsonKey(name: 'completedCount')
  final int completedCount;
  @JsonKey(name: 'inProgressCount')
  final int inProgressCount;
  @JsonKey(name: 'totalWatchTime')
  final int totalWatchTime;

  WatchHistoryStatsResponse({
    required this.totalWatched,
    required this.completedCount,
    required this.inProgressCount,
    required this.totalWatchTime,
  });

  factory WatchHistoryStatsResponse.fromJson(Map<String, dynamic> json) =>
      _$WatchHistoryStatsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WatchHistoryStatsResponseToJson(this);
}

@JsonSerializable()
class WatchProgress {
  final int progress;
  final int? duration;
  final bool completed;
  @JsonKey(name: 'progressPercentage')
  final int progressPercentage;
  @JsonKey(name: 'lastWatchedAt')
  final DateTime lastWatchedAt;
  @JsonKey(name: 'remainingTime')
  final int? remainingTime;

  WatchProgress({
    required this.progress,
    this.duration,
    required this.completed,
    required this.progressPercentage,
    required this.lastWatchedAt,
    this.remainingTime,
  });

  factory WatchProgress.fromJson(Map<String, dynamic> json) =>
      _$WatchProgressFromJson(json);
  Map<String, dynamic> toJson() => _$WatchProgressToJson(this);
}

@JsonSerializable()
class UserStats {
  final GeneralStats general;
  final Map<String, int> watchlist;
  final Map<String, WatchHistoryStats> watchHistory;
  @JsonKey(name: 'recentActivity')
  final RecentActivity recentActivity;

  UserStats({
    required this.general,
    required this.watchlist,
    required this.watchHistory,
    required this.recentActivity,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}

@JsonSerializable()
class GeneralStats {
  @JsonKey(name: 'watchlistItems')
  final int watchlistItems;
  @JsonKey(name: 'ratingsGiven')
  final int ratingsGiven;
  @JsonKey(name: 'itemsWatched')
  final int itemsWatched;
  @JsonKey(name: 'totalWatchTimeSeconds')
  final int totalWatchTimeSeconds;
  @JsonKey(name: 'totalWatchTimeHours')
  final int totalWatchTimeHours;
  @JsonKey(name: 'averageRating')
  final String averageRating;

  GeneralStats({
    required this.watchlistItems,
    required this.ratingsGiven,
    required this.itemsWatched,
    required this.totalWatchTimeSeconds,
    required this.totalWatchTimeHours,
    required this.averageRating,
  });

  factory GeneralStats.fromJson(Map<String, dynamic> json) =>
      _$GeneralStatsFromJson(json);
  Map<String, dynamic> toJson() => _$GeneralStatsToJson(this);
}

@JsonSerializable()
class WatchHistoryStats {
  final int count;
  @JsonKey(name: 'totalTime')
  final int totalTime;

  WatchHistoryStats({
    required this.count,
    required this.totalTime,
  });

  factory WatchHistoryStats.fromJson(Map<String, dynamic> json) =>
      _$WatchHistoryStatsFromJson(json);
  Map<String, dynamic> toJson() => _$WatchHistoryStatsToJson(this);
}

@JsonSerializable()
class RecentActivity {
  @JsonKey(name: 'lastWatchlistAddition')
  final RecentItem? lastWatchlistAddition;
  @JsonKey(name: 'lastWatched')
  final RecentItem? lastWatched;
  @JsonKey(name: 'lastRating')
  final RecentRating? lastRating;

  RecentActivity({
    this.lastWatchlistAddition,
    this.lastWatched,
    this.lastRating,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) =>
      _$RecentActivityFromJson(json);
  Map<String, dynamic> toJson() => _$RecentActivityToJson(this);
}

@JsonSerializable()
class RecentItem {
  final String title;
  @JsonKey(name: 'mediaType')
  final String mediaType;
  final DateTime addedAt;

  RecentItem({
    required this.title,
    required this.mediaType,
    required this.addedAt,
  });

  factory RecentItem.fromJson(Map<String, dynamic> json) =>
      _$RecentItemFromJson(json);
  Map<String, dynamic> toJson() => _$RecentItemToJson(this);
}

@JsonSerializable()
class RecentRating {
  final String title;
  final int rating;
  final DateTime updatedAt;

  RecentRating({
    required this.title,
    required this.rating,
    required this.updatedAt,
  });

  factory RecentRating.fromJson(Map<String, dynamic> json) =>
      _$RecentRatingFromJson(json);
  Map<String, dynamic> toJson() => _$RecentRatingToJson(this);
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

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  ValidationException(this.message, {this.fieldErrors});

  @override
  String toString() => 'ValidationException: $message';
}

// ==========================================
// CONSTANTS
// ==========================================

class ApiConstants {
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/';

  // Tailles d'images TMDB
  static const String posterSizeSmall = 'w154';
  static const String posterSizeMedium = 'w342';
  static const String posterSizeLarge = 'w500';
  static const String posterSizeOriginal = 'original';

  static const String backdropSizeSmall = 'w300';
  static const String backdropSizeMedium = 'w780';
  static const String backdropSizeLarge = 'w1280';
  static const String backdropSizeOriginal = 'original';

  static const String profileSizeSmall = 'w185';
  static const String profileSizeLarge = 'h632';
  static const String profileSizeOriginal = 'original';

  static const String stillSizeSmall = 'w185';
  static const String stillSizeMedium = 'w300';
  static const String stillSizeOriginal = 'original';

  // Timeout
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Media types
  static const String mediaTypeMovie = 'movie';
  static const String mediaTypeTV = 'tv';
  static const String mediaTypeEpisode = 'episode';

  // Trending time windows
  static const String trendingDay = 'day';
  static const String trendingWeek = 'week';

  // Sort orders
  static const String sortAsc = 'ASC';
  static const String sortDesc = 'DESC';
}

// ==========================================
// HELPER EXTENSIONS
// ==========================================

extension ApiResponseHelpers on http.Response {
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;

  Map<String, dynamic> get jsonBody {
    try {
      return json.decode(body) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Invalid JSON response: $body');
    }
  }
}

extension StringHelpers on String {
  String get tmdbPosterUrl =>
      ApiService.buildImageUrl(this, size: ApiConstants.posterSizeMedium);
  String get tmdbBackdropUrl =>
      ApiService.buildImageUrl(this, size: ApiConstants.backdropSizeLarge);
  String get tmdbProfileUrl =>
      ApiService.buildImageUrl(this, size: ApiConstants.profileSizeSmall);
  String get tmdbStillUrl =>
      ApiService.buildImageUrl(this, size: ApiConstants.stillSizeMedium);
}

extension DateTimeHelpers on DateTime {
  String get formattedDate => ApiService.formatDate(toIso8601String());

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'À l\'instant';
    }
  }
}

extension DurationHelpers on int {
  String get formattedDuration => ApiService.formatDuration(this);

  String get formattedTime {
    final hours = this ~/ 3600;
    final minutes = (this % 3600) ~/ 60;
    final seconds = this % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}

extension RatingHelpers on double {
  String get formattedRating => ApiService.formatRating(this);

  int get ratingStars => (this / 2).round().clamp(0, 5);

  String get ratingPercentage => '${(this * 10).round()}%';
}
