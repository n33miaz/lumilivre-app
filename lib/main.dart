import 'package:flutter/material.dart';

import 'package:lumilivre_app/screens/auth/login.dart';
import 'package:lumilivre_app/utils/constants.dart';

void main() {
  runApp(const LumiLivreApp());
}

class LumiLivreApp extends StatelessWidget {
  const LumiLivreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LumiLivre',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: LumiLivreTheme.primary,
        scaffoldBackgroundColor: LumiLivreTheme.background,
        colorScheme: ColorScheme.fromSeed(seedColor: LumiLivreTheme.primary),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: LumiLivreTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
              color: LumiLivreTheme.primary,
              width: 2.0,
            ),
          ),
          labelStyle: const TextStyle(color: LumiLivreTheme.label),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
