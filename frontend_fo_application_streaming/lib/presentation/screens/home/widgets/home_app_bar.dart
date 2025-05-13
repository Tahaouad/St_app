import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';

class HomeAppBar extends StatelessWidget {
  final double scrollOffset;
  final Map<String, dynamic>? user;

  const HomeAppBar({super.key, required this.scrollOffset, required this.user});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 60,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor:
          scrollOffset > 100 ? AppColors.background : Colors.transparent,
      elevation: scrollOffset > 100 ? 8 : 0,
      title:
          scrollOffset > 100
              ? const Text(
                'MoroccanFlix',
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
          onPressed: () {
            // TODO: Implement search functionality
          },
        ),
        IconButton(
          icon: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: SvgPicture.network(
                user?['avatar'] ??
                    'https://api.dicebear.com/9.x/adventurer/svg?seed=Default',
                width: 36,
                height: 36,
              ),
            ),
          ),
          onPressed: () {
            // TODO: Implement profile menu
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
