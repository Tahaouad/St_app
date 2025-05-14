import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/core/models/content_item.dart';
import 'package:frontend_fo_application_streaming/core/models/content_enums.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/featured_content.dart';
import 'package:frontend_fo_application_streaming/presentation/screens/content/content_details_screen.dart';

class HomeFeaturedSection extends StatelessWidget {
  final List<ContentItem> featuredContent;

  const HomeFeaturedSection({super.key, required this.featuredContent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: PageView.builder(
        itemCount: featuredContent.length,
        itemBuilder: (context, index) {
          final content = featuredContent[index];
          return FeaturedContent(
            title: content.title,
            description: content.description,
            imageUrl: content.posterUrl ??
                content.backdropUrl ??
                'assets/images/welcome.jpg',
            rating: content.rating,
            year: content.releaseYear.toString(),
            quality: '4K Ultra HD',
            type: content.type == ContentType.movie ? 'Film' : 'Série',
            onPlayPressed: () {
              // Navigation vers les détails du contenu
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContentDetailsScreen(
                    contentItem: content,
                  ),
                ),
              );
            },
            onAddToListPressed: () {
              // TODO: Ajouter aux favoris
            },
            onInfoPressed: () {
              // Navigation vers les détails
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
      ),
    );
  }
}
