// lib/presentation/screens/content/widgets/content_details_header.dart
import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/core/models/content_details.dart';
import 'package:frontend_fo_application_streaming/core/models/content_enums.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/player/trailer_player.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/player/video_player_screen.dart';
import 'package:frontend_fo_application_streaming/domain/services/streaming_service.dart';

class ContentDetailsHeader extends StatefulWidget {
  final ContentDetails contentDetails;

  const ContentDetailsHeader({
    super.key,
    required this.contentDetails,
  });

  @override
  State<ContentDetailsHeader> createState() => _ContentDetailsHeaderState();
}

class _ContentDetailsHeaderState extends State<ContentDetailsHeader> {
  bool _isLoadingStream = false;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl =
        widget.contentDetails.backdropUrl ?? widget.contentDetails.posterUrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Image de fond
        _buildBackgroundImage(imageUrl),

        // Gradient overlay
        _buildGradientOverlay(),

        // Boutons d'action
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildBackgroundImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[900],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.primary,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[900],
            child: const Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 60,
              ),
            ),
          );
        },
      );
    } else {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.movie_outlined,
                color: Colors.grey,
                size: 100,
              ),
              const SizedBox(height: 8),
              Text(
                widget.contentDetails.title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.7),
            Colors.black,
          ],
          stops: const [0.3, 0.5, 0.8, 1.0],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bouton Lecture
          ElevatedButton.icon(
            onPressed: _isLoadingStream ? null : _handlePlayPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
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
                : const Icon(Icons.play_arrow, color: Colors.white),
            label: Text(
              _isLoadingStream ? 'Chargement...' : 'Lecture',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Bouton Ma liste
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité en cours de développement'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Ma liste',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Bouton Bande-annonce
          if (widget.contentDetails.trailerUrl != null &&
              widget.contentDetails.trailerUrl!.isNotEmpty)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrailerPlayer(
                      title: widget.contentDetails.title,
                      youtubeUrl: widget.contentDetails.trailerUrl!,
                    ),
                  ),
                );
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
              icon: const Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 32,
              ),
            ),
        ],
      ),
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

      if (widget.contentDetails.type == ContentType.movie) {
        result =
            await streamingService.getMovieStreamUrl(widget.contentDetails.id);
      } else {
        if (widget.contentDetails.seasons != null &&
            widget.contentDetails.seasons!.isNotEmpty) {
          result = await streamingService.getEpisodeStreamUrl(
            widget.contentDetails.id,
            1, // Première saison
            1, // Premier épisode
          );
        } else {
          if (mounted) {
            _showErrorSnackBar('Aucun épisode disponible pour cette série.');
          }
          return;
        }
      }

      if (mounted) {
        if (result['success']) {
          final streamData = result['data'];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                title: streamData['title'] ?? widget.contentDetails.title,
                streamUrl: streamData['streamUrl'],
                isEpisode: widget.contentDetails.type == ContentType.series,
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
