import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';

class NotLoggedInView extends StatelessWidget {
  const NotLoggedInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.primary, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Utilisateur non connecté',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Se connecter',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
