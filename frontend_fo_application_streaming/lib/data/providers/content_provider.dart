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
  List<ContentItem> _trendingContent = [];
  List<ContentItem> _newReleases = [];
  List<ContentItem> _recommendedContent = [];
  List<ContentItem> _popularContent = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ContentItem> get featuredContent => _featuredContent;
  List<ContentItem> get trendingContent => _trendingContent;
  List<ContentItem> get newReleases => _newReleases;
  List<ContentItem> get recommendedContent => _recommendedContent;
  List<ContentItem> get popularContent => _popularContent;

  // Méthode pour charger tout le contenu
  Future<void> loadAllContent() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadFeaturedContent(),
        _loadTrendingContent(),
        _loadNewReleases(),
        _loadRecommendedContent(),
        _loadPopularContent(),
      ]);
    } catch (e) {
      _error = 'Erreur lors du chargement du contenu: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthodes privées pour charger différents types de contenu
  Future<void> _loadFeaturedContent() async {
    try {
      // Charger les films mis en avant
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

      // Prendre seulement les 5 premiers éléments mis en avant
      if (_featuredContent.length > 5) {
        _featuredContent = _featuredContent.sublist(0, 5);
      }
    } catch (e) {
      print(
        'Erreur lors du chargement des contenus en vedette: ${e.toString()}',
      );
    }
  }

  Future<void> _loadTrendingContent() async {
    try {
      // Simuler des données de tendances (à remplacer par une vraie API)
      await Future.delayed(const Duration(milliseconds: 500));
      _trendingContent = List.generate(
        10,
        (index) => ContentItem(
          id: 100 + index,
          title: 'Trending Title ${index + 1}',
          description: 'Description du contenu tendance ${index + 1}',
          posterUrl:
              'https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg',
          rating: 7.5 + (index * 0.1),
        ),
      );
    } catch (e) {
      print('Erreur lors du chargement des tendances: ${e.toString()}');
    }
  }

  Future<void> _loadNewReleases() async {
    try {
      // Simuler des données de nouvelles sorties (à remplacer par une vraie API)
      await Future.delayed(const Duration(milliseconds: 500));
      _newReleases = List.generate(
        10,
        (index) => ContentItem(
          id: 200 + index,
          title: 'New Release ${index + 1}',
          description: 'Description de la nouvelle sortie ${index + 1}',
          posterUrl:
              'https://image.tmdb.org/t/p/w500/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg',
          rating: 8.0 + (index * 0.1),
        ),
      );
    } catch (e) {
      print('Erreur lors du chargement des nouvelles sorties: ${e.toString()}');
    }
  }

  Future<void> _loadRecommendedContent() async {
    try {
      // Simuler des données recommandées (à remplacer par une vraie API)
      await Future.delayed(const Duration(milliseconds: 500));
      _recommendedContent = List.generate(
        10,
        (index) => ContentItem(
          id: 300 + index,
          title: 'Recommended Title ${index + 1}',
          description: 'Description du contenu recommandé ${index + 1}',
          posterUrl:
              'https://image.tmdb.org/t/p/w500/vZloFAK7NmvMGKE7VkF5UHaz0I.jpg',
          rating: 8.5 + (index * 0.1),
        ),
      );
    } catch (e) {
      print('Erreur lors du chargement des recommandations: ${e.toString()}');
    }
  }

  Future<void> _loadPopularContent() async {
    try {
      // Charger les films populaires
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
    } catch (e) {
      print(
        'Erreur lors du chargement des contenus populaires: ${e.toString()}',
      );
    }
  }
}
