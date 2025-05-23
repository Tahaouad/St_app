// lib/presentation/widgets/featured_content.dart
import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/core/models/content_enums.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/player/video_player_screen.dart';
import 'package:frontend_fo_application_streaming/domain/services/streaming_service.dart';

class FeaturedContent extends StatefulWidget {
  final String title;
  final String description;
  final String imageUrl;
  final double rating;
  final String year;
  final String quality;
  final String type;
  final int contentId;
  final ContentType contentType;
  final VoidCallback onAddToListPressed;
  final VoidCallback onInfoPressed;

  const FeaturedContent({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.year,
    required this.quality,
    required this.type,
    required this.contentId,
    required this.contentType,
    required this.onAddToListPressed,
    required this.onInfoPressed,
  });

  @override
  State<FeaturedContent> createState() => _FeaturedContentState();
}

class _FeaturedContentState extends State<FeaturedContent> {
  bool _isLoadingStream = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image d'arrière-plan
        _buildBackgroundImage(),

        // Gradient overlay
        _buildGradientOverlay(),

        // Contenu principal
        _buildMainContent(),

        // Indicateur de type
        _buildTypeIndicator(),
      ],
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        image: widget.imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
                colorFilter: const ColorFilter.mode(
                  Colors.black26,
                  BlendMode.darken,
                ),
                onError: (exception, stackTrace) {
                  debugPrint('Erreur de chargement image: $exception');
                },
              )
            : null,
        color: widget.imageUrl.isEmpty ? Colors.grey[900] : null,
      ),
      child: widget.imageUrl.isEmpty
          ? const Center(
              child: Icon(
                Icons.movie_outlined,
                color: Colors.grey,
                size: 100,
              ),
            )
          : null,
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withOpacity(0.1),
            AppColors.background.withOpacity(0.3),
            AppColors.background.withOpacity(0.7),
            AppColors.background.withOpacity(0.9),
            AppColors.background,
          ],
          stops: const [0.0, 0.3, 0.5, 0.8, 1.0],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge exclusivité
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'EXCLUSIVITÉ',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Titre
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: AppColors.textPrimary,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black54,
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Informations
            Row(
              children: [
                _buildRatingChip(),
                const SizedBox(width: 12),
                Text(
                  '${widget.year} • ${widget.quality}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.type,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              widget.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),

            // Boutons d'action
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Bouton Lecture
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoadingStream ? null : _handlePlayPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
            icon: _isLoadingStream
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.play_arrow, color: Colors.white, size: 24),
            label: Text(
              _isLoadingStream ? 'Chargement...' : 'Lecture',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Bouton Ma liste
        _buildActionIconButton(
          Icons.add,
          'Ma liste',
          widget.onAddToListPressed,
        ),
        const SizedBox(width: 12),

        // Bouton Infos
        _buildActionIconButton(
          Icons.info_outline,
          'Infos',
          widget.onInfoPressed,
        ),
      ],
    );
  }

  Widget _buildTypeIndicator() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.contentType == ContentType.movie ? Icons.movie : Icons.tv,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              widget.contentType == ContentType.movie ? 'FILM' : 'SÉRIE',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.black, size: 16),
          const SizedBox(width: 4),
          Text(
            widget.rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIconButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.4),
            border: Border.all(
              color: AppColors.textSecondary.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: AppColors.textPrimary, size: 22),
            padding: EdgeInsets.zero,
            splashRadius: 24,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _handlePlayPressed() async {
    if (_isLoadingStream) return;

    setState(() {
      _isLoadingStream = true;
    });

    try {
      final streamingService = StreamingService();
      Map<String, dynamic> result;

      if (widget.contentType == ContentType.movie) {
        result = await streamingService.getMovieStreamUrl(widget.contentId);
      } else {
        result = await streamingService.getEpisodeStreamUrl(
          widget.contentId,
          1, // Première saison
          1, // Premier épisode
        );
      }

      if (mounted) {
        if (result['success']) {
          final streamData = result['data'];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                title: streamData['title'] ?? widget.title,
                streamUrl: streamData['streamUrl'],
                isEpisode: widget.contentType == ContentType.series,
                season: streamData['season'],
                episode: streamData['episode'],
              ),
            ),
          );
        } else {
          _showErrorSnackBar(result['message'] ?? 'Erreur lors de la lecture');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
            'Erreur de connexion: Vérifiez votre connexion internet');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStream = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Réessayer',
          textColor: Colors.white,
          onPressed: _handlePlayPressed,
        ),
      ),
    );
  }
}
