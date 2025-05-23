// lib/providers/content_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// ==========================================
// CONTENT PROVIDERS
// ==========================================

// Provider pour les films populaires
final popularMoviesProvider = FutureProvider.family<TMDBResponse<Movie>, int>((ref, page) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getPopularMovies(page: page);
});

// Provider pour les séries populaires
final popularTVShowsProvider = FutureProvider.family<TMDBResponse<TVShow>, int>((ref, page) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getPopularTVShows(page: page);
});

// Provider pour le contenu trending
final trendingProvider = FutureProvider.family<TMDBResponse<dynamic>, TrendingParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getTrending(
    type: params.type,
    time: params.time,
    page: params.page,
  );
});

// Provider pour la recherche
final searchProvider = FutureProvider.family<TMDBResponse<dynamic>, SearchParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.search(params.query, page: params.page);
});

// Provider pour les détails d'un film
final movieDetailsProvider = FutureProvider.family<Movie, int>((ref, movieId) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getMovieDetails(movieId);
});

// Provider pour les détails d'une série
final tvShowDetailsProvider = FutureProvider.family<TVShow, int>((ref, tvId) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getTVShowDetails(tvId);
});

// Provider pour les détails d'une saison
final seasonDetailsProvider = FutureProvider.family<Season, SeasonParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getSeasonDetails(params.tvId, params.seasonNumber);
});

// Provider pour les genres
final genresProvider = FutureProvider.family<List<Genre>, String>((ref, type) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getGenres(type: type);
});

// Provider pour l'URL de streaming
final streamUrlProvider = FutureProvider.family<StreamResponse, StreamParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getStreamUrl(
    params.type,
    params.id,
    season: params.season,
    episode: params.episode,
    subtitleLang: params.subtitleLang,
  );
});

// ==========================================
// USER DATA PROVIDERS
// ==========================================

// Provider pour la watchlist
final watchlistProvider = FutureProvider.family<WatchlistResponse, WatchlistParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getWatchlist(
    page: params.page,
    limit: params.limit,
    mediaType: params.mediaType,
  );
});

// Provider pour vérifier si un élément est dans la watchlist
final inWatchlistProvider = FutureProvider.family<bool, CheckWatchlistParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.checkInWatchlist(params.tmdbId, params.mediaType);
});

// Provider pour les notes de l'utilisateur
final userRatingsProvider = FutureProvider.family<List<Rating>, RatingsParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getUserRatings(
    page: params.page,
    limit: params.limit,
    mediaType: params.mediaType,
    minRating: params.minRating,
    maxRating: params.maxRating,
  );
});

// Provider pour une note spécifique
final userRatingProvider = FutureProvider.family<Rating?, UserRatingParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getUserRating(
    params.tmdbId,
    params.mediaType,
    seasonNumber: params.seasonNumber,
    episodeNumber: params.episodeNumber,
  );
});

// Provider pour l'historique de visionnage
final watchHistoryProvider = FutureProvider.family<List<WatchHistoryItem>, WatchHistoryParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getWatchHistory(
    page: params.page,
    limit: params.limit,
    mediaType: params.mediaType,
    completed: params.completed,
  );
});

// Provider pour continuer le visionnage
final continueWatchingProvider = FutureProvider.family<List<WatchHistoryItem>, int>((ref, limit) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getContinueWatching(limit: limit);
});

// Provider pour le progrès de visionnage
final watchProgressProvider = FutureProvider.family<WatchProgress?, WatchProgressParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getWatchProgress(
    params.tmdbId,
    params.mediaType,
    seasonNumber: params.seasonNumber,
    episodeNumber: params.episodeNumber,
  );
});

// Provider pour les statistiques utilisateur
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getUserStats();
});

// ==========================================
// STATE NOTIFIERS POUR LES ACTIONS
// ==========================================

