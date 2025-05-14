import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';

class YoutubeIframePlayer extends StatefulWidget {
  final String title;
  final String youtubeUrl;

  const YoutubeIframePlayer({
    super.key,
    required this.title,
    required this.youtubeUrl,
  });

  @override
  State<YoutubeIframePlayer> createState() => _YoutubeIframePlayerState();
}

class _YoutubeIframePlayerState extends State<YoutubeIframePlayer> {
  late String _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = _extractVideoId(widget.youtubeUrl);
  }

  String _extractVideoId(String url) {
    if (url.contains('youtube.com/watch?v=')) {
      return url.split('v=')[1].split('&')[0];
    } else if (url.contains('youtu.be/')) {
      return url.split('youtu.be/')[1].split('?')[0];
    } else if (url.contains('youtube.com/embed/')) {
      return url.split('embed/')[1].split('?')[0];
    }
    return url;
  }

  String _getHtmlContent() {
    return '''
<!DOCTYPE html>
<html style="height: 100%; width: 100%; margin: 0; padding: 0;">
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      height: 100%;
      width: 100%;
      margin: 0;
      padding: 0;
      background-color: black;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    #player-container {
      position: relative;
      width: 100%;
      height: 100%;
      max-width: 100%;
      max-height: 100%;
    }
    iframe {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
    }
  </style>
</head>
<body>
  <div id="player-container">
    <iframe 
      src="https://www.youtube.com/embed/$_videoId?autoplay=1&enablejsapi=1&rel=0&showinfo=0"
      frameborder="0"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
      allowfullscreen>
    </iframe>
  </div>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.smart_display,
              color: AppColors.primary,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Lecture : ${widget.title}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ID Vidéo: $_videoId',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pour intégrer la vidéo YouTube dans votre app :',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // Copier le code HTML dans le presse-papiers
                            // Nécessite clipboard package
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Copier HTML'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Utiliser url_launcher pour ouvrir dans le navigateur
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(Icons.open_in_browser, size: 18),
                          label: const Text('Ouvrir'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Options pour intégrer :',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '1. webview_flutter:',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'webview_flutter: ^4.4.2',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '2. flutter_inappwebview:',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'flutter_inappwebview: ^6.0.0',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
