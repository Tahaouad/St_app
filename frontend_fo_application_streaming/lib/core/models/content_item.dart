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
  final String? country; // pays d'origine
  final String? language; // langue originale
  final bool isAdult; // contenu pour adultes
  final int? voteCount; // nombre de votes
  final double? popularity; // score de popularité

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
    this.country,
    this.language,
    this.isAdult = false,
    this.voteCount,
    this.popularity,
  });

  /// Factory pour créer depuis JSON de votre API ou TMDB
  factory ContentItem.fromJson(Map<String, dynamic> json) {
    // Déterminer le type de contenu
    final mediaType = json['media_type'] ?? json['mediaType'];
    ContentType type;

    if (mediaType == 'movie') {
      type = ContentType.movie;
    } else if (mediaType == 'tv') {
      type = ContentType.series;
    } else {
      // Essayer de deviner à partir d'autres champs
      if (json['first_air_date'] != null || json['number_of_seasons'] != null) {
        type = ContentType.series;
      } else {
        type = ContentType.movie; // par défaut
      }
    }

    return ContentItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      description: json['overview'] ?? '',
      posterUrl: _buildImageUrl(json['poster_path'] ?? json['poster_url']),
      backdropUrl:
          _buildImageUrl(json['backdrop_path'] ?? json['backdrop_url']),
      rating: (json['vote_average'] ?? 0.0).toDouble(),
      releaseYear: _extractYear(json['release_date'] ?? json['first_air_date']),
      type: type,
      genres: _extractGenresFromJson(json['genres'] ?? json['genre_ids']),
      duration: json['runtime'],
      seasonCount: json['number_of_seasons'],
      director: _extractDirector(json),
      creator: _extractCreator(json),
      cast: _extractCast(json),
      country: _extractCountry(json),
      language: json['original_language'],
      isAdult: json['adult'] ?? false,
      voteCount: json['vote_count'],
      popularity: (json['popularity'] ?? 0.0).toDouble(),
    );
  }

  /// Factory pour créer à partir d'un film TMDB
  factory ContentItem.fromMovie(Map<String, dynamic> movie) {
    return ContentItem(
      id: movie['id'] ?? 0,
      title: movie['title'] ?? '',
      description: movie['overview'] ?? '',
      posterUrl: _buildImageUrl(movie['poster_path']),
      backdropUrl: _buildImageUrl(movie['backdrop_path']),
      rating: (movie['vote_average'] ?? 0.0).toDouble(),
      releaseYear: _extractYear(movie['release_date']),
      type: ContentType.movie,
      genres: _extractGenresFromIds(movie['genre_ids']),
      duration: movie['runtime'],
      country: _extractCountry(movie),
      language: movie['original_language'],
      isAdult: movie['adult'] ?? false,
      voteCount: movie['vote_count'],
      popularity: (movie['popularity'] ?? 0.0).toDouble(),
    );
  }

  /// Factory pour créer à partir d'une série TMDB
  factory ContentItem.fromTVShow(Map<String, dynamic> tvShow) {
    return ContentItem(
      id: tvShow['id'] ?? 0,
      title: tvShow['name'] ?? tvShow['title'] ?? '',
      description: tvShow['overview'] ?? '',
      posterUrl: _buildImageUrl(tvShow['poster_path']),
      backdropUrl: _buildImageUrl(tvShow['backdrop_path']),
      rating: (tvShow['vote_average'] ?? 0.0).toDouble(),
      releaseYear: _extractYear(tvShow['first_air_date']),
      type: ContentType.series,
      genres: _extractGenresFromIds(tvShow['genre_ids']),
      seasonCount: tvShow['number_of_seasons'],
      creator: _extractCreator(tvShow),
      country: _extractCountry(tvShow),
      language: tvShow['original_language'],
      isAdult: false, // Les séries TV n'ont généralement pas ce flag
      voteCount: tvShow['vote_count'],
      popularity: (tvShow['popularity'] ?? 0.0).toDouble(),
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
      'media_type': type.apiValue,
      'genres': genres,
      'duration': duration,
      'season_count': seasonCount,
      'director': director,
      'creator': creator,
      'cast': cast,
      'country': country,
      'language': language,
      'is_adult': isAdult,
      'vote_count': voteCount,
      'popularity': popularity,
    };
  }

  // Getters utilitaires

  /// Titre d'affichage (pour compatibilité)
  String get displayTitle => title;

  /// Note formatée avec une décimale
  String get formattedRating => rating.toStringAsFixed(1);

  /// Durée formatée pour l'affichage
  String get formattedDuration {
    if (duration == null) return '';
    final hours = duration! ~/ 60;
    final minutes = duration! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  /// Année de sortie formatée
  String get formattedYear => releaseYear > 0 ? releaseYear.toString() : 'N/A';

  /// Genres sous forme de chaîne
  String get genresString => genres.join(', ');

  /// Vérifier si le contenu a une affiche valide
  bool get hasValidPoster => posterUrl != null && posterUrl!.isNotEmpty;

  /// Vérifier si le contenu a une image de fond valide
  bool get hasValidBackdrop => backdropUrl != null && backdropUrl!.isNotEmpty;

  /// Obtenir la meilleure image disponible
  String? get bestImageUrl =>
      hasValidPoster ? posterUrl : (hasValidBackdrop ? backdropUrl : null);

  /// Vérifier si c'est un nouveau contenu (sorti cette année)
  bool get isNew => releaseYear == DateTime.now().year;

  /// Vérifier si c'est un contenu récent (moins de 2 ans)
  bool get isRecent => DateTime.now().year - releaseYear <= 2;

  /// Obtenir le score de popularité formaté
  String get formattedPopularity =>
      popularity != null ? popularity!.toStringAsFixed(1) : 'N/A';

  /// Vérifier si c'est un contenu populaire (rating > 7.0)
  bool get isPopular => rating >= 7.0;

  /// Vérifier si c'est un contenu très bien noté (rating > 8.0)
  bool get isHighlyRated => rating >= 8.0;

  /// Obtenir une description tronquée
  String getShortDescription({int maxLength = 100}) {
    if (description.length <= maxLength) return description;
    return '${description.substring(0, maxLength)}...';
  }

  /// Obtenir l'âge du contenu en années
  int get ageInYears => DateTime.now().year - releaseYear;

  /// Statut de sortie
  String get releaseStatus {
    final currentYear = DateTime.now().year;
    if (releaseYear > currentYear) return 'À venir';
    if (releaseYear == currentYear) return 'Nouveau';
    if (currentYear - releaseYear <= 1) return 'Récent';
    return 'Disponible';
  }

  // Méthodes statiques pour l'extraction des données

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

  static List<String> _extractGenresFromIds(List<dynamic>? genreIds) {
    if (genreIds == null || genreIds.isEmpty) return [];

    // Mapping basique des IDs de genres TMDB les plus courants
    const genreMap = {
      28: 'Action',
      12: 'Aventure',
      16: 'Animation',
      35: 'Comédie',
      80: 'Crime',
      99: 'Documentaire',
      18: 'Drame',
      10751: 'Familial',
      14: 'Fantasy',
      36: 'Histoire',
      27: 'Horreur',
      10402: 'Musique',
      9648: 'Mystère',
      10749: 'Romance',
      878: 'Science-Fiction',
      10770: 'Téléfilm',
      53: 'Thriller',
      10752: 'Guerre',
      37: 'Western',
      10759: 'Action & Adventure',
      10762: 'Enfants',
      10763: 'News',
      10764: 'Reality',
      10765: 'Sci-Fi & Fantasy',
      10766: 'Soap',
      10767: 'Talk',
      10768: 'War & Politics',
    };

    return genreIds
        .map((id) => genreMap[id] ?? 'Inconnu')
        .where((genre) => genre != 'Inconnu')
        .toList();
  }

  static String? _extractDirector(Map<String, dynamic> json) {
    // Pour les données détaillées avec crédits
    if (json['credits'] != null && json['credits']['crew'] != null) {
      for (var crew in json['credits']['crew']) {
        if (crew['job'] == 'Director') {
          return crew['name'];
        }
      }
    }
    return null;
  }

  static String? _extractCreator(Map<String, dynamic> json) {
    if (json['created_by'] != null &&
        json['created_by'] is List &&
        json['created_by'].isNotEmpty) {
      return json['created_by'][0]['name'];
    }
    return null;
  }

  static List<String>? _extractCast(Map<String, dynamic> json) {
    if (json['credits'] != null && json['credits']['cast'] != null) {
      final List<String> castNames = [];
      for (var i = 0; i < json['credits']['cast'].length && i < 5; i++) {
        castNames.add(json['credits']['cast'][i]['name']);
      }
      return castNames.isNotEmpty ? castNames : null;
    }
    return null;
  }

  static String? _extractCountry(Map<String, dynamic> json) {
    // Pour les films
    if (json['production_countries'] != null &&
        json['production_countries'] is List &&
        json['production_countries'].isNotEmpty) {
      return json['production_countries'][0]['name'];
    }
    // Pour les séries
    if (json['origin_country'] != null &&
        json['origin_country'] is List &&
        json['origin_country'].isNotEmpty) {
      return json['origin_country'][0];
    }
    return null;
  }

  static String? _buildImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;

    // Si c'est déjà une URL complète, la retourner telle quelle
    if (path.startsWith('http')) return path;

    // Sinon, construire l'URL TMDB
    return 'https://image.tmdb.org/t/p/w500$path';
  }

  // Méthodes de comparaison et tri

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ type.hashCode;

  @override
  String toString() => '$title (${type.displayName}, $formattedYear)';

  /// Comparer par note (pour le tri)
  int compareByRating(ContentItem other) => other.rating.compareTo(rating);

  /// Comparer par année de sortie (pour le tri)
  int compareByYear(ContentItem other) =>
      other.releaseYear.compareTo(releaseYear);

  /// Comparer par popularité (pour le tri)
  int compareByPopularity(ContentItem other) {
    if (popularity == null && other.popularity == null) return 0;
    if (popularity == null) return 1;
    if (other.popularity == null) return -1;
    return other.popularity!.compareTo(popularity!);
  }

  /// Comparer par titre (pour le tri alphabétique)
  int compareByTitle(ContentItem other) => title.compareTo(other.title);

  /// Créer une copie avec des modifications
  ContentItem copyWith({
    int? id,
    String? title,
    String? description,
    String? posterUrl,
    String? backdropUrl,
    double? rating,
    int? releaseYear,
    ContentType? type,
    List<String>? genres,
    int? duration,
    int? seasonCount,
    String? director,
    String? creator,
    List<String>? cast,
    String? country,
    String? language,
    bool? isAdult,
    int? voteCount,
    double? popularity,
  }) {
    return ContentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      rating: rating ?? this.rating,
      releaseYear: releaseYear ?? this.releaseYear,
      type: type ?? this.type,
      genres: genres ?? this.genres,
      duration: duration ?? this.duration,
      seasonCount: seasonCount ?? this.seasonCount,
      director: director ?? this.director,
      creator: creator ?? this.creator,
      cast: cast ?? this.cast,
      country: country ?? this.country,
      language: language ?? this.language,
      isAdult: isAdult ?? this.isAdult,
      voteCount: voteCount ?? this.voteCount,
      popularity: popularity ?? this.popularity,
    );
  }
}

