import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';

class CustomAppBar extends StatelessWidget {
  final String username;
  final String avatarUrl;

  const CustomAppBar({
    required this.username,
    required this.avatarUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Row(
        children: [
          Image.asset('assets/logo.png', height: 30), // Ton logo si dispo
          const SizedBox(width: 10),
          const Text(
            'Streamy',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(username, style: const TextStyle(color: AppColors.textGray)),
          const SizedBox(width: 10),
          CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
        ],
      ),
    );
  }
}
