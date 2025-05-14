// lib/presentation/screens/content/widgets/similar_content_section.dart
import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/core/models/content_item.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/content/content_details_screen.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/ContentTile.dart';

  final List<ContentItem> similarContent;

  const SimilarContentSection({
    super.key,
    required this.similarContent,
  });

  @override
  Widget build(BuildContext context) {
    if (similarContent.isEmpty) {
      return const Center(
        child: Text(
          'Aucun contenu similaire disponible',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: similarContent.length,
      itemBuilder: (context, index) {
        final content = similarContent[index];
        return ContentTile(
          imageUrl: content.posterUrl,
          title: content.title,
          rating: content.rating,
          year: content.releaseYear,
          onTap: () {
            // Navigation vers les détails du contenu similaire
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContentDetailsScreen(
                  contentItem: content,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
