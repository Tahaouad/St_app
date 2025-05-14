import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';

class TrailerPlayer extends StatefulWidget {
  final String title;
  final String youtubeUrl;

  const TrailerPlayer({
    super.key,
    required this.title,
    required this.youtubeUrl,
  });

  @override
  State<TrailerPlayer> createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<TrailerPlayer> {
  late YoutubePlayerController _controller;

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

    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl);

    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        isLive: false,
        forceHD: true,
      ),
    );
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

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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
              onEnded: (data) {
                Navigator.pop(context);
              },
              bottomActions: [
                CurrentPosition(),
                ProgressBar(
                  isExpanded: true,
                  colors: const ProgressBarColors(
                    playedColor: AppColors.primary,
                    handleColor: AppColors.primary,
                  ),
                ),
                RemainingDuration(),
                const PlaybackSpeedButton(),
                FullScreenButton(),
              ],
            ),
          ),

          // Bouton de retour
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Titre de la vidéo
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
