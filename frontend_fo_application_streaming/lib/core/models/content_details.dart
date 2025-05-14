// lib/core/models/content_details.dart

import 'package:frontend_fo_application_streaming/core/models/content_item.dart';

class ContentDetails extends ContentItem {
  // Détails supplémentaires
  final String? cast;
  final List<Genre>? genres;
  final List<Media>? media;

  // Pour les séries
  final List<Season>? seasons;

  ContentDetails({
    required int id,
    required String title,
    required String description,
    String? posterUrl,
    String? backdropUrl,
    required double rating,
    required int releaseYear,
    String maturityRating = 'PG',
    bool isFeatured = false,
    String? videoUrl,
    String? trailerUrl,
    int viewCount = 0,
    required ContentType type,
    int? duration,
    String? director,
    String? creator,
    String? status,
    int? endYear,
    this.cast,
    this.genres,
    this.media,
    this.seasons,
  }) : super(
          id: id,
          title: title,
          description: description,
          posterUrl: posterUrl,
          backdropUrl: backdropUrl,
          rating: rating,
          releaseYear: releaseYear,
          maturityRating: maturityRating,
          isFeatured: isFeatured,
          videoUrl: videoUrl,
          trailerUrl: trailerUrl,
          viewCount: viewCount,
          type: type,
          duration: duration,
          director: director,
          creator: creator,
          status: status,
          endYear: endYear,
        );

  factory ContentDetails.fromJson(Map<String, dynamic> json, ContentType type) {
    // Debug pour voir la structure
    print('JSON data received: $json');

    return ContentDetails(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      posterUrl: json['posterUrl'],
      backdropUrl: json['backdropUrl'],
      rating: (json['ratingAVG'] ?? 0.0).toDouble(),
      releaseYear: json['releaseYear'] ?? 0,
      maturityRating: json['maturityRating'] ?? 'PG',
      isFeatured: json['isFeatured'] ?? false,
      videoUrl: json['videoUrl'],
      trailerUrl: json['trailerUrl'],
      viewCount: json['viewCount'] ?? 0,
      type: type,
      duration: json['duration'],
      director: json['director'],
      creator: json['creator'],
      status: json['status'],
      endYear: json['endYear'],
      cast: json['cast'],
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
      seasons: json['Seasons'] != null
          ? (json['Seasons'] as List)
              .map((season) => Season.fromJson(season))
              .toList()
          : null,
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

class Season {
  final int id;
  final int seriesId;
  final int seasonNumber;
  final String title;
  final String? description;
  final String? releaseDate;
  final String? posterUrl;
  final String? trailerUrl;
  final int episodeCount;
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
    this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] ?? 0,
      seriesId: json['seriesId'] ?? 0,
      seasonNumber: json['seasonNumber'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      releaseDate: json['releaseDate'],
      posterUrl: json['posterUrl'],
      trailerUrl: json['trailerUrl'],
      episodeCount: json['episodeCount'] ?? 0,
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
  final String? releaseDate;
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
      releaseDate: json['releaseDate'],
      viewCount: json['viewCount'] ?? 0,
    );
  }
}
