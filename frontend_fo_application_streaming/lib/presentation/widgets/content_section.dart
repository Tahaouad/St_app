import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/core/models/content_item.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/contenttile.dart';

class ContentSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ContentItem> items;
  final VoidCallback onSeeAllPressed;

  const ContentSection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
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
                onPressed: onSeeAllPressed,
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
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return ContentTile(
                imageUrl: item.posterUrl,
                title: item.title,
                rating: item.rating,
                year: item.releaseYear,
                isNew: index == 0, // Marquer le premier élément comme nouveau
                onTap: () {
                  // TODO: Navigation vers les détails
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
