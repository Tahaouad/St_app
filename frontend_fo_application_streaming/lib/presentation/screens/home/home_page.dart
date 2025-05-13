import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/core/models/content_item.dart';
import 'package:frontend_fo_application_streaming/data/providers/auth_provider.dart';
import 'package:frontend_fo_application_streaming/data/providers/content_provider.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/custom_drawer.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/content_section.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/featured_content.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/category_selector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  bool _isAppBarExpanded = true;
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'Pour vous',
    'Films',
    'Séries',
    'Populaire',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContent();
    });

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bool isExpanded = _scrollController.offset < 300;
    if (_isAppBarExpanded != isExpanded) {
      setState(() {
        _isAppBarExpanded = isExpanded;
        _scrollOffset = _scrollController.offset;
      });
    } else {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    }
  }

  Future<void> _loadContent() async {
    final contentProvider = Provider.of<ContentProvider>(
      context,
      listen: false,
    );
    await contentProvider.loadAllContent();
  }

  void _handleCategorySelection(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });

    final contentProvider = Provider.of<ContentProvider>(
      context,
      listen: false,
    );

    switch (index) {
      case 1: // Films
        contentProvider.loadMovies();
        break;
      case 2: // Séries
        contentProvider.loadSeries();
        break;
      case 3: // Populaire
        // Le contenu populaire est déjà chargé
        break;
      default: // Pour vous
        contentProvider.loadAllContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final contentProvider = Provider.of<ContentProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!authProvider.isAuthenticated) {
      return _buildNotLoggedInScreen();
    }

    if (contentProvider.error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.primary,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                contentProvider.error!,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadContent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Réessayer',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildMainScreen();
  }

  Widget _buildNotLoggedInScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.primary, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Utilisateur non connecté',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Se connecter',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScreen() {
    final authProvider = Provider.of<AuthProvider>(context);
    final contentProvider = Provider.of<ContentProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      drawer: CustomDrawer(
        user: authProvider.user,
        onLogout: () async {
          await authProvider.logout();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: _loadContent,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          controller: _scrollController,
          slivers: [
            _buildAppBar(),
            if (contentProvider.featuredContent.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 600,
                  child: PageView.builder(
                    itemCount: contentProvider.featuredContent.length,
                    itemBuilder: (context, index) {
                      final content = contentProvider.featuredContent[index];
                      return _buildFeaturedContent(content);
                    },
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CategorySelector(
                  categories: _categories,
                  selectedIndex: _selectedCategoryIndex,
                  onCategorySelected: _handleCategorySelection,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_selectedCategoryIndex == 0) ..._buildForYouContent(),
                  if (_selectedCategoryIndex == 1) _buildMoviesContent(),
                  if (_selectedCategoryIndex == 2) _buildSeriesContent(),
                  if (_selectedCategoryIndex == 3) _buildPopularContent(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildForYouContent() {
    final contentProvider = Provider.of<ContentProvider>(context);

    return [
      if (contentProvider.trendingContent.isNotEmpty)
        ContentSection(
          title: 'Tendances actuelles',
          icon: Icons.trending_up,
          items: contentProvider.trendingContent,
          onSeeAllPressed: () {},
        ),
      const SizedBox(height: 24),
      if (contentProvider.newReleases.isNotEmpty)
        ContentSection(
          title: 'Nouveautés',
          icon: Icons.new_releases,
          items: contentProvider.newReleases,
          onSeeAllPressed: () {},
        ),
      const SizedBox(height: 24),
      if (contentProvider.recommendedContent.isNotEmpty)
        ContentSection(
          title: 'Recommandé pour vous',
          icon: Icons.recommend,
          items: contentProvider.recommendedContent,
          onSeeAllPressed: () {},
        ),
      const SizedBox(height: 24),
      if (contentProvider.popularContent.isNotEmpty)
        ContentSection(
          title: 'Populaire sur MoroccanFlix',
          icon: Icons.star,
          items: contentProvider.popularContent,
          onSeeAllPressed: () {},
        ),
    ];
  }

  Widget _buildMoviesContent() {
    final contentProvider = Provider.of<ContentProvider>(context);

    if (contentProvider.movies.isEmpty) {
      return Center(
        child:
            contentProvider.isLoading
                ? const CircularProgressIndicator(color: AppColors.primary)
                : const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Aucun film disponible',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
      );
    }

    return ContentSection(
      title: 'Films',
      icon: Icons.movie,
      items: contentProvider.movies,
      onSeeAllPressed: () {},
    );
  }

  Widget _buildSeriesContent() {
    final contentProvider = Provider.of<ContentProvider>(context);

    if (contentProvider.series.isEmpty) {
      return Center(
        child:
            contentProvider.isLoading
                ? const CircularProgressIndicator(color: AppColors.primary)
                : const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Aucune série disponible',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
      );
    }

    return ContentSection(
      title: 'Séries',
      icon: Icons.tv,
      items: contentProvider.series,
      onSeeAllPressed: () {},
    );
  }

  Widget _buildPopularContent() {
    final contentProvider = Provider.of<ContentProvider>(context);

    if (contentProvider.popularContent.isEmpty) {
      return Center(
        child:
            contentProvider.isLoading
                ? const CircularProgressIndicator(color: AppColors.primary)
                : const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Aucun contenu populaire disponible',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
      );
    }

    return ContentSection(
      title: 'Les plus populaires',
      icon: Icons.whatshot,
      items: contentProvider.popularContent,
      onSeeAllPressed: () {},
    );
  }

  SliverAppBar _buildAppBar() {
    final authProvider = Provider.of<AuthProvider>(context);

    return SliverAppBar(
      expandedHeight: 60,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor:
          _scrollOffset > 100 ? AppColors.background : Colors.transparent,
      elevation: _scrollOffset > 100 ? 8 : 0,
      title:
          _scrollOffset > 100
              ? const Text(
                'MoroccanFlix',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppColors.primary,
                ),
              )
              : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: SvgPicture.network(
                authProvider.user?['avatar'] ??
                    'https://api.dicebear.com/9.x/adventurer/svg?seed=Default',
                width: 36,
                height: 36,
              ),
            ),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFeaturedContent(ContentItem content) {
    return FeaturedContent(
      title: content.title,
      description: content.description,
      imageUrl:
          content.posterUrl ??
          content.backdropUrl ??
          'assets/images/welcome.jpg',
      rating: content.rating,
      year: content.releaseYear.toString(),
      quality: '4K Ultra HD',
      type: content.type == ContentType.movie ? 'Film' : 'Série',
      onPlayPressed: () {
        // TODO: Navigation vers le lecteur vidéo
      },
      onAddToListPressed: () {
        // TODO: Ajouter aux favoris
      },
      onInfoPressed: () {
        // TODO: Navigation vers les détails
      },
    );
  }
}
