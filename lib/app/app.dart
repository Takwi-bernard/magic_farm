import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/language_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'translations/app_translations.dart';

class MagicFarmApp extends StatelessWidget {
  MagicFarmApp({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<LanguageController>(
      init: Get.put(LanguageController()),

      builder: (controller) {

        return GetMaterialApp(

          debugShowCheckedModeBanner: false,

          title: "Magic Farm",

          theme: AppTheme.light,

          translations: AppTranslations(),

          locale: controller.currentLocale,

          fallbackLocale: const Locale("en"),

          initialRoute: AppRoutes.splash,

          getPages: AppPages.routes,

        );

      },

    );

  }
}