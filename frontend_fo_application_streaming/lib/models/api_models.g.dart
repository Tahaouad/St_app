// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../core/models/api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      avatar: json['avatar'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'avatar': instance.avatar,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'user': instance.user,
      'message': instance.message,
    };

Movie _$MovieFromJson(Map<String, dynamic> json) => Movie(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
      genreIds:
          (json['genre_ids'] as List<dynamic>?)?.map((e) => e as int).toList(),
      adult: json['adult'] as bool?,
      mediaType: json['media_type'] as String? ?? 'movie',
      posterUrl: json['poster_url'] as String?,
      backdropUrl: json['backdrop_url'] as String?,
    );

Map<String, dynamic> _$MovieToJson(Movie instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'overview': instance.overview,
      'poster_path': instance.posterPath,
      'backdrop_path': instance.backdropPath,
      'release_date': instance.releaseDate,
      'vote_average': instance.voteAverage,
      'vote_count': instance.voteCount,
      'genre_ids': instance.genreIds,
      'adult': instance.adult,
      'media_type': instance.mediaType,
      'poster_url': instance.posterUrl,
      'backdrop_url': instance.backdropUrl,
    };

TVShow _$TVShowFromJson(Map<String, dynamic> json) => TVShow(
      id: json['id'] as int,
      name: json['name'] as String,
      title: json['title'] as String?,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      firstAirDate: json['first_air_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
      genreIds:
          (json['genre_ids'] as List<dynamic>?)?.map((e) => e as int).toList(),
      mediaType: json['media_type'] as String? ?? 'tv',
      posterUrl: json['poster_url'] as String?,
      backdropUrl: json['backdrop_url'] as String?,
    );

Map<String, dynamic> _$TVShowToJson(TVShow instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'title': instance.title,
      'overview': instance.overview,
      'poster_path': instance.posterPath,
      'backdrop_path': instance.backdropPath,
      'first_air_date': instance.firstAirDate,
      'vote_average': instance.voteAverage,
      'vote_count': instance.voteCount,
      'genre_ids': instance.genreIds,
      'media_type': instance.mediaType,
      'poster_url': instance.posterUrl,
      'backdrop_url': instance.backdropUrl,
    };

Genre _$GenreFromJson(Map<String, dynamic> json) => Genre(
      id: json['id'] as int,
      name: json['name'] as String,
    );

Map<String, dynamic> _$GenreToJson(Genre instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

Season _$SeasonFromJson(Map<String, dynamic> json) => Season(
      id: json['id'] as int,
      seasonNumber: json['season_number'] as int,
      name: json['name'] as String,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      airDate: json['air_date'] as String?,
      episodeCount: json['episode_count'] as int,
      episodes: (json['episodes'] as List<dynamic>?)
          ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SeasonToJson(Season instance) => <String, dynamic>{
      'id': instance.id,
      'season_number': instance.seasonNumber,
      'name': instance.name,
      'overview': instance.overview,
      'poster_path': instance.posterPath,
      'air_date': instance.airDate,
      'episode_count': instance.episodeCount,
      'episodes': instance.episodes,
    };

Episode _$EpisodeFromJson(Map<String, dynamic> json) => Episode(
      id: json['id'] as int,
      episodeNumber: json['episode_number'] as int,
      name: json['name'] as String,
      overview: json['overview'] as String?,
      stillPath: json['still_path'] as String?,
      airDate: json['air_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      runtime: json['runtime'] as int?,
    );

Map<String, dynamic> _$EpisodeToJson(Episode instance) => <String, dynamic>{
      'id': instance.id,
      'episode_number': instance.episodeNumber,
      'name': instance.name,
      'overview': instance.overview,
      'still_path': instance.stillPath,
      'air_date': instance.airDate,
      'vote_average': instance.voteAverage,
      'runtime': instance.runtime,
    };

WatchlistItem _$WatchlistItemFromJson(Map<String, dynamic> json) =>
    WatchlistItem(
      id: json['id'] as int,
      tmdbId: json['tmdbId'] as int,
      mediaType: json['mediaType'] as String,
      title: json['title'] as String,
      posterPath: json['posterPath'] as String?,
      posterUrl: json['poster_url'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
      addedDaysAgo: json['added_days_ago'] as int?,
    );

Map<String, dynamic> _$WatchlistItemToJson(WatchlistItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tmdbId': instance.tmdbId,
      'mediaType': instance.mediaType,
      'title': instance.title,
      'posterPath': instance.posterPath,
      'poster_url': instance.posterUrl,
      'addedAt': instance.addedAt.toIso8601String(),
      'added_days_ago': instance.addedDaysAgo,
    };

Rating _$RatingFromJson(Map<String, dynamic> json) => Rating(
      id: json['id'] as int,
      tmdbId: json['tmdbId'] as int,
      mediaType: json['mediaType'] as String,
      seasonNumber: json['seasonNumber'] as int?,
      episodeNumber: json['episodeNumber'] as int?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RatingToJson(Rating instance) => <String, dynamic>{
      'id': instance.id,
      'tmdbId': instance.tmdbId,
      'mediaType': instance.mediaType,
      'seasonNumber': instance.seasonNumber,
      'episodeNumber': instance.episodeNumber,
      'rating': instance.rating,
      'comment': instance.comment,
      'title': instance.title,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

WatchHistoryItem _$WatchHistoryItemFromJson(Map<String, dynamic> json) =>
    WatchHistoryItem(
      id: json['id'] as int,
      tmdbId: json['tmdbId'] as int,
      mediaType: json['mediaType'] as String,
      seasonNumber: json['seasonNumber'] as int?,
      episodeNumber: json['episodeNumber'] as int?,
      title: json['title'] as String,
      posterPath: json['posterPath'] as String?,
      posterUrl: json['poster_url'] as String?,
      watchedAt: DateTime.parse(json['watchedAt'] as String),
      progress: json['progress'] as int,
      duration: json['duration'] as int?,
      completed: json['completed'] as bool,
      progressPercentage: json['progressPercentage'] as int?,
      watchedDaysAgo: json['watched_days_ago'] as int?,
      remainingTime: json['remaining_time'] as int?,
    );

Map<String, dynamic> _$WatchHistoryItemToJson(WatchHistoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tmdbId': instance.tmdbId,
      'mediaType': instance.mediaType,
      'seasonNumber': instance.seasonNumber,
      'episodeNumber': instance.episodeNumber,
      'title': instance.title,
      'posterPath': instance.posterPath,
      'poster_url': instance.posterUrl,
      'watchedAt': instance.watchedAt.toIso8601String(),
      'progress': instance.progress,
      'duration': instance.duration,
      'completed': instance.completed,
      'progressPercentage': instance.progressPercentage,
      'watched_days_ago': instance.watchedDaysAgo,
      'remaining_time': instance.remainingTime,
    };

WatchlistResponse _$WatchlistResponseFromJson(Map<String, dynamic> json) =>
    WatchlistResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => WatchlistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
      stats: WatchlistStats.fromJson(json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WatchlistResponseToJson(WatchlistResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pagination': instance.pagination,
      'stats': instance.stats,
    };

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
      hasNext: json['hasNext'] as bool,
      hasPrev: json['hasPrev'] as bool,
    );

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
      'hasNext': instance.hasNext,
      'hasPrev': instance.hasPrev,
    };

WatchlistStats _$WatchlistStatsFromJson(Map<String, dynamic> json) =>
    WatchlistStats(
      totalMovies: json['totalMovies'] as int,
      totalTV: json['totalTV'] as int,
    );

Map<String, dynamic> _$WatchlistStatsToJson(WatchlistStats instance) =>
    <String, dynamic>{
      'totalMovies': instance.totalMovies,
      'totalTV': instance.totalTV,
    };

StreamResponse _$StreamResponseFromJson(Map<String, dynamic> json) =>
    StreamResponse(
      tmdbId: json['tmdbId'] as int,
      mediaType: json['mediaType'] as String,
      title: json['title'] as String,
      streamUrl: json['streamUrl'] as String,
      season: json['season'] as int?,
      episode: json['episode'] as int?,
    );

Map<String, dynamic> _$StreamResponseToJson(StreamResponse instance) =>
    <String, dynamic>{
      'tmdbId': instance.tmdbId,
      'mediaType': instance.mediaType,
      'title': instance.title,
      'streamUrl': instance.streamUrl,
      'season': instance.season,
      'episode': instance.episode,
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'avatar': instance.avatar,
    };

AddToWatchlistRequest _$AddToWatchlistRequestFromJson(
        Map<String, dynamic> json) =>
    AddToWatchlistRequest(
      tmdbId: json['tmdbId'] as int,
      mediaType: json['mediaType'] as String,
      title: json['title'] as String,
      posterPath: json['posterPath'] as String?,
    );

Map<String, dynamic> _$AddToWatchlistRequestToJson(
        AddToWatchlistRequest instance) =>
    <String, dynamic>{
      'tmdbId': instance.tmdbId,
      'mediaType': instance.mediaType,
      'title': instance.title,
      'posterPath': instance.posterPath,
    };

AddRatingRequest _$AddRatingRequestFromJson(Map<String, dynamic> json) =>
    AddRatingRequest(
      tmdbId: json['tmdbId'] as int,
      mediaType: json['mediaType'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      title: json['title'] as String,
      seasonNumber: json['seasonNumber'] as int?,
      episodeNumber: json['episodeNumber'] as int?,
    );

Map<String, dynamic> _$AddRatingRequestToJson(AddRatingRequest instance) =>
    <String, dynamic>{
      'tmdbId': instance.tmdbId,
      'mediaType': instance.mediaType,
      'rating': instance.rating,
      'comment': instance.comment,
      'title': instance.title,
      'seasonNumber': instance.seasonNumber,
      'episodeNumber': instance.episodeNumber,
    };

UpdateWatchHistoryRequest _$UpdateWatchHistoryRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateWatchHistoryRequest(
      tmdbId: json['tmdbId'] as int,
      mediaType: json['mediaType'] as String,
      title: json['title'] as String,
      posterPath: json['posterPath'] as String?,
      progress: json['progress'] as int,
      duration: json['duration'] as int?,
      completed: json['completed'] as bool,
      seasonNumber: json['seasonNumber'] as int?,
      episodeNumber: json['episodeNumber'] as int?,
    );

Map<String, dynamic> _$UpdateWatchHistoryRequestToJson(
        UpdateWatchHistoryRequest instance) =>
    <String, dynamic>{
      'tmdbId': instance.tmdbId,
      'mediaType': instance.mediaType,
      'title': instance.title,
      'posterPath': instance.posterPath,
      'progress': instance.progress,
      'duration': instance.duration,
      'completed': instance.completed,
      'seasonNumber': instance.seasonNumber,
      'episodeNumber': instance.episodeNumber,
    };
