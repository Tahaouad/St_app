
import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/core/models/content_details.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/player/trailer_button.dart';

class ContentDetailsHeaderCached extends StatelessWidget {
  final ContentDetails contentDetails;

  const ContentDetailsHeaderCached({
    super.key,
    required this.contentDetails,
  });

  @override
  Widget build(BuildContext context) {
    // Essayer backdrop d'abord, puis poster
    final String? imageUrl = contentDetails.backdropUrl ?? contentDetails.posterUrl;
    
    // Créer une URL de fallback si nécessaire
    final String placeholderUrl = 'https://via.placeholder.com/800x450.png?text=${Uri.encodeComponent(contentDetails.title)}';

    return Stack(
      fit: StackFit.expand,
      children: [
        // Image de fond
        if (imageUrl != null && imageUrl.isNotEmpty)
          Image.network(
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
              print('Erreur Image.network: $error pour URL: $imageUrl');
              // Essayer avec une image placeholder
              return Image.network(
                placeholderUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[900],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.movie_outlined,
                          color: Colors.grey,
                          size: 80,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          contentDetails.title,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        else
          Container(
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
                    contentDetails.title,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Gradient overlay
        Container(
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
        ),

        // Boutons d'action en bas
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouton Lecture
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implémenter la lecture
                },
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
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text(
                  'Lecture',
                  style: TextStyle(
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
                  // TODO: Ajouter à ma liste
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
              if (contentDetails.trailerUrl != null)
                IconButton(
                  onPressed: () {
                    // TODO: Lire la bande-annonce
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
        ),
      ],
    );
  }
}