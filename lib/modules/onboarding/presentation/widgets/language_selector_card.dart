import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/controllers/language_controller.dart';

class LanguageSelectorCard extends StatelessWidget {

  LanguageSelectorCard({super.key});

  final language =
      Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {

    return Row(

      children: [

        Expanded(

          child: Card(

            child: ListTile(

              leading: const Text(
                "🇬🇧",
                style: TextStyle(fontSize:26),
              ),

              title: const Text("English"),

              onTap: () {
                language.changeLanguage("en");
              },

            ),

          ),

        ),

        const SizedBox(width:15),

        Expanded(

          child: Card(

            child: ListTile(

              leading: const Text(
                "🇫🇷",
                style: TextStyle(fontSize:26),
              ),

              title: const Text("Français"),

              onTap: () {
                language.changeLanguage("fr");
              },

            ),

          ),

        ),

      ],

    );

  }

}