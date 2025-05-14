import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
// Ajoutez cet import après avoir ajouté url_launcher dans pubspec.yaml
// import 'package:url_launcher/url_launcher.dart';

class YoutubePlayerPage extends StatefulWidget {
  final String title;
  final String youtubeUrl;

  const YoutubePlayerPage({
    super.key,
    required this.title,
    required this.youtubeUrl,
  });

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  late String _videoId;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _videoId = _extractVideoId(widget.youtubeUrl);
  }

  String _extractVideoId(String url) {
    // Extraire l'ID de la vidéo YouTube de différents formats d'URL
    if (url.contains('youtube.com/watch?v=')) {
      return url.split('v=')[1].split('&')[0];
    } else if (url.contains('youtu.be/')) {
      return url.split('youtu.be/')[1].split('?')[0];
    } else if (url.contains('youtube.com/embed/')) {
      return url.split('embed/')[1].split('?')[0];
    }
    return url; // Retourner l'URL telle quelle si le format n'est pas reconnu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_outline,
                  color: AppColors.primary,
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  'Bande-annonce: ${widget.title}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Video ID: $_videoId',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pour afficher la vidéo YouTube, vous avez deux options :',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Option 1: youtube_player_flutter',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                        '✅ Simple à utiliser\n✅ Contrôles natifs YouTube\n✅ Support fullscreen',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Option 2: webview_flutter',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'webview_flutter: ^4.4.2',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '✅ Plus flexible\n✅ Support iframe YouTube\n❌ Configuration complexe',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    final url = 'https://www.youtube.com/watch?v=$_videoId';

                    // Ouvrir l'URL dans le navigateur externe
                    // Vous pouvez utiliser url_launcher pour cela
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Ouvrir dans le navigateur'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
