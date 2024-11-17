import 'package:flutter/material.dart';
import 'package:studysama/utils/colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'Montserrat', color: AppColors.text),
      bodyMedium: TextStyle(fontFamily: 'Montserrat', color: AppColors.text),
      titleLarge: TextStyle(fontFamily: 'Montserrat', color: AppColors.text, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, // Button background color
        foregroundColor: Colors.white, // Button text color
        textStyle: TextStyle(fontFamily: 'Montserrat', fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        //padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary, // Text color
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary, // Text color
        side: BorderSide(color: AppColors.primary, width: 2), // Border color and width
        textStyle: TextStyle(fontFamily: 'Montserrat', fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'Montserrat', color: Colors.white),
      bodyMedium: TextStyle(fontFamily: 'Montserrat', color: Colors.white),
      titleLarge: TextStyle(fontFamily: 'Montserrat', color: Colors.white70, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, // Button background color
        foregroundColor: Colors.white, // Button text color
        textStyle: TextStyle(fontFamily: 'Montserrat', fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent, // Text color
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent, // Text color
        side: BorderSide(color: AppColors.accent, width: 2), // Border color and width
        textStyle: TextStyle(fontFamily: 'Montserrat', fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    useMaterial3: true,
  );
}
