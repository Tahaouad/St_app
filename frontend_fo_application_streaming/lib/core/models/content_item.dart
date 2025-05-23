// lib/core/models/content_item.dart

import 'content_enums.dart';

class ContentItem {
  final int id;
  final String title;
  final String description;
  final String? posterUrl;
  final String? backdropUrl;
  final double rating;
  final int releaseYear;
  final ContentType type;
  final List<String> genres;
  final int? duration; // en minutes pour les films
  final int? seasonCount; // pour les séries
  final String? director;
  final String? creator;
  final List<String>? cast;

  ContentItem({
    required this.id,
    required this.title,
    required this.description,
    this.posterUrl,
    this.backdropUrl,
    required this.rating,
    required this.releaseYear,
    required this.type,
    this.genres = const [],
    this.duration,
    this.seasonCount,
    this.director,
    this.creator,
    this.cast,
  });

  // Factory pour créer depuis JSON de votre API
  factory ContentItem.fromJson(Map<String, dynamic> json) {
    final mediaType = json['media_type'] ?? json['mediaType'];
    ContentType type;
    
    if (mediaType == 'movie') {
      type = ContentType.movie;
    } else if (mediaType == 'tv') {
      type = ContentType.series;
    } else {
      type = ContentType.movie; // par défaut
    }

    return ContentItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      description: json['overview'] ?? '',
      posterUrl: json['poster_url'] ?? json['poster_path'],
      backdropUrl: json['backdrop_url'] ?? json['backdrop_path'],
      rating: (json['vote_average'] ?? 0.0).toDouble(),
      releaseYear: _extractYear(json['release_date'] ?? json['first_air_date']),
      type: type,
      genres: _extractGenresFromJson(json['genres'] ?? json['genre_ids']),
      duration: json['runtime'],
      seasonCount: json['number_of_seasons'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'poster_url': posterUrl,
      'backdrop_url': backdropUrl,
      'rating': rating,
      'release_year': releaseYear,
      'media_type': type == ContentType.movie ? 'movie' : 'tv',
      'genres': genres,
      'duration': duration,
      'season_count': seasonCount,
    };
  }

  static int _extractYear(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 0;
    try {
      return DateTime.parse(dateString).year;
    } catch (e) {
      return 0;
    }
  }

  static List<String> _extractGenresFromJson(dynamic genres) {
    if (genres == null) return [];
    
    if (genres is List) {
      return genres.map((g) {
        if (g is Map<String, dynamic> && g['name'] != null) {
          return g['name'].toString();
        }
        return g.toString();
      }).toList();
    }
    
    return [];
  }

  // Getters utilitaires
  String get displayTitle => title;
  String get formattedRating => rating.toStringAsFixed(1);
  String get formattedDuration {
    if (duration == null) return '';
    final hours = duration! ~/ 60;
    final minutes = duration! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  bool get hasValidPoster => posterUrl != null && posterUrl!.isNotEmpty;
  bool get hasValidBackdrop => backdropUrl != null && backdropUrl!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ type.hashCode;
}

// lib/core/models/content_enums.dart

enum ContentType {
  movie,
  series,
}

extension ContentTypeExtension on ContentType {
  String get name {
    switch (this) {
      case ContentType.movie:
        return 'Film';
      case ContentType.series:
        return 'Série';
    }
  }

  String get apiValue {
    switch (this) {
      case ContentType.movie:
        return 'movie';
      case ContentType.series:
        return 'tv';
    }
  }
}

// lib/core/models/content_details.dart

import 'content_enums.dart';

class ContentDetails {
  final int id;
  final String title;
  final String description;
  final String? posterUrl;
  final String? backdropUrl;
  final double rating;
  final int releaseYear;
  final ContentType type;
  final List<Genre>? genres;
  final int? duration; // pour les films
  final String? director; // pour les films
  final String? creator; // pour les séries
  final String? cast;
  final String? trailerUrl;
  final List<Season>? seasons; // pour les séries
  final List<ContentItem>? recommendations;
  final List<ContentItem>? similar;

  ContentDetails({
    required this.id,
    required this.title,
    required this.description,
    this.posterUrl,
    this.backdropUrl,
    required this.rating,
    required this.releaseYear,
    required this.type,
    this.genres,
    this.duration,
    this.director,
    this.creator,
    this.cast,
    this.trailerUrl,
    this.seasons,
    this.recommendations,
    this.similar,
  });

