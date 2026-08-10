import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/models/library_settings.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/content_provider.dart';
import 'package:lumilivre/providers/settings.dart';
import 'package:lumilivre/services/auth_storage.dart';
import 'package:lumilivre/widgets/mural.dart';

const String _token = 'jwt-token-mock-123';

const String _sessionJson =
    '{"id":"7","email":"leitor@escola.com","role":"READER",'
    '"readerRegistrationNumber":"2025001","token":"$_token",'
    '"isInitialPassword":false}';

/// Cache local do mural: é o que dá publicações ao provider sem servidor.
String _feed(int count) => jsonEncode([
  for (var i = 0; i < count; i++)
    {
      'id': 'c$i',
      'contentType': 'ANNOUNCEMENT',
      'title': 'Comunicado $i',
      'body': 'Corpo do comunicado $i',
      'createdAt': DateTime(2025, 3, i + 1, 12).toIso8601String(),
    },
]);

Future<Widget> _muralApp({required bool authenticated}) async {
  final settings = SettingsProvider(
    loadSettings: (_) async => LibrarySettings(
      libraryType: LibraryType.school,
      readerCanEditAvatar: true,
      guestAccessEnabled: true,
      features: SettingsFeatures(
        academicFields: true,
        ranking: true,
        contents: true,
      ),
    ),
  );
  await settings.load(_token);

  final auth = AuthProvider();
  if (authenticated) {
    await auth.tryAutoLogin();
  } else {
    auth.loginAsGuest();
  }

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: auth),
      ChangeNotifierProvider<SettingsProvider>.value(value: settings),
      ChangeNotifierProvider<ContentProvider>(
        create: (_) => ContentProvider()..syncWithAuth(auth),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Fundo roxo do cabeçalho é o contexto real do botão.
      home: const Scaffold(body: Center(child: MuralButton())),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'content_feed_cache_v1_pt-BR': _feed(3),
    });
    FlutterSecureStorage.setMockInitialValues({
      AuthStorage.authTokenKey: _token,
      AuthStorage.userDataKey: _sessionJson,
    });
  });

  testWidgets('o botao abre o mural num modal, com a lista dentro', (
    tester,
  ) async {
    await tester.pumpWidget(await _muralApp(authenticated: true));
    // Deixa o carregamento do feed (cache + tentativa de rede) terminar.
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MuralButton));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Comunicado 0'), findsOneWidget);
    expect(find.text('Comunicado 2'), findsOneWidget);
  });

  testWidgets('o modal fecha pelo botao de fechar', (tester) async {
    await tester.pumpWidget(await _muralApp(authenticated: true));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MuralButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  /// O selo é a razão de o botão existir no cabeçalho: ele acende sem ninguém
  /// abrir o mural, e apaga depois da visita.
  testWidgets('o selo conta o que nao foi visto e apaga apos a visita', (
    tester,
  ) async {
    await tester.pumpWidget(await _muralApp(authenticated: true));
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byType(MuralButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('3'), findsNothing);
  });

  testWidgets('sem sessao o modal convida ao login em vez de listar', (
    tester,
  ) async {
    await tester.pumpWidget(await _muralApp(authenticated: false));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MuralButton));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(MuralButton)))!;
    expect(find.text('Comunicado 0'), findsNothing);
    expect(find.byType(ListView), findsNothing);
    expect(find.text(l10n.muralLoginPrompt), findsOneWidget);
  });
}
