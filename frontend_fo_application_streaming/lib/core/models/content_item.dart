import 'package:frontend_fo_application_streaming/core/models/content_enums.dart';

class ContentItem {
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
  final bool isFeatured;

  ContentItem({
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
    this.isFeatured = false,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    // Déterminer le type basé sur la présence de certains champs
    ContentType type = ContentType.movie;
    if (json.containsKey('Seasons') || json.containsKey('creator')) {
      type = ContentType.series;
    }

    return ContentItem(
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
      isFeatured: json['isFeatured'] ?? false,
    );
  }
}
