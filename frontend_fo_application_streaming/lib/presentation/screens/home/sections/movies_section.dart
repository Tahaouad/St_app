import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/data/providers/content_provider.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/content_section.dart';

class MoviesSection extends StatelessWidget {
  const MoviesSection({super.key});

  @override
  Widget build(BuildContext context) {
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
      onSeeAllPressed: () {
        // TODO: Navigate to all movies
      },
    );
  }
}
