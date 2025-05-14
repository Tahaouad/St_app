import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/player/trailer_player.dart';

class TrailerButton extends StatelessWidget {
  final String? trailerUrl;
  final String title;

  const TrailerButton({
    super.key,
    required this.trailerUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (trailerUrl == null || trailerUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: () => _playTrailer(context),
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.5),
        padding: const EdgeInsets.all(12),
      ),
      icon: const Icon(
        Icons.play_circle_outline,
        color: Colors.white,
        size: 32,
      ),
      tooltip: 'Regarder la bande-annonce',
    );
  }

  void _playTrailer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Comment voulez-vous regarder la bande-annonce ?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Option 1 : Lecteur intégré
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.play_circle_filled,
                  color: AppColors.primary,
                ),
              ),
              title: const Text(
                'Lecteur intégré',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Regarder directement dans l\'application',
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrailerPlayer(
                      title: title,
                      youtubeUrl: trailerUrl!,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // Option 2 : Navigateur web
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.open_in_browser,
                  color: Colors.blue,
                ),
              ),
              title: const Text(
                'Navigateur web',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Ouvrir dans YouTube ou votre navigateur',
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () async {
                Navigator.pop(context);
                final uri = Uri.parse(trailerUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Impossible d\'ouvrir le lien'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
