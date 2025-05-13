import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend_fo_application_streaming/data/providers/content_provider.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/content_section.dart';

class ForYouSection extends StatelessWidget {
  const ForYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);

    return Column(
      children: [
        if (contentProvider.trendingContent.isNotEmpty)
          ContentSection(
            title: 'Tendances actuelles',
            icon: Icons.trending_up,
            items: contentProvider.trendingContent,
            onSeeAllPressed: () {
              // TODO: Navigate to all trending content
            },
          ),
        const SizedBox(height: 24),
        if (contentProvider.newReleases.isNotEmpty)
          ContentSection(
            title: 'Nouveautés',
            icon: Icons.new_releases,
            items: contentProvider.newReleases,
            onSeeAllPressed: () {
              // TODO: Navigate to all new releases
            },
          ),
        const SizedBox(height: 24),
        if (contentProvider.recommendedContent.isNotEmpty)
          ContentSection(
            title: 'Recommandé pour vous',
            icon: Icons.recommend,
            items: contentProvider.recommendedContent,
            onSeeAllPressed: () {
              // TODO: Navigate to all recommendations
            },
          ),
        const SizedBox(height: 24),
        if (contentProvider.popularContent.isNotEmpty)
          ContentSection(
            title: 'Populaire sur MoroccanFlix',
            icon: Icons.star,
            items: contentProvider.popularContent,
            onSeeAllPressed: () {
              // TODO: Navigate to all popular content
            },
          ),
      ],
    );
  }
}
