import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/models/library_settings.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/settings.dart';
import 'package:lumilivre/providers/theme.dart';
import 'package:lumilivre/screens/auth/login.dart';

/// App mínimo com a mesma vizinhança de providers que a tela de login espera,
/// e uma primeira rota qualquer para o login poder ser **empilhado** sobre ela —
/// que é o caso do convidado tocando em "Entrar" dentro do app.
Widget _appWith(AuthProvider auth) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: auth),
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Text('abrir login'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('login empilhado nao se fecha sozinho em modo convidado', (
    tester,
  ) async {
    // Regressão: o pop era disparado só por o usuário ser convidado, então a
    // rota se fechava no primeiro frame e todo botão "Entrar" do modo convidado
    // ficava inerte.
    final auth = AuthProvider()..loginAsGuest();

    await tester.pumpWidget(_appWith(auth));
    await tester.tap(find.text('abrir login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('entrar como convidado fecha o login empilhado', (tester) async {
    final auth = AuthProvider()..loginAsGuest();

    await tester.pumpWidget(_appWith(auth));
    await tester.tap(find.text('abrir login'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ENTRAR COMO CONVIDADO'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('abrir login'), findsOneWidget);
  });

  testWidgets('sem modo convidado a tela nao oferece entrada de visitante', (
    tester,
  ) async {
    final settings = SettingsProvider(
      loadSettings: (_) async => LibrarySettings.fromJson(const {
        'libraryType': 'SCHOOL',
        'guestAccessEnabled': false,
      }),
    );
    await settings.load('token-de-teste');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider<SettingsProvider>.value(value: settings),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ENTRAR COMO CONVIDADO'), findsNothing);
  });
}