/// Extensions utilitaires pour les listes de ContentItem
extension ContentItemListExtensions on List<ContentItem> {
  /// Filtrer par type de contenu
  List<ContentItem> filterByType(ContentType type) {
    return where((item) => item.type == type).toList();
  }

  /// Filtrer par note minimale
  List<ContentItem> filterByMinRating(double minRating) {
    return where((item) => item.rating >= minRating).toList();
  }

  /// Filtrer par année
  List<ContentItem> filterByYear(int year) {
    return where((item) => item.releaseYear == year).toList();
  }

  /// Filtrer par genre
  List<ContentItem> filterByGenre(String genre) {
    return where((item) => item.genres.contains(genre)).toList();
  }

  /// Obtenir les films uniquement
  List<ContentItem> get movies => filterByType(ContentType.movie);

  /// Obtenir les séries uniquement
  List<ContentItem> get series => filterByType(ContentType.series);

  /// Obtenir les documentaires uniquement
  List<ContentItem> get documentaries => filterByType(ContentType.documentary);

  /// Obtenir les contenus récents (moins de 2 ans)
  List<ContentItem> get recent {
    final currentYear = DateTime.now().year;
    return where((item) => currentYear - item.releaseYear <= 2).toList();
  }

  /// Obtenir les contenus populaires (note >= 7.0)
  List<ContentItem> get popular => filterByMinRating(7.0);

