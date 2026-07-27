import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/routes/app_routes.dart';

/// signInWithOAuth() only launches a browser — it returns before the
/// user has actually finished logging in. The real "you're signed in
/// now" moment happens later, when the OAuth provider redirects back
/// into the app via deep link and Supabase finishes the session
/// exchange. This is the piece that was missing: without something
/// listening for that moment, completing Google Sign-In wouldn't
/// navigate anywhere — the user would just be dropped back on
/// whatever screen the deep link landed on.
///
/// Call AuthGate.instance.start() once, early in app startup (e.g. in
/// bootstrap.dart, after Supabase.initialize() completes).
class AuthGate {
  AuthGate._();
  static final AuthGate instance = AuthGate._();

  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.signedIn) {
        Get.offAllNamed(AppRoutes.home);
      }

      if (event == AuthChangeEvent.signedOut) {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }
}