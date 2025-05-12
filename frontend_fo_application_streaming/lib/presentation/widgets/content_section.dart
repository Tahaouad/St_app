import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/horizontal_list.dart';

class ContentSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> imageUrls;
  final VoidCallback onSeeAllPressed;

  const ContentSection({
    super.key,
    required this.title,
    required this.icon,
    required this.imageUrls,
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
        HorizontalList(title: '', imageUrls: imageUrls),
      ],
    );
  }
}
