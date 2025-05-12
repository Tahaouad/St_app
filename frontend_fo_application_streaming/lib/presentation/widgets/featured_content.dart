import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';

class FeaturedContent extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final double rating;
  final String year;
  final String quality;
  final String type;
  final VoidCallback onPlayPressed;
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
    required this.onPlayPressed,
    required this.onAddToListPressed,
    required this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image d'arrière-plan
        Container(
          height: 600,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
              colorFilter: const ColorFilter.mode(
                Colors.black26,
                BlendMode.darken,
              ),
            ),
          ),
        ),
        // Overlay gradient
        Container(
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
        ),
        // Contenu texte et boutons
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge "Exclusivité"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Titre principal
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                // Informations secondaires
                Row(
                  children: [
                    _buildRatingChip(rating),
                    const SizedBox(width: 12),
                    Text(
                      '$year • $quality',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  type,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // Description courte
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPlayPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text(
                          'Lecture',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildActionIconButton(
                      Icons.add,
                      'Ma liste',
                      onAddToListPressed,
                    ),
                    const SizedBox(width: 12),
                    _buildActionIconButton(
                      Icons.info_outline,
                      'Infos',
                      onInfoPressed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingChip(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.black, size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textSecondary),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: AppColors.textPrimary),
            iconSize: 20,
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
