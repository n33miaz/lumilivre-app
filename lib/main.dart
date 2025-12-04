import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/theme.dart';
import 'package:lumilivre/providers/favorites.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/screens/auth/login.dart';
import 'package:lumilivre/screens/navigator_bar.dart';

void main() {
  // Garante que a engine do Flutter esteja pronta antes de tudo
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Captura erros de renderização (Tela vermelha da morte em dev, cinza em prod)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Aqui você poderia enviar para um serviço de logs (Sentry, Firebase Crashlytics)
    debugPrint("Erro de Flutter capturado: ${details.exception}");
  };

  // 2. Captura erros assíncronos que não foram tratados por try-catch
  runZonedGuarded(() {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthProvider()),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => FavoritesProvider()),
        ],
        child: const LumiLivreApp(),
      ),
    );
  }, (error, stack) {
    debugPrint("Erro Assíncrono Global: $error");
    // Evita que o app feche abruptamente em alguns casos
  });
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
