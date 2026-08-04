import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/theme.dart';
import 'package:lumilivre/providers/favorites.dart';
import 'package:lumilivre/providers/locale.dart';
import 'package:lumilivre/providers/settings.dart';
import 'package:lumilivre/providers/content_provider.dart';
import 'package:lumilivre/providers/app_update_provider.dart';
import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/screens/auth/login.dart';
import 'package:lumilivre/screens/force_update.dart';
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
            ChangeNotifierProxyProvider<AuthProvider, SettingsProvider>(
              create: (context) => SettingsProvider(),
              update: (context, authProvider, settingsProvider) =>
                  settingsProvider!..syncWithAuth(authProvider),
            ),
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
            ChangeNotifierProvider(create: (context) => FavoritesProvider()),
            ChangeNotifierProvider(create: (context) => LocaleProvider()),
            // Proxy: o mural é segmentado por público — limpa memória e cache
            // local no logout/troca de usuário (ver ContentProvider.syncWithAuth).
            ChangeNotifierProxyProvider<AuthProvider, ContentProvider>(
              create: (context) => ContentProvider(),
              update: (context, authProvider, contentProvider) =>
                  contentProvider!..syncWithAuth(authProvider),
            ),
            ChangeNotifierProvider(
              create: (context) {
                final appUpdateProvider = AppUpdateProvider();
                unawaited(appUpdateProvider.check());
                return appUpdateProvider;
              },
            ),
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
    return Consumer4<AuthProvider, ThemeProvider, LocaleProvider,
        AppUpdateProvider>(
      builder:
          (context, auth, themeProvider, localeProvider, appUpdate, _) =>
              MaterialApp(
                onGenerateTitle: (context) =>
                    AppLocalizations.of(context)!.appTitle,
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

                // O gate de versão precede a autenticação: enquanto a
                // checagem ou o auto-login não terminam, mostramos o loader; se
                // bloqueado, a tela de atualização impede o acesso.
                home: (!auth.authAttempted || !appUpdate.checked)
                    ? const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      )
                    : appUpdate.isBlocked
                    ? ForceUpdateScreen(info: appUpdate.info)
                    : auth.isAuthenticated || auth.isGuest
                    ? const MainNavigator()
                    : const LoginScreen(),
              ),
    );
  }
}
