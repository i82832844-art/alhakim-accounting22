import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF176BFF);
  static const secondary = Color(0xFF6C4DFF);
  static const surface = Color(0xFFF6F8FC);

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: surface,
        colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(width: 1.5, color: primary)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
}
