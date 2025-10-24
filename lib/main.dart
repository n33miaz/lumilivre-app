import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/theme.dart';
import 'package:lumilivre/utils/constants.dart';

import 'package:lumilivre/screens/auth/login.dart';
import 'package:lumilivre/screens/navigator_bar.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const LumiLivreApp(),
    ),
  );
}

class LumiLivreApp extends StatelessWidget {
  const LumiLivreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, auth, themeProvider, _) => MaterialApp(
        title: 'LumiLivre',
        debugShowCheckedModeBanner: false,

        theme: LumiLivreTheme.lightTheme,
        darkTheme: LumiLivreTheme.darkTheme,
        themeMode: themeProvider.currentTheme,

        home: auth.isAuthenticated || auth.isGuest
            ? const MainNavigator()
            : const LoginScreen(),
      ),
    );
  }
}
