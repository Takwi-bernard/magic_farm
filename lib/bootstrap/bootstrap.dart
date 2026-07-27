import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/translations/app_translations.dart';
import '../modules/auth/auth_gate.dart';

class Bootstrap {
  Bootstrap._();

  static final Logger _logger = Logger();

  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");

      await GetStorage.init();

      // Must complete before runApp(), or GetMaterialApp's `translations:`
      // map is empty and every .tr call across the app (starting with
      // splash) renders raw keys instead of real text.
      await AppTranslations.load();

      // Supabase.initialize() talks to the network to restore/refresh
      // a session. On a poor or absent connection (the normal case for
      // this app) it can hang or fail. We never want that to block the
      // whole app from opening — offline-first means splash/onboarding/
      // browsing must still work. A timeout lets boot continue in a
      // degraded "not yet connected to Supabase" state instead of
      // stalling indefinitely; screens that need Supabase will handle
      // that absence explicitly (via core/network + core/offline).
      try {
        await Supabase.initialize(
          url: dotenv.env['SUPABASE_URL']!,
          publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
        ).timeout(const Duration(seconds: 5));
      } on TimeoutException {
        _logger.w(
          "Supabase.initialize() timed out — likely poor/no network. "
              "Continuing app boot in offline mode.",
        );
      }

      // GoogleSignIn v7 requires this one-time initialize() before
      // .authenticate() can be called anywhere else in the app.
      // serverClientId (the Web client) is what makes Google issue a
      // token Supabase can actually verify — Android's own client is
      // matched automatically via package name + SHA-1, so it isn't
      // passed here directly.
      try {
        await GoogleSignIn.instance.initialize(
          clientId: kIsWeb || defaultTargetPlatform == TargetPlatform.iOS
              ? dotenv.env['GOOGLE_IOS_CLIENT_ID']
              : null,
          serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
        );
      } catch (e) {
        _logger.w("GoogleSignIn initialize failed: $e");
      }

      // Starts listening for Supabase auth state changes app-wide.
      // Kept as a safety net — native Google sign-in below navigates
      // directly on success, but this still matters if you ever add
      // back a browser-based OAuth provider, which completes async
      // via deep link instead of a direct return value.
      AuthGate.instance.start();

      _logger.i("Bootstrap initialized successfully.");
    } catch (e, stackTrace) {
      _logger.e(
        "Bootstrap initialization failed",
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}