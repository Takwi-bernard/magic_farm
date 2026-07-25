import 'package:flutter/material.dart';
import 'app_colors.dart';


class AppTheme {
 

 // light theme 
  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,

     colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),

     appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
     ),
     inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none
      ),
     )
  );

//  dark theme 
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.black,

     colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),

     appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
     ),
     inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none
      ),
     )
  );
}