import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/data/providers/auth_provider.dart';
import 'package:frontend_fo_application_streaming/data/providers/content_provider.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/home/widgets/home_app_bar.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/home/widgets/home_featured_section.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/home/widgets/content_category_tab.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/home/widgets/not_logged_in_view.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/home/sections/for_you_section.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/home/sections/movies_section.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/home/sections/series_section.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/home/sections/popular_section.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/custom_drawer.dart';
import 'package:frontend_fo_application_streaming/data/providers/home_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadContent();

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
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final bool isExpanded = _scrollController.offset < 300;

    if (homeProvider.isAppBarExpanded != isExpanded) {
      homeProvider.setAppBarExpanded(isExpanded);
    }

    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  Future<void> _loadContent() async {
    final contentProvider = Provider.of<ContentProvider>(
      context,
      listen: false,
    );
    await contentProvider.loadAllContent();
  }

  void _handleCategorySelection(int index) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.setSelectedCategory(index);

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

    // Loading state
    if (authProvider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // Not logged in state
    if (!authProvider.isAuthenticated) {
      return const NotLoggedInView();
    }

    // Error state
    if (contentProvider.error != null) {
      return _buildErrorScreen(contentProvider.error!);
    }

    // Main content
    return _buildMainScreen();
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.primary, size: 60),
            const SizedBox(height: 16),
            Text(
              error,
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

  Widget _buildMainScreen() {
    final authProvider = Provider.of<AuthProvider>(context);
    final contentProvider = Provider.of<ContentProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);

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
            HomeAppBar(scrollOffset: _scrollOffset, user: authProvider.user),
            if (contentProvider.featuredContent.isNotEmpty)
              SliverToBoxAdapter(
                child: HomeFeaturedSection(
                  featuredContent: contentProvider.featuredContent,
                ),
              ),
            SliverToBoxAdapter(
              child: ContentCategoryTab(
                categories: HomeProvider.categories,
                selectedIndex: homeProvider.selectedCategoryIndex,
                onCategorySelected: _handleCategorySelection,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (homeProvider.selectedCategoryIndex == 0)
                    const ForYouSection(),
                  if (homeProvider.selectedCategoryIndex == 1)
                    const MoviesSection(),
                  if (homeProvider.selectedCategoryIndex == 2)
                    const SeriesSection(),
                  if (homeProvider.selectedCategoryIndex == 3)
                    const PopularSection(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
