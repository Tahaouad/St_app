import 'package:flutter/foundation.dart';
import 'package:frontend_fo_application_streaming/core/models/content_item.dart';
import 'package:frontend_fo_application_streaming/domain/services/movie_service.dart';
import 'package:frontend_fo_application_streaming/domain/services/series_service.dart';

class ContentProvider extends ChangeNotifier {
  final MovieService _movieService = MovieService();
  final SeriesService _seriesService = SeriesService();

  bool _isLoading = false;
  String? _error;

  List<ContentItem> _featuredContent = [];
  List<ContentItem> _popularContent = [];
  List<ContentItem> _movies = [];
  List<ContentItem> _series = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ContentItem> get featuredContent => _featuredContent;
  List<ContentItem> get popularContent => _popularContent;
  List<ContentItem> get movies => _movies;
  List<ContentItem> get series => _series;

  // Pour les catégories simulées (à remplacer par des vraies données plus tard)
  List<ContentItem> get trendingContent => _popularContent.take(10).toList();
  List<ContentItem> get newReleases =>
      [..._movies, ..._series].take(10).toList();
  List<ContentItem> get recommendedContent =>
      _featuredContent.take(10).toList();

  // Méthode pour charger tout le contenu
  Future<void> loadAllContent() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadFeaturedContent(),
        _loadPopularContent(),
        loadMovies(), // Utiliser loadMovies() sans underscore
        loadSeries(), // Utiliser loadSeries() sans underscore
      ]);
    } catch (e) {
      _error = 'Erreur lors du chargement du contenu: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode pour charger les films avec filtres
  Future<void> loadMovies({
    int? categoryId,
    int? genreId,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _movieService.getMovies(
        categoryId: categoryId,
        genreId: genreId,
        search: search,
        limit: limit,
        offset: offset,
      );

      if (result['success']) {
        final data = result['data'];
        _movies =
            (data['rows'] as List)
                .map((movie) => ContentItem.fromJson(movie))
                .toList();
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des films: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode pour charger les séries avec filtres
  Future<void> loadSeries({
    int? categoryId,
    int? genreId,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _seriesService.getSeries(
        categoryId: categoryId,
        genreId: genreId,
        search: search,
        limit: limit,
        offset: offset,
      );

      if (result['success']) {
        final data = result['data'];
        _series =
            (data['rows'] as List)
                .map((series) => ContentItem.fromJson(series))
                .toList();
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des séries: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthodes privées pour charger différents types de contenu
  Future<void> _loadFeaturedContent() async {
    try {
      final movieResult = await _movieService.getFeaturedMovies();
      final seriesResult = await _seriesService.getFeaturedSeries();

      _featuredContent = [];

      if (movieResult['success']) {
        _featuredContent.addAll(
          (movieResult['data'] as List)
              .map((movie) => ContentItem.fromJson(movie))
              .toList(),
        );
      }

      if (seriesResult['success']) {
        _featuredContent.addAll(
          (seriesResult['data'] as List)
              .map((series) => ContentItem.fromJson(series))
              .toList(),
        );
      }

      // Mélanger et limiter à 5 éléments
      _featuredContent.shuffle();
      if (_featuredContent.length > 5) {
        _featuredContent = _featuredContent.sublist(0, 5);
      }
    } catch (e) {
      print(
        'Erreur lors du chargement des contenus en vedette: ${e.toString()}',
      );
    }
  }

  Future<void> _loadPopularContent() async {
    try {
      final movieResult = await _movieService.getPopularMovies();
      final seriesResult = await _seriesService.getPopularSeries();

      _popularContent = [];

      if (movieResult['success']) {
        _popularContent.addAll(
          (movieResult['data'] as List)
              .map((movie) => ContentItem.fromJson(movie))
              .toList(),
        );
      }

      if (seriesResult['success']) {
        _popularContent.addAll(
          (seriesResult['data'] as List)
              .map((series) => ContentItem.fromJson(series))
              .toList(),
        );
      }

      // Mélanger les contenus populaires
      _popularContent.shuffle();
    } catch (e) {
      print(
        'Erreur lors du chargement des contenus populaires: ${e.toString()}',
      );
    }
  }
}
