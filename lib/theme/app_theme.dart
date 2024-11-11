import 'package:flutter/material.dart';

class AppTheme {
  // Define your colors
  static const Color primaryColor = Color(0xFF379D9D);
  static const Color secondaryColor = Color(0xFFEFE6E6);
  static const Color backgroundColor = Color(0xFF1C3D3F);
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF011A33), Color(0xFF000A14)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'RussoOne',
          fontSize: 24,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Sanchez',
          fontSize: 18,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'AlfaSlabOne',
          fontSize: 16,
          color: Color(0xFF379D9D),
        ),
      ),
    );
  }
}
