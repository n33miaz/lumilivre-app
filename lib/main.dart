import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/theme.dart';
import 'package:lumilivre/providers/favorites.dart';
import 'package:lumilivre/providers/locale.dart';
import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/screens/auth/login.dart';
import 'package:lumilivre/screens/navigator_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("Erro de Flutter capturado: ${details.exception}");
  };

  runZonedGuarded(
    () {
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) {
                final authProvider = AuthProvider();
                unawaited(authProvider.tryAutoLogin());
                return authProvider;
              },
            ),
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
            ChangeNotifierProvider(create: (context) => FavoritesProvider()),
            ChangeNotifierProvider(create: (context) => LocaleProvider()),
          ],
          child: const LumiLivreApp(),
        ),
      );
    },
    (error, stack) {
      debugPrint("Erro Assíncrono Global: $error");
    },
  );
}

class LumiLivreApp extends StatelessWidget {
  const LumiLivreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, ThemeProvider, LocaleProvider>(
      builder: (context, auth, themeProvider, localeProvider, _) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        debugShowCheckedModeBanner: false,
        locale: localeProvider.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        theme: LumiLivreTheme.lightTheme,
        darkTheme: LumiLivreTheme.darkTheme,
        themeMode: themeProvider.currentTheme,

        home: !auth.authAttempted
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : auth.isAuthenticated || auth.isGuest
            ? const MainNavigator()
            : const LoginScreen(),
      ),
    );
  }
}
