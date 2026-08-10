import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/services/api_error.dart';
import 'package:lumilivre/services/api_health.dart';
import 'package:lumilivre/widgets/offline_banner.dart';

const _testLocale = Locale('pt', 'BR');

Widget _appWithBanner() {
  return ChangeNotifierProvider<ApiHealth>.value(
    value: ApiHealth.instance,
    child: MaterialApp(
      locale: _testLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const OfflineBanner(
        child: Scaffold(body: Center(child: Text('conteúdo'))),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final health = ApiHealth.instance;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(_testLocale);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    health.resetForTest();
  });

  tearDown(health.resetForTest);

  testWidgets('servidor no ar nao mostra faixa nenhuma', (tester) async {
    await tester.pumpWidget(_appWithBanner());
    await tester.pump();

    expect(find.text('conteúdo'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('acordando'), findsNothing);
  });

  testWidgets('servidor dormindo tem faixa propria, com tempo e espera', (
    tester,
  ) async {
    health.enable(
      client: MockClient(
        (_) async => throw const SocketException('instância dormindo'),
      ),
    );
    // É assim que o app descobre: uma chamada qualquer não voltou.
    ApiException.fromError(const SocketException('instância dormindo'));

    await tester.pumpWidget(_appWithBanner());
    await tester.pump();

    // A mensagem é outra, não a de offline: aqui a rede do aparelho está
    // perfeita e quem não responde é o servidor.
    final wakingLabel = l10n.apiHealthWakingBanner('').trim();
    expect(find.textContaining(wakingLabel), findsOneWidget);
    expect(find.text(l10n.offlineBannerMessage), findsNothing);
    // Indicador de espera na faixa: sem ele a espera de minutos parece
    // travamento.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // A explicação longa sai uma vez, em aviso transitório; o que fica é a
    // faixa pequena. As duas coisas convivem no mesmo episódio.
    await tester.pump();

    expect(find.text(l10n.apiHealthWakingToast), findsOneWidget);
    expect(find.textContaining(wakingLabel), findsOneWidget);

    health.resetForTest();
  });
}
