import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/horizontal_list.dart';
import 'package:frontend_fo_application_streaming/services/auth_service.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/custom_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  bool _isAppBarExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _scrollController.addListener(_onScroll);

    // Pour une immersion totale
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
    // Calcul pour l'effet de fondu de la barre d'app
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

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _authService.getProfile();
      setState(() {
        _user = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Gérer l'erreur silencieusement ou afficher un toast
    }
  }

  Widget _buildFeaturedContent() {
    return Stack(
      children: [
        // Image d'arrière-plan
        Container(
          height: 600, // Légèrement plus grand pour un meilleur impact visuel
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/welcome.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black26, // Légèrement assombri pour mieux lire le texte
                BlendMode.darken,
              ),
            ),
          ),
        ),
        // Overlay gradient
        Container(
          height: 600,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withOpacity(0.1),
                AppColors.background.withOpacity(0.3),
                AppColors.background.withOpacity(0.7),
                AppColors.background.withOpacity(0.9),
                AppColors.background,
              ],
              stops: const [0.0, 0.3, 0.5, 0.8, 1.0],
            ),
          ),
        ),
        // Contenu texte et boutons
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge "Nouveau"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'EXCLUSIVITÉ',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Titre principal
                const Text(
                  "DEMOLIDOR: RENASCIDO",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                // Informations secondaires
                Row(
                  children: [
                    _buildRatingChip(),
                    const SizedBox(width: 12),
                    const Text(
                      '2023 • 4K Ultra HD',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Série • 4 saisons',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // Description courte
                const Text(
                  'Matt Murdock, aveugle depuis l\'enfance, combat l\'injustice le jour en tant qu\'avocat et la nuit en tant que justicier masqué dans les rues de Hell\'s Kitchen.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text(
                          'Lecture',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildActionIconButton(Icons.add, 'Ma liste'),
                    const SizedBox(width: 12),
                    _buildActionIconButton(Icons.info_outline, 'Infos'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.star, color: Colors.black, size: 16),
          SizedBox(width: 4),
          Text(
            '9.2',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIconButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textSecondary),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(icon, color: AppColors.textPrimary),
            iconSize: 20,
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_user == null) {
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
              const Text(
                'Utilisateur non connecté',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _loadUserProfile(),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      drawer: CustomDrawer(user: _user, authService: _authService),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 600,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor:
                _scrollOffset > 300 ? AppColors.background : Colors.transparent,
            elevation: _scrollOffset > 300 ? 8 : 0,
            title:
                _scrollOffset > 300
                    ? const Text(
                      'Moroccanflix',
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
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: SvgPicture.network(
                    _user?['avatar'] ?? 'https://i.pravatar.cc/150?img=11',
                  ),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildFeaturedContent(),
              collapseMode: CollapseMode.parallax,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _buildCategories(),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              _buildHorizontalListWithHeader(
                'Tendances actuelles',
                Icons.trending_up,
                List.generate(
                  10,
                  (index) =>
                      'https://image.tmdb.org/t/p/w500/${index % 2 == 0 ? 'q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg' : 'vZloFAK7NmvMGKE7VkF5UHaz0I.jpg'}',
                ),
              ),
              const SizedBox(height: 24),
              _buildHorizontalListWithHeader(
                'Nouveautés',
                Icons.new_releases,
                List.generate(
                  10,
                  (index) =>
                      'https://image.tmdb.org/t/p/w500/${index % 2 == 0 ? '8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg' : 'vZloFAK7NmvMGKE7VkF5UHaz0I.jpg'}',
                ),
              ),
              const SizedBox(height: 24),
              _buildHorizontalListWithHeader(
                'Recommandé pour vous',
                Icons.recommend,
                List.generate(
                  10,
                  (index) =>
                      'https://image.tmdb.org/t/p/w500/${index % 2 == 0 ? 'q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg' : '8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg'}',
                ),
              ),
              const SizedBox(height: 24),
              _buildHorizontalListWithHeader(
                'Populaire',
                Icons.star,
                List.generate(
                  10,
                  (index) =>
                      'https://image.tmdb.org/t/p/w500/${index % 2 == 0 ? 'vZloFAK7NmvMGKE7VkF5UHaz0I.jpg' : 'q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg'}',
                ),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['Pour vous', 'Séries', 'Films', 'Ma liste', 'Top 10'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = index == 0;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor:
                    isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color:
                        isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary.withOpacity(0.3),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalListWithHeader(
    String title,
    IconData icon,
    List<String> imageUrls,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text(
                      'Tout voir',
                      style: TextStyle(color: AppColors.primary, fontSize: 14),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.primary,
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        HorizontalList(title: '', imageUrls: imageUrls),
      ],
    );
  }
}
