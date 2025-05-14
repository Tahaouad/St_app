import 'package:frontend_fo_application_streaming/core/models/content_enums.dart';

class ContentDetails {
  final int id;
  final String title;
  final String description;
  final String? posterUrl;
  final String? backdropUrl;
  final double rating;
  final int releaseYear;
  final String maturityRating;
  final String? trailerUrl;
  final String? videoUrl;
  final int viewCount;
  final ContentType type;

  // Spécifique aux films
  final int? duration;
  final String? director;
  final String? cast;

  // Spécifique aux séries
  final String? creator;
  final String? status;
  final int? endYear;
  final List<Season>? seasons;

  // Genres
  final List<Genre>? genres;

  // Media
  final List<Media>? media;

  ContentDetails({
    required this.id,
    required this.title,
    required this.description,
    this.posterUrl,
    this.backdropUrl,
    required this.rating,
    required this.releaseYear,
    this.maturityRating = 'PG',
    this.trailerUrl,
    this.videoUrl,
    this.viewCount = 0,
    required this.type,
    this.duration,
    this.director,
    this.cast,
    this.creator,
    this.status,
    this.endYear,
    this.seasons,
    this.genres,
    this.media,
  });

  factory ContentDetails.fromJson(Map<String, dynamic> json, ContentType type) {
    return ContentDetails(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      posterUrl: json['posterUrl'],
      backdropUrl: json['backdropUrl'],
      rating: (json['ratingAVG'] ?? 0.0).toDouble(),
      releaseYear: json['releaseYear'] ?? 0,
      maturityRating: json['maturityRating'] ?? 'PG',
      trailerUrl: json['trailerUrl'],
      videoUrl: json['videoUrl'],
      viewCount: json['viewCount'] ?? 0,
      type: type,
      duration: json['duration'],
      director: json['director'],
      cast: json['cast'],
      creator: json['creator'],
      status: json['status'],
      endYear: json['endYear'],
      seasons: json['Seasons'] != null
          ? (json['Seasons'] as List)
              .map((season) => Season.fromJson(season))
              .toList()
          : null,
      genres: json['Genres'] != null
          ? (json['Genres'] as List)
              .map((genre) => Genre.fromJson(genre))
              .toList()
          : null,
      media: json['Media'] != null
          ? (json['Media'] as List)
              .map((media) => Media.fromJson(media))
              .toList()
          : null,
    );
  }

  String get displayDuration {
    if (type == ContentType.movie && duration != null) {
      final hours = duration! ~/ 60;
      final minutes = duration! % 60;
      return '${hours}h ${minutes}min';
    }
    return '';
  }
}

class Season {
  final int id;
  final int seriesId;
  final int seasonNumber;
  final String title;
  final String? description;
  final DateTime? releaseDate;
  final String? posterUrl;
  final String? trailerUrl;
  final int episodeCount;
  final bool isActive;
  final List<Episode>? episodes;

  Season({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    required this.title,
    this.description,
    this.releaseDate,
    this.posterUrl,
    this.trailerUrl,
    this.episodeCount = 0,
    this.isActive = true,
    this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] ?? 0,
      seriesId: json['seriesId'] ?? 0,
      seasonNumber: json['seasonNumber'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      releaseDate: json['releaseDate'] != null
          ? DateTime.parse(json['releaseDate'])
          : null,
      posterUrl: json['posterUrl'],
      trailerUrl: json['trailerUrl'],
      episodeCount: json['episodeCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      episodes: json['Episodes'] != null
          ? (json['Episodes'] as List)
              .map((episode) => Episode.fromJson(episode))
              .toList()
          : null,
    );
  }
}

class Episode {
  final int id;
  final int seasonId;
  final String title;
  final String? description;
  final int duration;
  final int episodeNumber;
  final String videoUrl;
  final String? thumbnailUrl;
  final DateTime? releaseDate;
  final bool isActive;
  final int viewCount;

  Episode({
    required this.id,
    required this.seasonId,
    required this.title,
    this.description,
    required this.duration,
    required this.episodeNumber,
    required this.videoUrl,
    this.thumbnailUrl,
    this.releaseDate,
    this.isActive = true,
    this.viewCount = 0,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? 0,
      seasonId: json['seasonId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      duration: json['duration'] ?? 0,
      episodeNumber: json['episodeNumber'] ?? 0,
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      releaseDate: json['releaseDate'] != null
          ? DateTime.parse(json['releaseDate'])
          : null,
      isActive: json['isActive'] ?? true,
      viewCount: json['viewCount'] ?? 0,
    );
  }
}

class Genre {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;

  Genre({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}

class Media {
  final int id;
  final String url;
  final String type;
  final String? title;
  final String? description;
  final bool isDefault;

  Media({
    required this.id,
    required this.url,
    required this.type,
    this.title,
    this.description,
    this.isDefault = false,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
      type: json['type'] ?? '',
      title: json['title'],
      description: json['description'],
      isDefault: json['isDefault'] ?? false,
    );
  }
}
