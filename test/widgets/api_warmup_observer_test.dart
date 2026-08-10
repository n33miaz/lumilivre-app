import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumilivre/services/api_error.dart';
import 'package:lumilivre/services/api_health.dart';
import 'package:lumilivre/widgets/api_warmup_observer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final health = ApiHealth.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    health.resetForTest();
  });

  tearDown(health.resetForTest);

  testWidgets('a abertura do app e o que liga o monitor', (tester) async {
    // Antes de montar: uma falha de rede não muda nada, porque não há ninguém
    // escutando. É o que mantém os testes de unidade sem rede e sem timer.
    ApiException.fromError(const SocketException('sem rota'));
    expect(health.status, ApiHealthStatus.unknown);

    await tester.pumpWidget(const ApiWarmUpObserver(child: SizedBox.shrink()));

    ApiException.fromError(const SocketException('sem rota'));

    expect(health.isWaking, isTrue);

    health.resetForTest();
  });
}
