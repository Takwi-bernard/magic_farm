import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../shared/services/local_auth_service.dart';

class SplashController extends GetxController {
  final GetStorage storage = GetStorage();

  static const _brandDelay = Duration(milliseconds: 1800);

  @override
  void onReady() {
    super.onReady();
    initialize();
  }

  Future<void> initialize() async {
    await Future.delayed(_brandDelay);

    try {
      final bool onboardingCompleted =
          storage.read<bool>('onboardingCompleted') ?? false;

      if (!onboardingCompleted) {
        Get.offAllNamed(AppRoutes.onboarding);
        return;
      }

      final bool hasSession =
          Supabase.instance.client.auth.currentSession != null;

      if (!hasSession) {
        // Never signed in, or a previous session was cleared
        // (logout) — needs full email/password (or Google) login.
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      // Already signed in from a previous visit — "sign in once," not
      // every time. Gate re-entry with a quick device unlock when the
      // device actually supports it, as a lightweight security layer
      // on top of the still-valid session.
      final bool localAuthAvailable =
      await LocalAuthService.instance.isAvailable();

      if (!localAuthAvailable) {
        // Nothing to gate with — skip straight to home. The user is
        // already authenticated via the persisted session; there's no
        // extra step to offer here.
        Get.offAllNamed(AppRoutes.home);
        return;
      }

      final bool unlocked = await LocalAuthService.instance.authenticate(
        reason: "Unlock Magic Farm",
      );

      if (unlocked) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        // Failed or cancelled the device prompt. Rather than loop
        // indefinitely, fall back to full login as the safety net.
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (_) {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}