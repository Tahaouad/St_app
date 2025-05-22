import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/core/models/content_details.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/trailer_thumbnail.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/player/trailer_player.dart';

class EpisodesSection extends StatefulWidget {
  final List<Season> seasons;

  const EpisodesSection({
    super.key,
    required this.seasons,
  });

  @override
  State<EpisodesSection> createState() => _EpisodesSectionState();
}

class _EpisodesSectionState extends State<EpisodesSection> {
  int _selectedSeasonIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.seasons.isEmpty) {
      return const Center(
        child: Text(
          'Aucun épisode disponible',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final selectedSeason = widget.seasons[_selectedSeasonIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sélecteur de saison
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.seasons.asMap().entries.map((entry) {
              final index = entry.key;
              final season = entry.value;
              final isSelected = index == _selectedSeasonIndex;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(
                    'Saison ${season.seasonNumber}',
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.grey[900],
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSeasonIndex = index;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Liste des épisodes
        Expanded(
          child: selectedSeason.episodes != null &&
                  selectedSeason.episodes!.isNotEmpty
              ? ListView.builder(
                  itemCount: selectedSeason.episodes!.length,
                  itemBuilder: (context, index) {
                    final episode = selectedSeason.episodes![index];
                    return _buildEpisodeCard(episode);
                  },
                )
              : const Center(
                  child: Text(
                    'Aucun épisode disponible pour cette saison',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEpisodeCard(Episode episode) {
    // Vérifier si l'épisode a une URL vidéo YouTube
    final bool hasYoutubeVideo = episode.videoUrl.contains('youtube.com') ||
        episode.videoUrl.contains('youtu.be');

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (hasYoutubeVideo) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrailerPlayer(
                  title: '${episode.title} - Episode ${episode.episodeNumber}',
                  youtubeUrl: episode.videoUrl,
                ),
              ),
            );
          }
          // TODO: Gérer la lecture des épisodes non-YouTube
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail - utiliser TrailerThumbnail si c'est une vidéo YouTube
              if (hasYoutubeVideo)
                TrailerThumbnail(
                  trailerUrl: episode.videoUrl,
                  title: episode.title,
                  width: 120,
                  height: 68,
                  showPlayButton: true,
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: episode.thumbnailUrl != null
                      ? Image.network(
                          episode.thumbnailUrl!,
                          width: 120,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 120,
                            height: 68,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.play_circle_outline,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          width: 120,
                          height: 68,
                          color: Colors.grey[800],
                          child: Center(
                            child: Text(
                              'EP ${episode.episodeNumber}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ),

              const SizedBox(width: 12),

              // Informations de l'épisode
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Épisode ${episode.episodeNumber}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${episode.duration} min',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      episode.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (episode.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        episode.description!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Icône de lecture
              IconButton(
                onPressed: () {
                  if (hasYoutubeVideo) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrailerPlayer(
                          title:
                              '${episode.title} - Episode ${episode.episodeNumber}',
                          youtubeUrl: episode.videoUrl,
                        ),
                      ),
                    );
                  }
                  // TODO: Gérer la lecture des épisodes non-YouTube
                },
                icon: const Icon(
                  Icons.play_circle_filled,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
