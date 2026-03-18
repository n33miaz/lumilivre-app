import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumilivre/providers/auth.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthProvider', () {
    late AuthProvider authProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      authProvider = AuthProvider();
    });

    group('estado inicial', () {
      test('deve começar sem usuário autenticado', () {
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.user, isNull);
      });

      test('deve começar sem modo convidado', () {
        expect(authProvider.isGuest, isFalse);
      });

      test('authAttempted deve ser false inicialmente', () {
        expect(authProvider.authAttempted, isFalse);
      });

      test('isInitialPassword deve ser false inicialmente', () {
        expect(authProvider.isInitialPassword, isFalse);
      });
    });

    group('loginAsGuest', () {
      test('deve ativar modo convidado', () {
        authProvider.loginAsGuest();
        expect(authProvider.isGuest, isTrue);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.user, isNull);
      });

      test('deve resetar isInitialPassword', () {
        authProvider.loginAsGuest();
        expect(authProvider.isInitialPassword, isFalse);
      });

      test('deve notificar listeners', () {
        int notifyCount = 0;
        authProvider.addListener(() => notifyCount++);
        authProvider.loginAsGuest();
        expect(notifyCount, 1);
      });
    });

    group('completeInitialPasswordChange', () {
      test('deve desativar flag de senha inicial', () {
        authProvider.completeInitialPasswordChange();
        expect(authProvider.isInitialPassword, isFalse);
      });

      test('deve notificar listeners', () {
        int notifyCount = 0;
        authProvider.addListener(() => notifyCount++);
        authProvider.completeInitialPasswordChange();
        expect(notifyCount, 1);
      });
    });

    group('logout', () {
      test('deve limpar estado ao fazer logout', () async {
        authProvider.loginAsGuest();
        expect(authProvider.isGuest, isTrue);
        await authProvider.logout();
        expect(authProvider.isGuest, isFalse);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.isInitialPassword, isFalse);
        expect(authProvider.user, isNull);
      });

      test('deve notificar listeners ao fazer logout', () async {
        authProvider.loginAsGuest();
        int notifyCount = 0;
        authProvider.addListener(() => notifyCount++);
        await authProvider.logout();
        expect(notifyCount, 1);
      });
    });

    group('tryAutoLogin', () {
      test('deve marcar authAttempted como true sem dados salvos', () async {
        await authProvider.tryAutoLogin();
        expect(authProvider.authAttempted, isTrue);
        expect(authProvider.isAuthenticated, isFalse);
      });

      test('deve restaurar usuário de dados salvos', () async {
        SharedPreferences.setMockInitialValues({
          'authToken': 'jwt-token-mock-123',
          'userData': '{"id":1,"email":"aluno@escola.com","role":"ALUNO","matriculaAluno":"2025001","token":"jwt-token-mock-123","isInitialPassword":false}',
        });
        final provider = AuthProvider();
        await provider.tryAutoLogin();
        expect(provider.isAuthenticated, isTrue);
        expect(provider.user?.email, 'aluno@escola.com');
        expect(provider.authAttempted, isTrue);
      });
    });

    group('transições de estado', () {
      test('guest -> logout -> sem estado', () async {
        authProvider.loginAsGuest();
        expect(authProvider.isGuest, isTrue);
        await authProvider.logout();
        expect(authProvider.isGuest, isFalse);
        expect(authProvider.isAuthenticated, isFalse);
      });
    });
  });
}
