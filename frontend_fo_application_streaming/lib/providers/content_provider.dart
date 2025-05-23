// lib/data/providers/content_provider.dart

import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';
import '../../core/models/content_item.dart';

class ContentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // États de chargement
  bool _isLoading = false;
  String? _error;

  // Collections de contenu
  List<ContentItem> _featuredContent = [];
  List<ContentItem> _popularContent = [];
  List<ContentItem> _trendingContent = [];
  List<ContentItem> _newReleases = [];
  List<ContentItem> _recommendedContent = [];
  List<ContentItem> _movies = [];
  List<ContentItem> _series = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ContentItem> get featuredContent => _featuredContent;
  List<ContentItem> get popularContent => _popularContent;
  List<ContentItem> get trendingContent => _trendingContent;
  List<ContentItem> get newReleases => _newReleases;
  List<ContentItem> get recommendedContent => _recommendedContent;
  List<ContentItem> get movies => _movies;
  List<ContentItem> get series => _series;

  // Charger tout le contenu
  Future<void> loadAllContent() async {
    try {
      _setLoading(true);
      _clearError();

      await Future.wait([
        _loadPopularContent(),
        _loadTrendingContent(),
        loadMovies(),
        loadSeries(),
        _loadUpcoming(),
      ]);

      // Créer le contenu featured à partir du trending
      _createFeaturedContent();
    } catch (error) {
      _setError('Erreur lors du chargement du contenu: ${error.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Charger le contenu populaire
  Future<void> _loadPopularContent() async {
    try {
      // Charger films et séries populaires
      final [moviesResponse, tvResponse] = await Future.wait([
        _apiService.getPopularMovies(page: 1),
        _apiService.getPopularTV(page: 1),
      ]);

      final List<ContentItem> popularItems = [];

      // Traiter les films populaires
      if (moviesResponse['results'] != null) {
        for (var item in moviesResponse['results']) {
          popularItems.add(_createContentItemFromMovie(item));
        }
      }

      // Traiter les séries populaires
      if (tvResponse['results'] != null) {
        for (var item in tvResponse['results']) {
          popularItems.add(_createContentItemFromTV(item));
        }
      }

      // Mélanger et limiter
      popularItems.shuffle();
      _popularContent = popularItems.take(20).toList();
    } catch (error) {
      print('Erreur chargement contenu populaire: $error');
    }
  }

  // Charger le contenu trending
  Future<void> _loadTrendingContent() async {
    try {
      final response = await _apiService.getTrending(
        type: 'all',
        time: 'day',
        page: 1,
      );

      final List<ContentItem> trendingItems = [];

      if (response['results'] != null) {
        for (var item in response['results']) {
          if (item['media_type'] == 'movie') {
            trendingItems.add(_createContentItemFromMovie(item));
          } else if (item['media_type'] == 'tv') {
            trendingItems.add(_createContentItemFromTV(item));
          }
        }
      }

      _trendingContent = trendingItems.take(20).toList();
    } catch (error) {
      print('Erreur chargement trending: $error');
    }
  }

  // Charger les films
  Future<void> loadMovies() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiService.getPopularMovies(page: 1);
      final List<ContentItem> movieItems = [];

      if (response['results'] != null) {
        for (var item in response['results']) {
          movieItems.add(_createContentItemFromMovie(item));
        }
      }

      _movies = movieItems;
    } catch (error) {
      _setError('Erreur lors du chargement des films: ${error.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Charger les séries
  Future<void> loadSeries() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiService.getPopularTV(page: 1);
      final List<ContentItem> seriesItems = [];

      if (response['results'] != null) {
        for (var item in response['results']) {
          seriesItems.add(_createContentItemFromTV(item));
        }
      }

      _series = seriesItems;
    } catch (error) {
      _setError('Erreur lors du chargement des séries: ${error.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Charger les nouveautés
  Future<void> _loadUpcoming() async {
    try {
      final response = await _apiService.getUpcoming(page: 1);
      final List<ContentItem> upcomingItems = [];

      if (response['results'] != null) {
        for (var item in response['results']) {
          upcomingItems.add(_createContentItemFromMovie(item));
        }
      }

      _newReleases = upcomingItems.take(15).toList();

      // Créer du contenu recommandé à partir du top rated
      await _loadRecommended();
    } catch (error) {
      print('Erreur chargement upcoming: $error');
    }
  }

  // Charger le contenu recommandé
  Future<void> _loadRecommended() async {
    try {
      final response = await _apiService.getTopRated(type: 'movie', page: 1);
      final List<ContentItem> recommendedItems = [];

      if (response['results'] != null) {
        for (var item in response['results']) {
          recommendedItems.add(_createContentItemFromMovie(item));
        }
      }

      _recommendedContent = recommendedItems.take(15).toList();
    } catch (error) {
      print('Erreur chargement recommandé: $error');
    }
  }

  // Créer le contenu featured
  void _createFeaturedContent() {
    // Prendre les meilleurs éléments du trending pour le featured
    _featuredContent = _trendingContent.take(5).toList();
  }

  // Recherche
  Future<List<ContentItem>> search(String query) async {
    try {
      final response = await _apiService.search(query, page: 1);
      final List<ContentItem> searchResults = [];

      if (response['results'] != null) {
        for (var item in response['results']) {
          if (item['media_type'] == 'movie') {
            searchResults.add(_createContentItemFromMovie(item));
          } else if (item['media_type'] == 'tv') {
            searchResults.add(_createContentItemFromTV(item));
          }
        }
      }

      return searchResults;
    } catch (error) {
      throw Exception('Erreur de recherche: ${error.toString()}');
    }
  }

  // Méthodes utilitaires pour créer des ContentItem
  ContentItem _createContentItemFromMovie(Map<String, dynamic> movie) {
    return ContentItem(
      id: movie['id'] ?? 0,
      title: movie['title'] ?? '',
      description: movie['overview'] ?? '',
      posterUrl: movie['poster_url'],
      backdropUrl: movie['backdrop_url'],
      rating: (movie['vote_average'] ?? 0.0).toDouble(),
      releaseYear: _extractYear(movie['release_date']),
      type: ContentType.movie,
      genres: _extractGenres(movie['genre_ids']),
    );
  }

  ContentItem _createContentItemFromTV(Map<String, dynamic> tv) {
    return ContentItem(
      id: tv['id'] ?? 0,
      title: tv['name'] ?? tv['title'] ?? '',
      description: tv['overview'] ?? '',
      posterUrl: tv['poster_url'],
      backdropUrl: tv['backdrop_url'],
      rating: (tv['vote_average'] ?? 0.0).toDouble(),
      releaseYear: _extractYear(tv['first_air_date']),
      type: ContentType.series,
      genres: _extractGenres(tv['genre_ids']),
    );
  }

  // Extraire l'année à partir d'une date
  int _extractYear(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 0;
    try {
      return DateTime.parse(dateString).year;
    } catch (e) {
      return 0;
    }
  }

  // Extraire les genres (placeholder - vous pourriez charger la liste des genres)
  List<String> _extractGenres(List<dynamic>? genreIds) {
    // Pour l'instant, retourner une liste vide
    // Vous pourriez implémenter un mapping des IDs vers les noms de genres
    return [];
  }

  // Méthodes utilitaires privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Rafraîchir tout le contenu
  Future<void> refresh() async {
    await loadAllContent();
  }

  // Charger plus de contenu pour une catégorie spécifique
  Future<void> loadMoreMovies({int page = 2}) async {
    try {
      final response = await _apiService.getPopularMovies(page: page);
      final List<ContentItem> moreMovies = [];

      if (response['results'] != null) {
        for (var item in response['results']) {
          moreMovies.add(_createContentItemFromMovie(item));
        }
      }

      _movies.addAll(moreMovies);
      notifyListeners();
    } catch (error) {
      print('Erreur chargement plus de films: $error');
    }
  }

  Future<void> loadMoreSeries({int page = 2}) async {
    try {
      final response = await _apiService.getPopularTV(page: page);
      final List<ContentItem> moreSeries = [];

      if (response['results'] != null) {
        for (var item in response['results']) {
          moreSeries.add(_createContentItemFromTV(item));
        }
      }

      _series.addAll(moreSeries);
      notifyListeners();
    } catch (error) {
      print('Erreur chargement plus de séries: $error');
    }
  }
}
