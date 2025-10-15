
import 'package:flutter/material.dart';

// Centralized theme configuration for the application.
class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.deepPurple,
    scaffoldBackgroundColor: Colors.grey[50],

    // Define the default font family for the experience.
    textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Arial'),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontFamily: 'Arial',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
    ),

    iconTheme: const IconThemeData(
      color: Colors.deepPurple,
    ),
  );
}
