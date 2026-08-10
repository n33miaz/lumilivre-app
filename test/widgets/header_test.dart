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
import 'package:lumilivre/providers/theme.dart';
import 'package:lumilivre/widgets/header.dart';
import 'package:lumilivre/widgets/mural.dart';

/// Barra de status alta de propósito: é o caso em que o campo de busca e os
/// botões do topo do cabeçalho ocupam a mesma faixa de pixels.
const double _tallStatusBar = 60;

/// Largura da tela do teste; o centro dela é onde o título tem de cair.
const double _screenWidth = 800;

LibrarySettings _settings({required bool contents}) => LibrarySettings(
  libraryType: LibraryType.school,
  readerCanEditAvatar: true,
  guestAccessEnabled: true,
  features: SettingsFeatures(
    academicFields: true,
    ranking: true,
    contents: contents,
  ),
);

Future<Widget> _headerApp({
  required ThemeProvider theme,
  bool contents = true,
}) async {
  final settings = SettingsProvider(
    loadSettings: (_) async => _settings(contents: contents),
  );
  await settings.load('token-de-teste');

  return MultiProvider(
    providers: [
      // Convidado: o botão do mural existe, e nada é buscado na rede.
      ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider()..loginAsGuest(),
      ),
      ChangeNotifierProvider<SettingsProvider>.value(value: settings),
      ChangeNotifierProvider<ThemeProvider>.value(value: theme),
      ChangeNotifierProvider<ContentProvider>(create: (_) => ContentProvider()),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(_screenWidth, 600),
          padding: EdgeInsets.only(top: _tallStatusBar),
        ),
        child: const Scaffold(body: CustomHeader(title: 'LumiLivre')),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('o mural e um botao do cabecalho quando a feature esta ligada', (
    tester,
  ) async {
    await tester.pumpWidget(await _headerApp(theme: ThemeProvider()));
    await tester.pump();

    expect(find.byType(MuralButton), findsOneWidget);
  });

  testWidgets('sem a feature de conteudos o botao do mural nao existe', (
    tester,
  ) async {
    await tester.pumpWidget(
      await _headerApp(theme: ThemeProvider(), contents: false),
    );
    await tester.pump();

    expect(find.byType(MuralButton), findsNothing);
  });

  /// Antes o título era centralizado entre um botão de 36 e um vão de 48, com
  /// mais 10 de recuo: ficava ~11 px à direita do centro da tela.
  testWidgets('o titulo fica no centro da tela, com e sem o botao', (
    tester,
  ) async {
    await tester.pumpWidget(await _headerApp(theme: ThemeProvider()));
    await tester.pump();

    expect(
      tester.getCenter(find.text('LumiLivre')).dx,
      closeTo(_screenWidth / 2, 0.5),
    );

    await tester.pumpWidget(
      await _headerApp(theme: ThemeProvider(), contents: false),
    );
    await tester.pump();

    expect(
      tester.getCenter(find.text('LumiLivre')).dx,
      closeTo(_screenWidth / 2, 0.5),
    );
  });

  /// Regressão de ordem de pintura: o campo de busca era o último filho do
  /// `Stack`, então ficava por cima dos botões do topo — e num aparelho de barra
  /// de status alta ele engolia o toque deles sem nem parecer estar por cima.
  testWidgets('a busca nao rouba o toque dos botoes do cabecalho', (
    tester,
  ) async {
    final theme = ThemeProvider();
    await tester.pumpWidget(await _headerApp(theme: theme));
    // Duas passadas: a preferência de tema é lida do disco na primeira.
    await tester.pump();
    await tester.pump();
    expect(theme.isDarkMode, isFalse);

    final themeButton = tester.getRect(find.byType(InkWell).first);
    // O `Positioned` do cabeçalho é o campo de busca inteiro — a carta dele
    // absorve toque em toda a área, não só onde há texto.
    final search = tester.getRect(find.byType(Positioned));
    // A faixa onde os dois se sobrepõem precisa existir para o teste valer.
    expect(search.top, lessThan(themeButton.bottom));

    await tester.tapAt(
      Offset(themeButton.center.dx, (search.top + themeButton.bottom) / 2),
    );
    await tester.pump();

    expect(theme.isDarkMode, isTrue);
  });
}
