enum ContentType { movie, series }

class ContentItem {
  final int id;
  final String title;
  final String description;
  final String? posterUrl;
  final String? backdropUrl;
  final double rating;
  final int releaseYear;
  final String maturityRating;
  final bool isFeatured;
  final String? videoUrl;
  final String? trailerUrl;
  final int viewCount;

  // Pour distinguer entre films et séries
  final ContentType type;

  // Spécifique aux films
  final int? duration;
  final String? director;

  // Spécifique aux séries
  final String? creator;
  final String? status;
  final int? endYear;

  ContentItem({
    required this.id,
    required this.title,
    required this.description,
    this.posterUrl,
    this.backdropUrl,
    required this.rating,
    required this.releaseYear,
    this.maturityRating = 'PG',
    this.isFeatured = false,
    this.videoUrl,
    this.trailerUrl,
    this.viewCount = 0,
    required this.type,
    this.duration,
    this.director,
    this.creator,
    this.status,
    this.endYear,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json, {ContentType? type}) {
    // Déterminer le type de contenu si non fourni
    if (type == null) {
      if (json.containsKey('duration') &&
          json['duration'] != null &&
          json.containsKey('director')) {
        type = ContentType.movie;
      } else if (json.containsKey('creator') || json.containsKey('status')) {
        type = ContentType.series;
      } else {
        // Par défaut, on considère que c'est un film
        type = ContentType.movie;
      }
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
    );
  }

  String get displayType {
    switch (type) {
      case ContentType.movie:
        return 'Film';
      case ContentType.series:
        return 'Série';
    }
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
