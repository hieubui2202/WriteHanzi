
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF58CC02); // Duolingo Green
  static const Color primaryDarkColor = Color(0xFF4AAE02);
  static const Color textColor = Color(0xFF4b4b4b);
  static const Color secondaryTextColor = Color(0xFF777777);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFF7F7F7);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: ThemeData.light().textTheme.copyWith(
        headlineSmall: const TextStyle(
          color: textColor,
          fontFamily: 'Arial',
          fontWeight: FontWeight.bold,
        ),
        titleLarge: const TextStyle(
          color: textColor,
          fontFamily: 'Arial',
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: const TextStyle(
          color: secondaryTextColor,
          fontFamily: 'Arial',
        ),
      ),
      appBarTheme: const AppBarTheme(
        color: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: secondaryTextColor),
        titleTextStyle: const TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
