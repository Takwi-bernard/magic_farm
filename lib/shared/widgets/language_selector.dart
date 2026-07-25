import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/language_controller.dart';

class LanguageSelector extends StatelessWidget {

  LanguageSelector({super.key});

  final controller = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {

    return DropdownButton<String>(

      value: controller.currentLocale.languageCode,

      items: const [

        DropdownMenuItem(

          value: "en",

          child: Text("English"),

        ),

        DropdownMenuItem(

          value: "fr",

          child: Text("Français"),

        ),

      ],

      onChanged: (value){

        if(value != null){

          controller.changeLanguage(value);

        }

      },

    );

  }

}