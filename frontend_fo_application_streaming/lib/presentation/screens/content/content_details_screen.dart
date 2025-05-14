// lib/presentation/screens/content/content_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/core/models/content_details.dart';
import 'package:frontend_fo_application_streaming/core/models/content_item.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/content/widgets/content_details_header.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/content/widgets/episodes_section.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/content/widgets/similar_content_section.dart';
import 'package:frontend_fo_application_streaming/domain/services/movie_service.dart';
import 'package:frontend_fo_application_streaming/domain/services/series_service.dart';

class ContentDetailsScreen extends StatefulWidget {
  final ContentItem contentItem;

  const ContentDetailsScreen({
    super.key,
    required this.contentItem,
  });

  @override
  State<ContentDetailsScreen> createState() => _ContentDetailsScreenState();
}

class _ContentDetailsScreenState extends State<ContentDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ContentDetails? _contentDetails;
  List<ContentItem> _similarContent = [];
  bool _isLoading = true;
  String? _error;

  final MovieService _movieService = MovieService();
  final SeriesService _seriesService = SeriesService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadContentDetails();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _loadContentDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Map<String, dynamic> result;

      if (widget.contentItem.type == ContentType.movie) {
        result = await _movieService.getMovieDetails(widget.contentItem.id);
        if (result['success']) {
          _contentDetails = ContentDetails.fromJson(
            result['data'],
            ContentType.movie,
          );

          // Charger les films similaires
          final relatedResult = await _movieService.getRelatedMovies(
            widget.contentItem.id,
          );
          if (relatedResult['success']) {
            _similarContent = (relatedResult['data'] as List)
                .map((item) => ContentItem.fromJson(item))
                .toList();
          }
        }
      } else {
        result = await _seriesService.getSeriesDetails(widget.contentItem.id);
        if (result['success']) {
          _contentDetails = ContentDetails.fromJson(
            result['data'],
            ContentType.series,
          );

          // Pour l'instant, pas de séries similaires dans l'API
          _similarContent = [];
        }
      }

      if (!result['success']) {
        _error = result['message'];
      }
    } catch (e) {
      _error = 'Une erreur est survenue: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null || _contentDetails == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.primary, size: 60),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Une erreur est survenue',
                style: const TextStyle(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadContentDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar avec image de fond
          SliverAppBar(
            expandedHeight: 500,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: ContentDetailsHeader(
              contentDetails: _contentDetails!,
            ),
          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et informations
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _contentDetails!.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildInfoChip(
                                  Icons.star,
                                  _contentDetails!.rating.toStringAsFixed(1),
                                  Colors.amber,
                                ),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  Icons.calendar_today,
                                  _contentDetails!.releaseYear.toString(),
                                ),
                                if (_contentDetails!.type ==
                                    ContentType.movie) ...[
                                  const SizedBox(width: 8),
                                  _buildInfoChip(
                                    Icons.access_time,
                                    _contentDetails!.displayDuration,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Genres
                  if (_contentDetails!.genres != null &&
                      _contentDetails!.genres!.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _contentDetails!.genres!
                          .map((genre) => Chip(
                                label: Text(
                                  genre.name,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.2),
                                side: BorderSide(
                                  color: AppColors.primary.withOpacity(0.5),
                                ),
                              ))
                          .toList(),
                    ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    _contentDetails!.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Réalisateur/Créateur et casting
                  if (_contentDetails!.type == ContentType.movie &&
                      _contentDetails!.director != null) ...[
                    _buildInfoRow('Réalisateur', _contentDetails!.director!),
                    const SizedBox(height: 16),
                  ],

                  if (_contentDetails!.type == ContentType.series &&
                      _contentDetails!.creator != null) ...[
                    _buildInfoRow('Créateur', _contentDetails!.creator!),
                    const SizedBox(height: 16),
                  ],

                  if (_contentDetails!.cast != null) ...[
                    _buildInfoRow('Casting', _contentDetails!.cast!),
                    const SizedBox(height: 24),
                  ],

                  // Tabs pour séries (Épisodes et Similaires)
                  if (_contentDetails!.type == ContentType.series) ...[
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      tabs: const [
                        Tab(text: 'Épisodes'),
                        Tab(text: 'Similaires'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          EpisodesSection(
                            seasons: _contentDetails!.seasons ?? [],
                          ),
                          SimilarContentSection(
                            similarContent: _similarContent,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Section similaire pour les films
                    if (_similarContent.isNotEmpty) ...[
                      const Text(
                        'Films similaires',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SimilarContentSection(
                        similarContent: _similarContent,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, [Color? iconColor]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor ?? AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
