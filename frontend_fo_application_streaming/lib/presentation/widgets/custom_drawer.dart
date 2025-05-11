import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/services/auth_service.dart';

class CustomDrawer extends StatelessWidget {
  final Map<String, dynamic>? user;
  final AuthService authService;

  const CustomDrawer({
    super.key,
    required this.user,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          // Section d'en-tête du drawer
          _buildHeader(context),

          // Sections des menus
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 8),
                _buildSectionHeader('NAVIGATION'),
                _buildDrawerItem(
                  context,
                  Icons.home_filled,
                  'Accueil',
                  isSelected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.search,
                  'Rechercher',
                  onTap: () {},
                ),
                _buildDrawerItem(
                  context,
                  Icons.movie_outlined,
                  'Films',
                  onTap: () {},
                ),
                _buildDrawerItem(context, Icons.tv, 'Séries', onTap: () {}),

                const Divider(
                  color: AppColors.textGray,
                  height: 32,
                  thickness: 0.5,
                  indent: 20,
                  endIndent: 20,
                ),

                _buildSectionHeader('MA BIBLIOTHÈQUE'),
                _buildDrawerItem(
                  context,
                  Icons.favorite_border,
                  'Ma liste',
                  onTap: () {},
                ),
                _buildDrawerItem(
                  context,
                  Icons.download_outlined,
                  'Téléchargements',
                  onTap: () {},
                ),
                _buildDrawerItem(
                  context,
                  Icons.history,
                  'Historique',
                  onTap: () {},
                ),

                const Divider(
                  color: AppColors.textGray,
                  height: 32,
                  thickness: 0.5,
                  indent: 20,
                  endIndent: 20,
                ),

                _buildSectionHeader('PROFIL'),
                _buildDrawerItem(
                  context,
                  Icons.person_outline,
                  'Mon compte',
                  onTap: () {},
                ),
                _buildDrawerItem(
                  context,
                  Icons.settings_outlined,
                  'Paramètres',
                  onTap: () {},
                ),
                _buildDrawerItem(
                  context,
                  Icons.help_outline,
                  'Aide et support',
                  onTap: () {},
                ),

                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),

          // Footer avec bouton de déconnexion
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final String userName = user?['name'] ?? 'Utilisateur';
    final String userEmail = user?['email'] ?? 'utilisateur@exemple.com';
    final String avatarUrl =
        user?['avatar'] ?? 'https://www.example.com/default_avatar.png';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar avec bordure
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: SvgPicture.network(
                    avatarUrl,
                    width: 60,
                    height: 60,
                    placeholderBuilder:
                        (context) => const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Informations utilisateur
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barre de progression d'abonnement
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Abonnement Premium',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '21 jours restants',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.3, // 30% du temps d'abonnement restant
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textGray,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    final Color itemColor =
        isSelected ? AppColors.primary : AppColors.textPrimary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: itemColor, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: itemColor,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing:
            isSelected
                ? Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
                : null,
        dense: true,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          // Afficher une boîte de dialogue de confirmation
          final bool? confirm = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  backgroundColor: AppColors.background,
                  title: const Text(
                    'Se déconnecter',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  content: const Text(
                    'Êtes-vous sûr de vouloir vous déconnecter ?',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: AppColors.textGray),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text(
                        'Se déconnecter',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          );

          if (confirm == true) {
            await authService.logout();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.textGray, width: 1),
          ),
        ),
        icon: const Icon(Icons.logout, color: AppColors.textPrimary),
        label: const Text(
          'Se déconnecter',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
