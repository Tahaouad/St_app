import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';

class ContentSectionSkeleton extends StatelessWidget {
  const ContentSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[700]!,
            child: Container(
              width: 150,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[700]!,
                child: Container(
                  width: 110,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FeaturedContentSkeleton extends StatelessWidget {
  const FeaturedContentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        height: 600,
        width: double.infinity,
        color: Colors.grey[800],
      ),
    );
  }
}
