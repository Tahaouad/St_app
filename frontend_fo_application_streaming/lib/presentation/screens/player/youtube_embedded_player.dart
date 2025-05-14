import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeEmbeddedPlayer extends StatefulWidget {
  final String title;
  final String youtubeUrl;

  const YoutubeEmbeddedPlayer({
    super.key,
    required this.title,
    required this.youtubeUrl,
  });

  @override
  State<YoutubeEmbeddedPlayer> createState() => _YoutubeEmbeddedPlayerState();
}

class _YoutubeEmbeddedPlayerState extends State<YoutubeEmbeddedPlayer> {
  // Décommentez ces lignes après avoir ajouté youtube_player_flutter
  // late YoutubePlayerController _controller;
  // late String _videoId;

  @override
  void initState() {
    super.initState();

    // Forcer l'orientation paysage
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // Masquer la barre de statut
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Extraire l'ID de la vidéo
    // _videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl) ?? '';

    // Initialiser le contrôleur
    /*
    _controller = YoutubePlayerController(
      initialVideoId: _videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        isLive: false,
        forceHD: true,
      ),
    );
    */
  }

  @override
  void dispose() {
    // Restaurer l'orientation portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Restaurer la barre de statut
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Décommentez ce code après avoir ajouté youtube_player_flutter
          /*
          Center(
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.primary,
              progressColors: const ProgressBarColors(
                playedColor: AppColors.primary,
                handleColor: AppColors.primary,
              ),
              onReady: () {
                print('Player is ready.');
              },
              onEnded: (metaData) {
                Navigator.pop(context);
              },
            ),
          ),
          */

          // Code temporaire de démonstration
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_circle_outline,
                    color: AppColors.primary,
                    size: 100,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Pour activer la lecture YouTube :',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '1. Ajoutez au pubspec.yaml :',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'youtube_player_flutter: ^8.1.2',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 14,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '2. Décommentez le code dans cette page',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '3. Importez le package en haut du fichier',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton de retour
          Positioned(
            top: 40,
            left: 20,
            child: Material(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
