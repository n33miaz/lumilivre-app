import 'package:flutter/material.dart';
import 'package:lumilivre_app/screens/auth/login.dart';

void main() {
  runApp(const LumiLivreApp());
}

// widget principal
class LumiLivreApp extends StatelessWidget {
  const LumiLivreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LumiLivre',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
    );
  }
}