// Notifier pour gérer les actions de la watchlist
class WatchlistNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiService _apiService;

  WatchlistNotifier(this._apiService) : super(const AsyncValue.data(null));

  Future<bool> addToWatchlist({
    required int tmdbId,
    required String mediaType,
    required String title,
    String? posterPath,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final request = AddToWatchlistRequest(
        tmdbId: tmdbId,
        mediaType: mediaType,
        title: title,
        posterPath: posterPath,
      );
      
      await _apiService.addToWatchlist(request);
      state = const AsyncValue.data(null);
      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }

  Future<bool> removeFromWatchlist(int id) async {
    try {
      state = const AsyncValue.loading();
      await _apiService.removeFromWatchlist(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }
}

// Notifier pour gérer les notes
class RatingNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiService _apiService;

  RatingNotifier(this._apiService) : super(const AsyncValue.data(null));

  Future<bool> addRating({
    required int tmdbId,
    required String mediaType,
    required int rating,
    required String title,
    String? comment,
    int? seasonNumber,
    int? episodeNumber,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final request = AddRatingRequest(
        tmdbId: tmdbId,
        mediaType: mediaType,
        rating: rating,
        title: title,
        comment: comment,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      );
      
      await _apiService.addRating(request);
      state = const AsyncValue.data(null);
      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteRating(int ratingId) async {
    try {
      state = const AsyncValue.loading();
      await _apiService.deleteRating(ratingId);
      state = const AsyncValue.data(null);
      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }
}

// Notifier pour gérer l'historique de visionnage
class WatchHistoryNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiService _apiService;

  WatchHistoryNotifier(this._apiService) : super(const AsyncValue.data(null));

  Future<bool> updateWatchHistory({
    required int tmdbId,
    required String mediaType,
    required String title,
    String? posterPath,
    required int progress,
    int? duration,
    required bool completed,
    int? seasonNumber,
    int? episodeNumber,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final request = UpdateWatchHistoryRequest(
        tmdbId: tmdbId,
        mediaType: mediaType,
        title: title,
        posterPath: posterPath,
        progress: progress,
        duration: duration,
        completed: completed,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      );
      
      await _apiService.updateWatchHistory(request);
      state = const AsyncValue.data(null);
      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }

  Future<bool> clearWatchHistory({String? mediaType, DateTime? beforeDate}) async {
    try {
      state = const AsyncValue.loading();
      await _apiService.clearWatchHistory(mediaType: mediaType, beforeDate: beforeDate);
      state = const AsyncValue.data(null);
      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }
}

// Providers pour les notifiers
final watchlistNotifierProvider = StateNotifierProvider<WatchlistNotifier, AsyncValue<void>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return WatchlistNotifier(apiService);
});

// lib/providers/content_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// ==========================================
// CONTENT PROVIDERS
// ==========================================

// Provider pour les films populaires
final popularMoviesProvider = FutureProvider.family<TMDBResponse<Movie>, int>((ref, page) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getPopularMovies(page: page);
});

// Provider pour les séries populaires
final popularTVShowsProvider = FutureProvider.family<TMDBResponse<TVShow>, int>((ref, page) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getPopularTVShows(page: page);
});

// Provider pour le contenu trending
final trendingProvider = FutureProvider.family<TMDBResponse<dynamic>, TrendingParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getTrending(
    type: params.type,
    time: params.time,
    page: params.page,
  );
});

// Provider pour la recherche
final searchProvider = FutureProvider.family<TMDBResponse<dynamic>, SearchParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.search(params.query, page: params.page);
});

// Provider pour les détails d'un film
final movieDetailsProvider = FutureProvider.family<Movie, int>((ref, movieId) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getMovieDetails(movieId);
});

// Provider pour les détails d'une série
final tvShowDetailsProvider = FutureProvider.family<TVShow, int>((ref, tvId) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getTVShowDetails(tvId);
});

