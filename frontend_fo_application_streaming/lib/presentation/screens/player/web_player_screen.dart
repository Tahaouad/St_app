import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/services/streaming_service.dart';

class WebPlayerScreen extends StatefulWidget {
  final String title;
  final int tmdbId;
  final String mediaType;
  final int? season;
  final int? episode;

  const WebPlayerScreen({
    super.key,
    required this.title,
    required this.tmdbId,
    required this.mediaType,
    this.season,
    this.episode,
  });

  @override
  State<WebPlayerScreen> createState() => _WebPlayerScreenState();
}

class _WebPlayerScreenState extends State<WebPlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  int _currentUrlIndex = 0;

  List<String> _streamUrls = [];

  @override
  void initState() {
    super.initState();
    _initializeUrls();
    _initializeWebView();

    // Forcer l'orientation paysage
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Masquer la barre de statut
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _initializeUrls() {
    try {
      _streamUrls = [
        StreamingService.buildStreamUrl(
          tmdbId: widget.tmdbId,
          mediaType: widget.mediaType,
          season: widget.season,
          episode: widget.episode,
        ),
        StreamingService.buildAlternativeUrl(
          tmdbId: widget.tmdbId,
          mediaType: widget.mediaType,
          season: widget.season,
          episode: widget.episode,
        ),
      ];
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la génération des URLs: $e';
      });
    }
  }

  void _initializeWebView() {
    if (_streamUrls.isEmpty) return;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onHttpError: (HttpResponseError error) {
            setState(() {
              _error = 'Erreur HTTP: ${error.response?.statusCode}';
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _error = 'Erreur de ressource: ${error.description}';
              _isLoading = false;
            });
          },
        ),
      );

    _loadCurrentUrl();
  }

  void _loadCurrentUrl() {
    if (_currentUrlIndex < _streamUrls.length) {
      _controller.loadRequest(Uri.parse(_streamUrls[_currentUrlIndex]));
    }
  }

  void _tryNextUrl() {
    if (_currentUrlIndex < _streamUrls.length - 1) {
      setState(() {
        _currentUrlIndex++;
        _error = null;
      });
      _loadCurrentUrl();
    } else {
      setState(() {
        _error = 'Aucune source de streaming disponible';
      });
    }
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // WebView principal
          if (_streamUrls.isNotEmpty && _error == null)
            WebViewWidget(controller: _controller),

          // Indicateur de chargement
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),

          // Affichage d'erreur
          if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_currentUrlIndex < _streamUrls.length - 1)
                    ElevatedButton(
                      onPressed: _tryNextUrl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Essayer une autre source'),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                    ),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            ),

          // Contrôles personnalisés
          Positioned(
            top: 40,
            left: 20,
            child: SafeArea(
              child: Row(
                children: [
                  GestureDetector(
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Indicateur de source actuelle
          if (_streamUrls.length > 1)
            Positioned(
              top: 40,
              right: 20,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Source ${_currentUrlIndex + 1}/${_streamUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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
