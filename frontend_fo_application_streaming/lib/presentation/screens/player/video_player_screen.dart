// lib/presentation/screens/player/video_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/domain/services/streaming_service.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String title;
  final String? streamUrl; // URL optionnelle
  final int? tmdbId; // ID TMDB pour générer les URLs
  final String? mediaType; // Type de média
  final bool isEpisode;
  final int? season;
  final int? episode;
  final String? imdbId; // ID IMDB optionnel

  const VideoPlayerScreen({
    super.key,
    required this.title,
    this.streamUrl,
    this.tmdbId,
    this.mediaType,
    this.isEpisode = false,
    this.season,
    this.episode,
    this.imdbId,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  bool _showControls = true;
  int _currentUrlIndex = 0;
  List<String> _streamUrls = [];

  @override
  void initState() {
    super.initState();
    _generateStreamUrls();
    _initializeWebView();

    // Configuration de l'écran
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Masquer les contrôles après 5 secondes
    _hideControlsAfterDelay();
  }

  void _generateStreamUrls() {
    _streamUrls = [];

    // Si une URL est fournie directement, l'utiliser en premier
    if (widget.streamUrl != null && widget.streamUrl!.isNotEmpty) {
      _streamUrls.add(widget.streamUrl!);
    }

    // Générer des URLs alternatives si on a les données nécessaires
    if (widget.tmdbId != null && widget.mediaType != null) {
      final alternativeUrls = StreamingService.getAlternativeStreamUrls(
        tmdbId: widget.tmdbId!,
        mediaType: widget.mediaType!,
        imdbId: widget.imdbId,
        season: widget.season,
        episode: widget.episode,
      );

      // Ajouter les URLs qui ne sont pas déjà dans la liste
      for (final url in alternativeUrls) {
        if (!_streamUrls.contains(url)) {
          _streamUrls.add(url);
        }
      }
    }

    // URL de fallback si aucune autre n'est disponible
    if (_streamUrls.isEmpty &&
        widget.tmdbId != null &&
        widget.mediaType != null) {
      try {
        final fallbackUrl = StreamingService.buildStreamUrl(
          tmdbId: widget.tmdbId!,
          mediaType: widget.mediaType!,
          imdbId: widget.imdbId,
          season: widget.season,
          episode: widget.episode,
        );
        _streamUrls.add(fallbackUrl);
      } catch (e) {
        print('Erreur génération URL fallback: $e');
      }
    }
  }

  void _initializeWebView() {
    if (_streamUrls.isEmpty) {
      setState(() {
        _error = 'Aucune URL de streaming disponible';
        _isLoading = false;
      });
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted && progress == 100) {
              setState(() => _isLoading = false);
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _error = null;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              print('Erreur WebView: ${error.description}');
              _handleLoadError('Impossible de charger la vidéo');
            }
          },
          onHttpError: (HttpResponseError error) {
            if (mounted) {
              print('Erreur HTTP: ${error.response?.statusCode}');
              _handleLoadError('Erreur de connexion au serveur de streaming');
            }
          },
        ),
      );

    _loadCurrentUrl();
  }

  void _handleLoadError(String errorMessage) {
    if (_currentUrlIndex < _streamUrls.length - 1) {
      // Essayer l'URL suivante
      print(
          'Tentative URL suivante: ${_currentUrlIndex + 1}/${_streamUrls.length}');
      setState(() {
        _currentUrlIndex++;
        _isLoading = true;
        _error = null;
      });
      _loadCurrentUrl();
    } else {
      // Plus d'URLs à essayer
      setState(() {
        _isLoading = false;
        _error = errorMessage;
      });
    }
  }

  void _loadCurrentUrl() {
    if (_currentUrlIndex < _streamUrls.length) {
      final url = _streamUrls[_currentUrlIndex];
      print('Chargement URL: $url');
      _controller.loadRequest(Uri.parse(url));
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _showControls) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String get _displayTitle {
    if (widget.isEpisode && widget.season != null && widget.episode != null) {
      return '${widget.title} - S${widget.season}E${widget.episode}';
    }
    return widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // WebView Player
            if (_error == null && _streamUrls.isNotEmpty)
              WebViewWidget(controller: _controller)
            else
              _buildErrorWidget(),

            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Chargement du lecteur...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _displayTitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_streamUrls.length > 1) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Source ${_currentUrlIndex + 1}/${_streamUrls.length}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // Controls Overlay
            if (_showControls && !_isLoading) _buildControlsOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Controls
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _displayTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_streamUrls.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_currentUrlIndex + 1}/${_streamUrls.length}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _showOptionsMenu,
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom Controls
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () => _controller.reload(),
                    icon: const Icon(Icons.refresh,
                        color: Colors.white, size: 32),
                  ),
                  if (_streamUrls.length > 1)
                    IconButton(
                      onPressed: _tryNextUrl,
                      icon: const Icon(Icons.skip_next,
                          color: Colors.white, size: 32),
                    ),
                  IconButton(
                    onPressed: _openInBrowser,
                    icon: const Icon(Icons.open_in_browser,
                        color: Colors.white, size: 32),
                  ),
                  IconButton(
                    onPressed: _toggleFullscreen,
                    icon: const Icon(Icons.fullscreen,
                        color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.primary, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Erreur de lecture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Impossible de charger la vidéo',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  if (_streamUrls.length > 1 &&
                      _currentUrlIndex < _streamUrls.length - 1)
                    ElevatedButton.icon(
                      onPressed: _tryNextUrl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      label: const Text('Source suivante',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ElevatedButton.icon(
                    onPressed: _retryCurrentUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Réessayer',
                        style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openInBrowser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    icon:
                        const Icon(Icons.open_in_browser, color: Colors.white),
                    label: const Text('Navigateur',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white70),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child:
                    const Text('Retour', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tryNextUrl() {
    if (_currentUrlIndex < _streamUrls.length - 1) {
      setState(() {
        _currentUrlIndex++;
        _error = null;
        _isLoading = true;
      });
      _loadCurrentUrl();
    }
  }

  void _retryCurrentUrl() {
    setState(() {
      _error = null;
      _isLoading = true;
    });
    _loadCurrentUrl();
  }

  void _openInBrowser() async {
    if (_streamUrls.isNotEmpty) {
      final url = _streamUrls[_currentUrlIndex];
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Impossible d\'ouvrir le lien'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _toggleFullscreen() {
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.landscape) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    }
  }

  void _showOptionsMenu() {
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
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Options de lecture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.white),
              title: const Text('Recharger',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _controller.reload();
              },
            ),
            if (_streamUrls.length > 1 &&
                _currentUrlIndex < _streamUrls.length - 1)
              ListTile(
                leading: const Icon(Icons.skip_next, color: Colors.white),
                title: const Text('Source suivante',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _tryNextUrl();
                },
              ),
            ListTile(
              leading: const Icon(Icons.open_in_browser, color: Colors.white),
              title: const Text('Ouvrir dans le navigateur',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _openInBrowser();
              },
            ),
            ListTile(
              leading: const Icon(Icons.screen_rotation, color: Colors.white),
              title: const Text('Rotation écran',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _toggleFullscreen();
              },
            ),
          ],
        ),
      ),
    );
  }
}