// Provider pour les détails d'une saison
final seasonDetailsProvider = FutureProvider.family<Season, SeasonParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getSeasonDetails(params.tvId, params.seasonNumber);
});

// Provider pour les genres
final genresProvider = FutureProvider.family<List<Genre>, String>((ref, type) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getGenres(type: type);
});

// Provider pour l'URL de streaming
final streamUrlProvider = FutureProvider.family<StreamResponse, StreamParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getStreamUrl(
    params.type,
    params.id,
    season: params.season,
    episode: params.episode,
    subtitleLang: params.subtitleLang,
  );
});

// ==========================================
// USER DATA PROVIDERS
// ==========================================

// Provider pour la watchlist
final watchlistProvider = FutureProvider.family<WatchlistResponse, WatchlistParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getWatchlist(
    page: params.page,
    limit: params.limit,
    mediaType: params.mediaType,
  );
});

// Provider pour vérifier si un élément est dans la watchlist
final inWatchlistProvider = FutureProvider.family<bool, CheckWatchlistParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.checkInWatchlist(params.tmdbId, params.mediaType);
});

// Provider pour les notes de l'utilisateur
final userRatingsProvider = FutureProvider.family<List<Rating>, RatingsParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getUserRatings(
    page: params.page,
    limit: params.limit,
    mediaType: params.mediaType,
    minRating: params.minRating,
    maxRating: params.maxRating,
  );
});

// Provider pour une note spécifique
final userRatingProvider = FutureProvider.family<Rating?, UserRatingParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getUserRating(
    params.tmdbId,
    params.mediaType,
    seasonNumber: params.seasonNumber,
    episodeNumber: params.episodeNumber,
  );
});

// Provider pour l'historique de visionnage
final watchHistoryProvider = FutureProvider.family<List<WatchHistoryItem>, WatchHistoryParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getWatchHistory(
    page: params.page,
    limit: params.limit,
    mediaType: params.mediaType,
    completed: params.completed,
  );
});

// Provider pour continuer le visionnage
final continueWatchingProvider = FutureProvider.family<List<WatchHistoryItem>, int>((ref, limit) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getContinueWatching(limit: limit);
});

// Provider pour le progrès de visionnage
final watchProgressProvider = FutureProvider.family<WatchProgress?, WatchProgressParams>((ref, params) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getWatchProgress(
    params.tmdbId,
    params.mediaType,
    seasonNumber: params.seasonNumber,
    episodeNumber: params.episodeNumber,
  );
});

// Provider pour les statistiques utilisateur
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getUserStats();
});

// ==========================================
// STATE NOTIFIERS POUR LES ACTIONS
// ==========================================

