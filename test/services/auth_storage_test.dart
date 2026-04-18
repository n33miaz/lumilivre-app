import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/services/auth_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthStorage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('deve salvar token e dados do usuario no storage seguro', () async {
      final storage = AuthStorage();

      await storage.saveSession(
        token: 'jwt-token-mock-123',
        userData: '{"email":"aluno@escola.com"}',
      );

      expect(await storage.getToken(), 'jwt-token-mock-123');
      expect(await storage.getUserData(), '{"email":"aluno@escola.com"}');
    });

    test('deve limpar token e dados do usuario no logout', () async {
      FlutterSecureStorage.setMockInitialValues({
        AuthStorage.authTokenKey: 'jwt-token-mock-123',
        AuthStorage.userDataKey: '{"email":"aluno@escola.com"}',
      });
      final storage = AuthStorage();

      await storage.clearSession();

      expect(await storage.getToken(), isNull);
      expect(await storage.getUserData(), isNull);
    });

    test(
      'deve migrar sessao legada do SharedPreferences para storage seguro',
      () async {
        SharedPreferences.setMockInitialValues({
          AuthStorage.authTokenKey: 'legacy-token',
          AuthStorage.userDataKey: '{"email":"legado@escola.com"}',
        });
        final storage = AuthStorage();

        await storage.migrateLegacySession();

        expect(await storage.getToken(), 'legacy-token');
        expect(await storage.getUserData(), '{"email":"legado@escola.com"}');

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(AuthStorage.authTokenKey), isNull);
        expect(prefs.getString(AuthStorage.userDataKey), isNull);
      },
    );
  });
}
