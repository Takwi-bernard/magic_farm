import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/translations/app_translations.dart';

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