// Notifier pour gérer les actions de la watchlist
class WatchlistNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiService _apiService;

  WatchlistNotifier(this._apiService) : super(const AsyncValue.data(null));

  Future<bool> addToWatchlist({
    required int tmdbId,
    required String mediaType,
    required String title,
    String? posterPath,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final request = AddToWatchlistRequest(
        tmdbId: tmdbId,
        mediaType: mediaType,
        title: title,
        posterPath: posterPath,
      );
      
      await _apiService.addToWatchlist(request);
      state = const AsyncValue.data(null);
      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }

  Future<bool> removeFromWatchlist(int id) async {
    try {
      state = const AsyncValue.loading();
      await _apiService.removeFromWatchlist(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }
}

// Notifier pour gérer les notes
class RatingNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiService _apiService;

  RatingNotifier(this._apiService) : super(const AsyncValue.data(null));

  Future<bool> addRating({
    required int tmdbId,
    required String mediaType,
    required int rating,
    required String title,
    String? comment,
    int? seasonNumber,
    int? episodeNumber,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final request = AddRatingRequest(
        tmdbId: tmdbId,
        mediaType: mediaType,
        rating: rating,
        title: title,
        comment: comment,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      );
      
      await _apiService.addRating(request);
      state = const AsyncValue.data(null);
      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteRating(int ratingId) async {
    try {
      state = const AsyncValue.loading();
      await _apiService.deleteRating(ratingId);
      state = const AsyncValue.data(null);
      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }
}

// Notifier pour gérer l'historique de visionnage
class WatchHistoryNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiService _apiService;

  WatchHistoryNotifier(this._apiService) : super(const AsyncValue.data(null));

  Future<bool> updateWatchHistory({
    required int tmdbId,
    required String mediaType,
    required String title,
    String? posterPath,
    required int progress,
    int? duration,
    required bool completed,
    int? seasonNumber,
    int? episodeNumber,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final request = UpdateWatchHistoryRequest(
        tmdbId: tmdbId,
        mediaType: mediaType,
        title: title,
        posterPath: posterPath,
        progress: progress,
        duration: duration,
        completed: completed,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      );
      
      await _apiService.updateWatchHistory(request);
      state = const AsyncValue.data(null);
      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }

  Future<bool> clearWatchHistory({String? mediaType, DateTime? beforeDate}) async {
    try {
      state = const AsyncValue.loading();
      await _apiService.clearWatchHistory(mediaType: mediaType, beforeDate: beforeDate);
      state = const AsyncValue.data(null);
      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }
}

// Providers pour les notifiers
final watchlistNotifierProvider = StateNotifierProvider<WatchlistNotifier, AsyncValue<void>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return WatchlistNotifier(apiService);
});

final ratingNotifierProvider = StateNotifierProvider<RatingNotifier, AsyncValue<void>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return RatingNotifier(apiService);
});

final watchHistoryNotifierProvider = StateNotifierProvider<WatchHistoryNotifier, AsyncValue<void>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return WatchHistoryNotifier(apiService);
});

// ==========================================
// PARAMETER CLASSES
// ==========================================

class TrendingParams {
  final String type;
  final String time;
  final int page;

  TrendingParams({
    required this.type,
    required this.time,
    required this.page,
  });
}

class SearchParams {
  final String query;
  final int page;

  SearchParams({
    required this.query,
    required this.page,
  });
}

class SeasonParams {
  final int tvId;
  final int seasonNumber;

  SeasonParams({
    required this.tvId,
    required this.seasonNumber,
  });
}

class StreamParams {
  final String type;
  final int id;
  final int? season;
  final int? episode;
  final String? subtitleLang;

  StreamParams({
    required this.type,
    required this.id,
    this.season,
    this.episode,
    this.subtitleLang,
  });
}

class WatchlistParams {
  final int page;
  final int limit;
  final String? mediaType;

  WatchlistParams({
    required this.page,
    required this.limit,
    this.mediaType,
  });
}

class CheckWatchlistParams {
  final int tmdbId;
  final String mediaType;

  CheckWatchlistParams({
    required this.tmdbId,
    required this.mediaType,
  });
}

class RatingsParams {
  final int page;
  final int limit;
  final String? mediaType;
  final int? minRating;
  final int? maxRating;

  RatingsParams({
    required this.page,
    required this.limit,
    this.mediaType,
    this.minRating,
    this.maxRating,
  });
}

class UserRatingParams {
  final int tmdbId;
  final String mediaType;
  final int? seasonNumber;
  final int? episodeNumber;

  UserRatingParams({
    required this.tmdbId,
    required this.mediaType,
    this.seasonNumber,
    this.episodeNumber,
  });
}

class WatchHistoryParams {
  final int page;
  final int limit;
  final String? mediaType;
  final bool? completed;

  WatchHistoryParams({
    required this.page,
    required this.limit,
    this.mediaType,
    this.completed,
  });
}

class WatchProgressParams {
  final int tmdbId;
  final String mediaType;
  final int? seasonNumber;
  final int? episodeNumber;

  WatchProgressParams({
    required this.tmdbId,
    required this.mediaType,
    this.seasonNumber,
    this.episodeNumber,
  });
}