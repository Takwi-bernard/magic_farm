import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../auth/repositories/auth_repository.dart';

/// Placeholder — real profile module not built yet. Includes a
/// working logout button since that's genuinely useful even before
/// the full profile screen exists.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'coming_soon'.tr,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 30),
            OutlinedButton.icon(
              onPressed: () async {
                // Constructed directly rather than via Get.find() —
                // a returning user goes straight from splash to home
                // (see splash_controller.dart), so AuthController and
                // AuthRepository may never have been registered via
                // GetX this session. AuthRepository has no
                // dependencies of its own, so it's safe to create
                // standalone here.
                try {
                  await AuthRepository().signOut();
                } catch (_) {
                  // Even if the network sign-out call fails, still
                  // route to login — better than leaving someone
                  // stuck on a dead session.
                }
                Get.offAllNamed(AppRoutes.login);
              },
              icon: const Icon(Icons.logout),
              label: Text('logout'.tr),
            ),
          ],
        ),
      ),
    );
  }
}