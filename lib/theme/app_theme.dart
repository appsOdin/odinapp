import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFFE66411);
  static const Color accentColor = Color(0xFFEC955F);
  static const Color buttonColor = Color(0xFF1E88E5);
  static const Color textColor = Color(0xFF222222);

  static ThemeData themeData = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: accentColor,
    ),
    scaffoldBackgroundColor: Color(0xFFF2F4F7),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        fontSize: 22,
        color: Colors.white,
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        fontSize: 23,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 16,
        color: textColor,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.white,
      )
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        textStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  );
}