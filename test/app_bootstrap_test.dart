import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumilivre/main.dart';
import 'package:lumilivre/models/user.dart';
import 'package:lumilivre/providers/app_update_provider.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/content_provider.dart';
import 'package:lumilivre/providers/favorites.dart';
import 'package:lumilivre/providers/locale.dart';
import 'package:lumilivre/providers/settings.dart';
import 'package:lumilivre/providers/theme.dart';
import 'package:lumilivre/screens/auth/login.dart';
import 'package:lumilivre/screens/navigator_bar.dart';
import 'package:lumilivre/services/api_health.dart';
import 'package:lumilivre/services/auth_storage.dart';

Widget buildBootstrappedApp() {
  // Espelha a árvore de providers de main.dart (incluindo o gate de versão).
  return MultiProvider(
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
      ChangeNotifierProxyProvider<AuthProvider, FavoritesProvider>(
        lazy: false,
        create: (context) => FavoritesProvider(),
        update: (context, authProvider, favoritesProvider) =>
            favoritesProvider!..syncWithAuth(authProvider),
      ),
      ChangeNotifierProvider(create: (context) => LocaleProvider()),
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
      // O monitor de saúde da API entra desligado: sem `ApiHealth.enable()` ele
      // não pinga nada e a faixa de aviso fica fora da tela, que é o cenário de
      // servidor no ar que estes testes descrevem.
      ChangeNotifierProvider<ApiHealth>.value(value: ApiHealth.instance),
    ],
    child: const LumiLivreApp(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Singleton: sem isto um teste que ligasse o monitor deixaria o gancho de
    // falha instalado para o seguinte.
    ApiHealth.instance.resetForTest();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    // Sem o mock, PackageInfo.fromPlatform() nunca completa e o gate de
    // versão seguraria o app no splash para sempre no teste.
    PackageInfo.setMockInitialValues(
      appName: 'LumiLivre',
      packageName: 'br.com.lumilivre',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  testWidgets('mostra splash enquanto tenta restaurar a sessao', (
    tester,
  ) async {
    await tester.pumpWidget(buildBootstrappedApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Auto-login + fail-open do gate de versão: avança o relógio
    // fake além do timeout de 5s da consulta de versão.
    await tester.pump(const Duration(seconds: 6));
    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('restaura sessao salva e abre a navegacao principal', (
    tester,
  ) async {
    final user = LoginResponse(
      id: '7',
      token: 'jwt-token',
      email: 'leitor@lumilivre.test',
      role: 'READER',
      isInitialPassword: false,
      readerRegistrationNumber: '2024001',
    );

    FlutterSecureStorage.setMockInitialValues({
      AuthStorage.authTokenKey: user.token,
      AuthStorage.userDataKey: jsonEncode(user),
    });

    await tester.pumpWidget(buildBootstrappedApp());
    await tester.pump(const Duration(seconds: 6));
    await tester.pump();

    expect(find.byType(MainNavigator), findsOneWidget);
  });
}
