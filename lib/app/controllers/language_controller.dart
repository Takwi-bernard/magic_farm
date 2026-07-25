import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {

  final GetStorage _box = GetStorage();

  static const String key = "language";

  Locale get currentLocale {

    final code = _box.read<String>(key);

    return Locale(code ?? "en");
  }

  void changeLanguage(String languageCode) {

    _box.write(key, languageCode);

    Get.updateLocale(Locale(languageCode));

    update();
  }
}