  factory ContentDetails.fromJson(Map<String, dynamic> json, ContentType type) {
    return ContentDetails(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      description: json['overview'] ?? '',
      posterUrl: json['poster_url'],
      backdropUrl: json['backdrop_url'],
      rating: (json['vote_average'] ?? 0.0).toDouble(),
      releaseYear: _extractYear(json['release_date'] ?? json['first_air_date']),
      type: type,
      genres: _extractGenres(json['genres']),
      duration: json['runtime'],
      director: _extractDirector(json['credits']),
      creator: _extractCreator(json['created_by']),
      cast: _extractCast(json['credits']),
      trailerUrl: _extractTrailerUrl(json['videos']),
      seasons: type == ContentType.series ? _extractSeasons(json['seasons']) : null,
      recommendations: _extractRecommendations(json['recommendations']),
      similar: _extractSimilar(json['similar']),
    );
  }

  String get displayDuration {
    if (duration == null) return '';
    final hours = duration! ~/ 60;
    final minutes = duration! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  static int _extractYear(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 0;
    try {
      return DateTime.parse(dateString).year;
    } catch (e) {
      return 0;
    }
  }

  static List<Genre>? _extractGenres(dynamic genres) {
    if (genres == null) return null;
    if (genres is! List) return null;
    
    return genres.map((g) => Genre.fromJson(g)).toList();
  }

  static String? _extractDirector(dynamic credits) {
    if (credits == null || credits['crew'] == null) return null;
    
    for (var crew in credits['crew']) {
      if (crew['job'] == 'Director') {
        return crew['name'];
      }
    }
    return null;
  }

  static String? _extractCreator(dynamic createdBy) {
    if (createdBy == null || createdBy is! List || createdBy.isEmpty) return null;
    return createdBy[0]['name'];
  }

  static String? _extractCast(dynamic credits) {
    if (credits == null || credits['cast'] == null) return null;
    
    final List<String> castNames = [];
    for (var i = 0; i < credits['cast'].length && i < 5; i++) {
      castNames.add(credits['cast'][i]['name']);
    }
    return castNames.join(', ');
  }

  static String? _extractTrailerUrl(dynamic videos) {
    if (videos == null || videos['results'] == null) return null;
    
    for (var video in videos['results']) {
      if (video['type'] == 'Trailer' && video['site'] == 'YouTube') {
        return 'https://www.youtube.com/watch?v=${video['key']}';
      }
    }
    return null;
  }

  static List<Season>? _extractSeasons(dynamic seasons) {
    if (seasons == null || seasons is! List) return null;
    
    return seasons.map((s) => Season.fromJson(s)).toList();
  }

  static List<ContentItem>? _extractRecommendations(dynamic recommendations) {
    if (recommendations == null || recommendations['results'] == null) return null;
    
    return (recommendations['results'] as List)
        .take(10)
        .map((item) => ContentItem.fromJson(item))
        .toList();
  }

  static List<ContentItem>? _extractSimilar(dynamic similar) {
    if (similar == null || similar['results'] == null) return null;
    
    return (similar['results'] as List)
        .take(10)
        .map((item) => ContentItem.fromJson(item))
        .toList();
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Season {
  final int id;
  final int seasonNumber;
  final String name;
  final String? overview;
  final String? posterPath;
  final String? airDate;
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

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] ?? 0,
      seasonNumber: json['season_number'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'],
      posterPath: json['poster_path'],
      airDate: json['air_date'],
      episodeCount: json['episode_count'] ?? 0,
      episodes: json['episodes'] != null
          ? (json['episodes'] as List).map((e) => Episode.fromJson(e)).toList()
          : null,
    );
  }
}

class Episode {
  final int id;
  final int episodeNumber;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? airDate;
  final double? rating;
  final int duration; // en minutes
  final String videoUrl; // URL de la vidéo

  Episode({
    required this.id,
    required this.episodeNumber,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.airDate,
    this.rating,
    required this.duration,
    required this.videoUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? 0,
      episodeNumber: json['episode_number'] ?? 0,
      title: json['name'] ?? '',
      description: json['overview'],
      thumbnailUrl: json['still_path'],
      airDate: json['air_date'],
      rating: (json['vote_average'] ?? 0.0).toDouble(),
      duration: json['runtime'] ?? 45, // durée par défaut
      videoUrl: json['video_url'] ?? '', // À adapter selon votre API
    );
  }
}