  /// Obtenir les contenus très bien notés (note >= 8.0)
  List<ContentItem> get highlyRated => filterByMinRating(8.0);

  /// Trier par note (décroissant)
  List<ContentItem> sortByRating() {
    return [...this]..sort((a, b) => b.rating.compareTo(a.rating));
  }

  /// Trier par année (décroissant)
  List<ContentItem> sortByYear() {
    return [...this]..sort((a, b) => b.releaseYear.compareTo(a.releaseYear));
  }

  /// Trier par popularité (décroissant)
  List<ContentItem> sortByPopularity() {
    return [...this]..sort((a, b) {
        if (a.popularity == null && b.popularity == null) return 0;
        if (a.popularity == null) return 1;
        if (b.popularity == null) return -1;
        return b.popularity!.compareTo(a.popularity!);
      });
  }

  /// Trier par titre (alphabétique)
  List<ContentItem> sortByTitle() {
    return [...this]..sort((a, b) => a.title.compareTo(b.title));
  }

  /// Obtenir une sélection aléatoire
  List<ContentItem> randomSelection({int count = 5}) {
    final shuffled = [...this]..shuffle();
    return shuffled.take(count).toList();
  }

  /// Rechercher dans les titres et descriptions
  List<ContentItem> search(String query) {
    final lowerQuery = query.toLowerCase();
    return where((item) =>
        item.title.toLowerCase().contains(lowerQuery) ||
        item.description.toLowerCase().contains(lowerQuery) ||
        item.genres
            .any((genre) => genre.toLowerCase().contains(lowerQuery))).toList();
  }

  /// Obtenir tous les genres uniques
  Set<String> get allGenres {
    final genres = <String>{};
    for (final item in this) {
      genres.addAll(item.genres);
    }
    return genres;
  }

  /// Obtenir toutes les années uniques
  Set<int> get allYears {
    return map((item) => item.releaseYear).where((year) => year > 0).toSet();
  }

  /// Statistiques de la collection
  Map<String, dynamic> get stats {
    if (isEmpty) {
      return {
        'total': 0,
        'movies': 0,
        'series': 0,
        'documentaries': 0,
        'averageRating': 0.0,
        'totalDuration': 0,
      };
    }

    final movieCount = movies.length;
    final seriesCount = series.length;
    final documentaryCount = documentaries.length;
    final avgRating =
        map((item) => item.rating).reduce((a, b) => a + b) / length;
    final totalDuration = where((item) => item.duration != null)
        .map((item) => item.duration!)
        .fold(0, (sum, duration) => sum + duration);

    return {
      'total': length,
      'movies': movieCount,
      'series': seriesCount,
      'documentaries': documentaryCount,
      'averageRating': avgRating,
      'totalDuration': totalDuration,
      'totalHours': (totalDuration / 60).toStringAsFixed(1),
    };
  }
}
