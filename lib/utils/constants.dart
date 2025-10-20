import 'package:flutter/material.dart';

// http://api.lumilivre.com.br:8080 (prod) - http://localhost:8080 (web) - http://10.0.2.2:8080 (mobile)
const String apiBaseUrl = 'http://localhost:8080';

class LumiLivreTheme {
  // cores do tema claro
  static const Color primary = Color(0xFF762075);
  static const Color label = Color(0xFFC964C5);
  static const Color lightBackground = Color(0xFFF3F4F6);
  static const Color lightText = Color(0xFF1F2937);
  static const Color lightCard = Colors.white;

  // cores do tema escuro
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkText = Colors.white;
  static const Color darkCard = Color(0xFF1F2937);

  // tema claro
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      labelStyle: const TextStyle(color: label),
    ),
  );

  // tema escuro
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      labelStyle: const TextStyle(color: label),
    ),
  );

  // tela de busca
  static const List<Color> genreCardColors = [
    Color(0xFFE13300), 
    Color(0xFF006450), 
    Color(0xFF8400E7), 
    Color(0xFF1E3264), 
    Color(0xFFE8115B), 
    Color(0xFF148A08), 
    Color(0xFFBC5900), 
    Color(0xFF7D4B32), 
  ];
}
