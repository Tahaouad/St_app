// lib/core/models/content_details.dart

import 'content_enums.dart';
import 'content_item.dart';

/// Modèle détaillé pour un contenu (film ou série)
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
  final int? duration; // en minutes pour les films
  final String? director; // pour les films
  final String? creator; // pour les séries
  final String? cast;
  final String? trailerUrl;
  final List<Season>? seasons; // pour les séries
  final List<ContentItem>? recommendations;
  final List<ContentItem>? similar;
  final String? status; // Released, In Production, etc.
  final String? originalLanguage;
  final List<String>? spokenLanguages;
  final List<String>? productionCountries;
  final List<ProductionCompany>? productionCompanies;
  final int? budget; // pour les films
  final int? revenue; // pour les films
  final String? homepage;
  final String? tagline;
  final List<String>? keywords;

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
    this.status,
    this.originalLanguage,
    this.spokenLanguages,
    this.productionCountries,
    this.productionCompanies,
    this.budget,
    this.revenue,
    this.homepage,
    this.tagline,
    this.keywords,
  });

  /// Factory pour créer ContentDetails depuis JSON API
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
      seasons:
          type == ContentType.series ? _extractSeasons(json['seasons']) : null,
      recommendations: _extractRecommendations(json['recommendations']),
      similar: _extractSimilar(json['similar']),
      status: json['status'],
      originalLanguage: json['original_language'],
      spokenLanguages: _extractSpokenLanguages(json['spoken_languages']),
      productionCountries:
          _extractProductionCountries(json['production_countries']),
      productionCompanies:
          _extractProductionCompanies(json['production_companies']),
      budget: json['budget'],
      revenue: json['revenue'],
      homepage: json['homepage'],
      tagline: json['tagline'],
      keywords: _extractKeywords(json['keywords']),
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'poster_url': posterUrl,
      'backdrop_url': backdropUrl,
      'rating': rating,
      'release_year': releaseYear,
      'type': type.apiValue,
      'genres': genres?.map((g) => g.toJson()).toList(),
      'duration': duration,
      'director': director,
      'creator': creator,
      'cast': cast,
      'trailer_url': trailerUrl,
      'seasons': seasons?.map((s) => s.toJson()).toList(),
      'status': status,
      'original_language': originalLanguage,
      'spoken_languages': spokenLanguages,
      'production_countries': productionCountries,
      'budget': budget,
      'revenue': revenue,
      'homepage': homepage,
      'tagline': tagline,
      'keywords': keywords,
    };
  }

  /// Durée formatée pour l'affichage
  String get displayDuration {
    if (duration == null) return '';
    final hours = duration! ~/ 60;
    final minutes = duration! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  /// Note formatée
  String get formattedRating => rating.toStringAsFixed(1);

  /// Année de sortie formatée
  String get formattedYear => releaseYear > 0 ? releaseYear.toString() : 'N/A';

  /// Genres formatés en string
  String get genresText {
    if (genres == null || genres!.isEmpty) return '';
    return genres!.map((g) => g.name).join(', ');
  }

  /// URL de l'image principale (backdrop ou poster)
  String? get primaryImageUrl => backdropUrl ?? posterUrl;

  /// Vérifie si le contenu a des saisons
  bool get hasSeasons => seasons != null && seasons!.isNotEmpty;

  /// Nombre total d'épisodes (pour les séries)
  int get totalEpisodes {
    if (seasons == null) return 0;
    return seasons!.fold(0, (total, season) => total + season.episodeCount);
  }

  /// Vérifie si le contenu a du contenu similaire
  bool get hasSimilarContent => similar != null && similar!.isNotEmpty;

  /// Vérifie si le contenu a des recommandations
  bool get hasRecommendations =>
      recommendations != null && recommendations!.isNotEmpty;

  // Méthodes statiques privées pour l'extraction de données

  static int _extractYear(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 0;
    try {
      return DateTime.parse(dateString).year;
    } catch (e) {
      return 0;
    }
  }

  static List<Genre>? _extractGenres(dynamic genres) {
    if (genres == null || genres is! List) return null;
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
    if (createdBy == null || createdBy is! List || createdBy.isEmpty)
      return null;
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
    if (recommendations == null || recommendations['results'] == null)
      return null;
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

  static List<String>? _extractSpokenLanguages(dynamic languages) {
    if (languages == null || languages is! List) return null;
    return languages
        .map<String>((lang) => lang['english_name'] ?? lang['name'] ?? '')
        .toList();
  }

  static List<String>? _extractProductionCountries(dynamic countries) {
    if (countries == null || countries is! List) return null;
    return countries.map<String>((country) => country['name'] ?? '').toList();
  }

  static List<ProductionCompany>? _extractProductionCompanies(
      dynamic companies) {
    if (companies == null || companies is! List) return null;
    return companies
        .map((company) => ProductionCompany.fromJson(company))
        .toList();
  }

  static List<String>? _extractKeywords(dynamic keywords) {
    if (keywords == null) return null;
    final keywordsList = keywords['keywords'] ?? keywords['results'] ?? [];
    if (keywordsList is! List) return null;
    return keywordsList
        .map<String>((keyword) => keyword['name'] ?? '')
        .toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentDetails &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ type.hashCode;
}

/// Modèle pour un genre
class Genre {
  final int id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Genre && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Modèle pour une saison
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'season_number': seasonNumber,
      'name': name,
      'overview': overview,
      'poster_path': posterPath,
      'air_date': airDate,
      'episode_count': episodeCount,
      'episodes': episodes?.map((e) => e.toJson()).toList(),
    };
  }

  /// Année de diffusion
  int get airYear {
    if (airDate == null || airDate!.isEmpty) return 0;
    try {
      return DateTime.parse(airDate!).year;
    } catch (e) {
      return 0;
    }
  }

  /// Vérifie si la saison a des épisodes
  bool get hasEpisodes => episodes != null && episodes!.isNotEmpty;
}

/// Modèle pour un épisode
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'episode_number': episodeNumber,
      'name': title,
      'overview': description,
      'still_path': thumbnailUrl,
      'air_date': airDate,
      'vote_average': rating,
      'runtime': duration,
      'video_url': videoUrl,
    };
  }

  /// Durée formatée
  String get formattedDuration => '${duration}min';

  /// Note formatée
  String get formattedRating => rating?.toStringAsFixed(1) ?? 'N/A';

  /// Vérifie si l'épisode a une URL vidéo YouTube
  bool get hasYoutubeVideo =>
      videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be');
}

/// Modèle pour une société de production
class ProductionCompany {
  final int id;
  final String name;
  final String? logoPath;
  final String? originCountry;

  ProductionCompany({
    required this.id,
    required this.name,
    this.logoPath,
    this.originCountry,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    return ProductionCompany(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logoPath: json['logo_path'],
      originCountry: json['origin_country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_path': logoPath,
      'origin_country': originCountry,
    };
  }
}

// Import nécessaire pour ContentItem (à ajouter en haut du fichier)
