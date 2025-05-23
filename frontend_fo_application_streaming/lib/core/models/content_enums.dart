// lib/core/models/content_enums.dart

enum ContentType {
  movie,
  series,
  documentary,
  shortFilm;

  /// Nom d'affichage localisé
  String get displayName {
    switch (this) {
      case ContentType.movie:
        return 'Film';
      case ContentType.series:
        return 'Série';
      case ContentType.documentary:
        return 'Documentaire';
      case ContentType.shortFilm:
        return 'Court métrage';
    }
  }

  /// Valeur pour les appels API (compatible TMDB)
  String get apiValue {
    switch (this) {
      case ContentType.movie:
        return 'movie';
      case ContentType.series:
        return 'tv';
      case ContentType.documentary:
        return 'documentary';
      case ContentType.shortFilm:
        return 'short';
    }
  }

  /// Icône représentative du type de contenu
  String get icon {
    switch (this) {
      case ContentType.movie:
        return '🎬';
      case ContentType.series:
        return '📺';
      case ContentType.documentary:
        return '🎥';
      case ContentType.shortFilm:
        return '🎞️';
    }
  }

  /// Créer un ContentType à partir d'une string API
  static ContentType? fromApiValue(String? value) {
    if (value == null) return null;

    switch (value.toLowerCase()) {
      case 'movie':
        return ContentType.movie;
      case 'tv':
      case 'series':
        return ContentType.series;
      case 'documentary':
        return ContentType.documentary;
      case 'short':
      case 'shortfilm':
        return ContentType.shortFilm;
      default:
        return null;
    }
  }

  /// Créer un ContentType à partir d'un nom d'affichage
  static ContentType? fromDisplayName(String? name) {
    if (name == null) return null;

    switch (name.toLowerCase()) {
      case 'film':
        return ContentType.movie;
      case 'série':
        return ContentType.series;
      case 'documentaire':
        return ContentType.documentary;
      case 'court métrage':
        return ContentType.shortFilm;
      default:
        return null;
    }
  }

  /// Vérifier si le type de contenu a des saisons/épisodes
  bool get hasEpisodes {
    switch (this) {
      case ContentType.series:
        return true;
      case ContentType.movie:
      case ContentType.documentary:
      case ContentType.shortFilm:
        return false;
    }
  }

  /// Obtenir l'unité de durée appropriée
  String get durationUnit {
    switch (this) {
      case ContentType.movie:
      case ContentType.documentary:
        return 'minutes';
      case ContentType.series:
        return 'épisodes';
      case ContentType.shortFilm:
        return 'minutes';
    }
  }
}

/// Extensions additionnelles pour ContentType
extension ContentTypeExtensions on ContentType {
  /// Couleur thématique pour l'UI
  int get colorValue {
    switch (this) {
      case ContentType.movie:
        return 0xFFE50914; // Rouge Netflix
      case ContentType.series:
        return 0xFF00BCD4; // Cyan
      case ContentType.documentary:
        return 0xFF4CAF50; // Vert
      case ContentType.shortFilm:
        return 0xFFFF9800; // Orange
    }
  }

  /// Préfixe pour les IDs uniques
  String get idPrefix {
    switch (this) {
      case ContentType.movie:
        return 'mv';
      case ContentType.series:
        return 'sr';
      case ContentType.documentary:
        return 'dc';
      case ContentType.shortFilm:
        return 'sf';
    }
  }
}
