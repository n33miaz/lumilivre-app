import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/content_provider.dart';
import 'package:lumilivre/services/auth_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Chave do cache local do mural (prefixo + tag de idioma padrão). Semear o
/// cache é o que dá publicações ao provider sem rede no teste: `load` emite o
/// que está salvo antes de tentar revalidar.
const String _feedCacheKey = 'content_feed_cache_v1_pt-BR';

const String _token = 'jwt-token-mock-123';

String _sessionJson(String id) =>
    '{"id":"$id","email":"leitor@escola.com","role":"READER",'
    '"readerRegistrationNumber":"2025001","token":"$_token",'
    '"isInitialPassword":false}';

String _feed(List<DateTime> createdAt) => jsonEncode([
  for (var i = 0; i < createdAt.length; i++)
    {
      'id': 'c$i',
      'contentType': 'ANNOUNCEMENT',
      'title': 'Publicacao $i',
      'createdAt': createdAt[i].toIso8601String(),
    },
]);

/// Sessão restaurada do armazenamento seguro, do jeito que o app faz na
/// abertura — é o caminho que dá um `AuthProvider` autenticado sem servidor.
Future<AuthProvider> _session(String accountId) async {
  FlutterSecureStorage.setMockInitialValues({
    AuthStorage.authTokenKey: _token,
    AuthStorage.userDataKey: _sessionJson(accountId),
  });
  final auth = AuthProvider();
  await auth.tryAutoLogin();
  return auth;
}

Future<ContentProvider> _loadedProvider(AuthProvider auth) async {
  final provider = ContentProvider()..syncWithAuth(auth);
  // A leitura do marcador é assíncrona: espera o disco antes de conferir.
  await pumpEventQueue();
  await provider.load(_token);
  return provider;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final agora = DateTime(2025, 3, 10, 12);
  final ontem = DateTime(2025, 3, 9, 12);
  final anteontem = DateTime(2025, 3, 8, 12);

  setUp(() {
    SharedPreferences.setMockInitialValues({
      _feedCacheKey: _feed([anteontem, ontem, agora]),
    });
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('marcador de publicacao nao vista', () {
    test('sem marcador, o mural inteiro conta como novidade', () async {
      final provider = await _loadedProvider(await _session('7'));

      expect(provider.items, hasLength(3));
      expect(provider.unseenCount, 3);
    });

    test('markSeen zera a contagem e grava o marcador da conta', () async {
      final provider = await _loadedProvider(await _session('7'));

      await provider.markSeen();

      expect(provider.unseenCount, 0);
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('mural_last_seen_v1_7'),
        agora.toIso8601String(),
      );
    });

    /// O ponto do marcador ser persistido: abrir o app de novo não pode
    /// reacender o selo sobre o que já foi lido.
    test('o marcador sobrevive a reabertura do app', () async {
      final auth = await _session('7');
      await (await _loadedProvider(auth)).markSeen();

      final reaberto = await _loadedProvider(auth);

      expect(reaberto.unseenCount, 0);
    });

    test('publicacao mais nova que o marcador volta a contar', () async {
      final auth = await _session('7');
      await (await _loadedProvider(auth)).markSeen();

      SharedPreferences.setMockInitialValues({
        'mural_last_seen_v1_7': agora.toIso8601String(),
        _feedCacheKey: _feed([ontem, agora, DateTime(2025, 3, 11, 8)]),
      });
      final depois = await _loadedProvider(auth);

      expect(depois.unseenCount, 1);
    });

    /// O marcador é da conta, não do aparelho: quem entra depois no mesmo
    /// celular não pode herdar o "já vi" de outra pessoa.
    test('outra conta no mesmo aparelho comeca sem marcador', () async {
      await (await _loadedProvider(await _session('7'))).markSeen();

      final outra = await _loadedProvider(await _session('99'));

      expect(outra.unseenCount, 3);
    });

    test('sem sessao nao ha o que marcar', () async {
      final provider = ContentProvider();

      await provider.markSeen();

      expect(provider.unseenCount, 0);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('mural_last_seen_v1_7'), isNull);
    });
  });
}
