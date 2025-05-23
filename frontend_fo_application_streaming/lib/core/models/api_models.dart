import 'package:json_annotation/json_annotation.dart';

part '../../models/api_models.g.dart';

// ==========================================
// USER MODELS
// ==========================================

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String avatar;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatar,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final String token;
  final User user;
  final String? message;

  AuthResponse({
    required this.token,
    required this.user,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

// ==========================================
// CONTENT MODELS (TMDB)
// ==========================================

@JsonSerializable()
class Movie {
  final int id;
  final String title;
  final String? overview;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @JsonKey(name: 'vote_average')
  final double? voteAverage;
  @JsonKey(name: 'vote_count')
  final int? voteCount;
  @JsonKey(name: 'genre_ids')
  final List<int>? genreIds;
  final bool? adult;
  @JsonKey(name: 'media_type')
  final String mediaType;
  @JsonKey(name: 'poster_url')
  final String? posterUrl;
  @JsonKey(name: 'backdrop_url')
  final String? backdropUrl;

  Movie({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
    this.genreIds,
    this.adult,
    this.mediaType = 'movie',
    this.posterUrl,
    this.backdropUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
  Map<String, dynamic> toJson() => _$MovieToJson(this);
}

@JsonSerializable()
class TVShow {
  final int id;
  final String name;
  final String? title; // Alias pour uniformité
  final String? overview;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  @JsonKey(name: 'first_air_date')
  final String? firstAirDate;
  @JsonKey(name: 'vote_average')
  final double? voteAverage;
  @JsonKey(name: 'vote_count')
  final int? voteCount;
  @JsonKey(name: 'genre_ids')
  final List<int>? genreIds;
  @JsonKey(name: 'media_type')
  final String mediaType;
  @JsonKey(name: 'poster_url')
  final String? posterUrl;
  @JsonKey(name: 'backdrop_url')
  final String? backdropUrl;

  TVShow({
    required this.id,
    required this.name,
    this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.firstAirDate,
    this.voteAverage,
    this.voteCount,
    this.genreIds,
    this.mediaType = 'tv',
    this.posterUrl,
    this.backdropUrl,
  });

  factory TVShow.fromJson(Map<String, dynamic> json) => _$TVShowFromJson(json);
  Map<String, dynamic> toJson() => _$TVShowToJson(this);

  String get displayTitle => title ?? name;
}

@JsonSerializable()
class Genre {
  final int id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);
  Map<String, dynamic> toJson() => _$GenreToJson(this);
}

@JsonSerializable()
class Season {
  final int id;
  @JsonKey(name: 'season_number')
  final int seasonNumber;
  final String name;
  final String? overview;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'air_date')
  final String? airDate;
  @JsonKey(name: 'episode_count')
  final int episodeCount;
  final List<Episode>? episodes;

  Season({
    required this.id,
    required this.seasonNumber,
    required this.name,
    this.overview,
    this.posterPath,
    this.airDate,
    required this.episodeCount,
    this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);
  Map<String, dynamic> toJson() => _$SeasonToJson(this);
}

@JsonSerializable()
class Episode {
  final int id;
  @JsonKey(name: 'episode_number')
  final int episodeNumber;
  final String name;
  final String? overview;
  @JsonKey(name: 'still_path')
  final String? stillPath;
  @JsonKey(name: 'air_date')
  final String? airDate;
  @JsonKey(name: 'vote_average')
  final double? voteAverage;
  final int? runtime;

  Episode({
    required this.id,
    required this.episodeNumber,
    required this.name,
    this.overview,
    this.stillPath,
    this.airDate,
    this.voteAverage,
    this.runtime,
  });

  factory Episode.fromJson(Map<String, dynamic> json) =>
      _$EpisodeFromJson(json);
  Map<String, dynamic> toJson() => _$EpisodeToJson(this);
}

// ==========================================
// USER DATA MODELS
// ==========================================

@JsonSerializable()
class WatchlistItem {
  final int id;
  @JsonKey(name: 'tmdbId')
  final int tmdbId;
  @JsonKey(name: 'mediaType')
  final String mediaType;
  final String title;
  @JsonKey(name: 'posterPath')
  final String? posterPath;
  @JsonKey(name: 'poster_url')
  final String? posterUrl;
  @JsonKey(name: 'addedAt')
  final DateTime addedAt;
  @JsonKey(name: 'added_days_ago')
  final int? addedDaysAgo;

  WatchlistItem({
    required this.id,
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    this.posterPath,
    this.posterUrl,
    required this.addedAt,
    this.addedDaysAgo,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) =>
      _$WatchlistItemFromJson(json);
  Map<String, dynamic> toJson() => _$WatchlistItemToJson(this);
}

@JsonSerializable()
class Rating {
  final int id;
  @JsonKey(name: 'tmdbId')
  final int tmdbId;
  @JsonKey(name: 'mediaType')
  final String mediaType;
  @JsonKey(name: 'seasonNumber')
  final int? seasonNumber;
  @JsonKey(name: 'episodeNumber')
  final int? episodeNumber;
  final int rating;
  final String? comment;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  Rating({
    required this.id,
    required this.tmdbId,
    required this.mediaType,
    this.seasonNumber,
    this.episodeNumber,
    required this.rating,
    this.comment,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);
  Map<String, dynamic> toJson() => _$RatingToJson(this);
}

@JsonSerializable()
class WatchHistoryItem {
  final int id;
  @JsonKey(name: 'tmdbId')
  final int tmdbId;
  @JsonKey(name: 'mediaType')
  final String mediaType;
  @JsonKey(name: 'seasonNumber')
  final int? seasonNumber;
  @JsonKey(name: 'episodeNumber')
  final int? episodeNumber;
  final String title;
  @JsonKey(name: 'posterPath')
  final String? posterPath;
  @JsonKey(name: 'poster_url')
  final String? posterUrl;
  @JsonKey(name: 'watchedAt')
  final DateTime watchedAt;
  final int progress;
  final int? duration;
  final bool completed;
  @JsonKey(name: 'progressPercentage')
  final int? progressPercentage;
  @JsonKey(name: 'watched_days_ago')
  final int? watchedDaysAgo;
  @JsonKey(name: 'remaining_time')
  final int? remainingTime;

  WatchHistoryItem({
    required this.id,
    required this.tmdbId,
    required this.mediaType,
    this.seasonNumber,
    this.episodeNumber,
    required this.title,
    this.posterPath,
    this.posterUrl,
    required this.watchedAt,
    required this.progress,
    this.duration,
    required this.completed,
    this.progressPercentage,
    this.watchedDaysAgo,
    this.remainingTime,
  });

  factory WatchHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$WatchHistoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$WatchHistoryItemToJson(this);
}

// ==========================================
// API RESPONSE MODELS
// ==========================================

@JsonSerializable()
class TMDBResponse<T> {
  final int page;
  final List<T> results;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'total_results')
  final int totalResults;

  TMDBResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory TMDBResponse.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      TMDBResponse<T>(
        page: json['page'] as int,
        results: (json['results'] as List<dynamic>).map(fromJsonT).toList(),
        totalPages: json['total_pages'] as int,
        totalResults: json['total_results'] as int,
      );

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) => {
        'page': page,
        'results': results.map(toJsonT).toList(),
        'total_pages': totalPages,
        'total_results': totalResults,
      };
}

@JsonSerializable()
class WatchlistResponse {
  final List<WatchlistItem> items;
  final Pagination pagination;
  final WatchlistStats stats;

  WatchlistResponse({
    required this.items,
    required this.pagination,
    required this.stats,
  });

  factory WatchlistResponse.fromJson(Map<String, dynamic> json) =>
      _$WatchlistResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WatchlistResponseToJson(this);
}

@JsonSerializable()
class Pagination {
  final int total;
  final int page;
  final int limit;
  @JsonKey(name: 'totalPages')
  final int totalPages;
  @JsonKey(name: 'hasNext')
  final bool hasNext;
  @JsonKey(name: 'hasPrev')
  final bool hasPrev;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}

@JsonSerializable()
class WatchlistStats {
  @JsonKey(name: 'totalMovies')
  final int totalMovies;
  @JsonKey(name: 'totalTV')
  final int totalTV;

  WatchlistStats({
    required this.totalMovies,
    required this.totalTV,
  });

  factory WatchlistStats.fromJson(Map<String, dynamic> json) =>
      _$WatchlistStatsFromJson(json);
  Map<String, dynamic> toJson() => _$WatchlistStatsToJson(this);
}

@JsonSerializable()
class StreamResponse {
  @JsonKey(name: 'tmdbId')
  final int tmdbId;
  @JsonKey(name: 'mediaType')
  final String mediaType;
  final String title;
  @JsonKey(name: 'streamUrl')
  final String streamUrl;
  final int? season;
  final int? episode;

  StreamResponse({
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    required this.streamUrl,
    this.season,
    this.episode,
  });

  factory StreamResponse.fromJson(Map<String, dynamic> json) =>
      _$StreamResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StreamResponseToJson(this);
}

// ==========================================
// REQUEST MODELS
// ==========================================

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String? avatar;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.avatar,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class AddToWatchlistRequest {
  @JsonKey(name: 'tmdbId')
  final int tmdbId;
  @JsonKey(name: 'mediaType')
  final String mediaType;
  final String title;
  @JsonKey(name: 'posterPath')
  final String? posterPath;

  AddToWatchlistRequest({
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    this.posterPath,
  });

  factory AddToWatchlistRequest.fromJson(Map<String, dynamic> json) =>
      _$AddToWatchlistRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddToWatchlistRequestToJson(this);
}

@JsonSerializable()
class AddRatingRequest {
  @JsonKey(name: 'tmdbId')
  final int tmdbId;
  @JsonKey(name: 'mediaType')
  final String mediaType;
  final int rating;
  final String? comment;
  final String title;
  @JsonKey(name: 'seasonNumber')
  final int? seasonNumber;
  @JsonKey(name: 'episodeNumber')
  final int? episodeNumber;

  AddRatingRequest({
    required this.tmdbId,
    required this.mediaType,
    required this.rating,
    this.comment,
    required this.title,
    this.seasonNumber,
    this.episodeNumber,
  });

  factory AddRatingRequest.fromJson(Map<String, dynamic> json) =>
      _$AddRatingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddRatingRequestToJson(this);
}

@JsonSerializable()
class UpdateWatchHistoryRequest {
  @JsonKey(name: 'tmdbId')
  final int tmdbId;
  @JsonKey(name: 'mediaType')
  final String mediaType;
  final String title;
  @JsonKey(name: 'posterPath')
  final String? posterPath;
  final int progress;
  final int? duration;
  final bool completed;
  @JsonKey(name: 'seasonNumber')
  final int? seasonNumber;
  @JsonKey(name: 'episodeNumber')
  final int? episodeNumber;

  UpdateWatchHistoryRequest({
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    this.posterPath,
    required this.progress,
    this.duration,
    required this.completed,
    this.seasonNumber,
    this.episodeNumber,
  });

  factory UpdateWatchHistoryRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateWatchHistoryRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateWatchHistoryRequestToJson(this);
}
