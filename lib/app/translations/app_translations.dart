import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {

  static Map<String, Map<String, String>> translations = {};

  static Future<void> load() async {

    final en = json.decode(
      await rootBundle.loadString(
        "assets/translations/en.json",
      ),
    );

    final fr = json.decode(
      await rootBundle.loadString(
        "assets/translations/fr.json",
      ),
    );

    translations = {

      "en": Map<String, String>.from(en),

      "fr": Map<String, String>.from(fr),

    };

  }

  @override
  Map<String, Map<String, String>> get keys => translations;

}