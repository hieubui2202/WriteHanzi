import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData buildTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF121418),
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF00CFFF),
        secondary: const Color(0xFF78E08F),
        error: const Color(0xFFFBBF24),
        surface: const Color(0xFF1A1D23),
      ),
      textTheme: GoogleFonts.notoSansScTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121418),
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00CFFF),
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF00CFFF).withOpacity(0.4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A1D23),
        contentTextStyle: GoogleFonts.notoSansSc(
          color: Colors.white,
          fontSize: 16,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
