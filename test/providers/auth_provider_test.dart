import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/services/auth_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthProvider', () {
    late AuthProvider authProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
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
      test('deve desativar flag de senha inicial', () async {
        await authProvider.completeInitialPasswordChange();
        expect(authProvider.isInitialPassword, isFalse);
      });

      test('deve notificar listeners', () async {
        int notifyCount = 0;
        authProvider.addListener(() => notifyCount++);
        await authProvider.completeInitialPasswordChange();
        expect(notifyCount, 1);
      });

      test('deve persistir flag de senha inicial como false', () async {
        FlutterSecureStorage.setMockInitialValues({
          AuthStorage.authTokenKey: 'jwt-token-mock-123',
          AuthStorage.userDataKey:
              '{"id":1,"email":"aluno@escola.com","role":"ALUNO","matriculaAluno":"2025001","token":"jwt-token-mock-123","isInitialPassword":true}',
        });
        final provider = AuthProvider();
        await provider.tryAutoLogin();

        await provider.completeInitialPasswordChange();

        final storage = AuthStorage();
        final savedUserData = jsonDecode(await storage.getUserData() ?? '{}');
        expect(provider.isInitialPassword, isFalse);
        expect(savedUserData['isInitialPassword'], isFalse);
      });
    });

    group('logout', () {
      test('deve limpar estado ao fazer logout', () async {
        FlutterSecureStorage.setMockInitialValues({
          AuthStorage.authTokenKey: 'jwt-token-mock-123',
          AuthStorage.userDataKey:
              '{"id":1,"email":"aluno@escola.com","role":"ALUNO","matriculaAluno":"2025001","token":"jwt-token-mock-123","isInitialPassword":false}',
        });
        authProvider = AuthProvider();
        authProvider.loginAsGuest();
        expect(authProvider.isGuest, isTrue);
        await authProvider.logout();
        expect(authProvider.isGuest, isFalse);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.isInitialPassword, isFalse);
        expect(authProvider.user, isNull);
        final storage = AuthStorage();
        expect(await storage.getToken(), isNull);
        expect(await storage.getUserData(), isNull);
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
        FlutterSecureStorage.setMockInitialValues({
          AuthStorage.authTokenKey: 'jwt-token-mock-123',
          AuthStorage.userDataKey:
              '{"id":1,"email":"aluno@escola.com","role":"ALUNO","matriculaAluno":"2025001","token":"jwt-token-mock-123","isInitialPassword":false}',
        });
        final provider = AuthProvider();
        await provider.tryAutoLogin();
        expect(provider.isAuthenticated, isTrue);
        expect(provider.user?.email, 'aluno@escola.com');
        expect(provider.authAttempted, isTrue);
      });

      test('deve migrar sessao legada antes de restaurar usuario', () async {
        SharedPreferences.setMockInitialValues({
          AuthStorage.authTokenKey: 'legacy-token',
          AuthStorage.userDataKey:
              '{"id":1,"email":"legado@escola.com","role":"ALUNO","matriculaAluno":"2025001","isInitialPassword":false}',
        });
        final provider = AuthProvider();

        await provider.tryAutoLogin();

        expect(provider.isAuthenticated, isTrue);
        expect(provider.user?.email, 'legado@escola.com');
        expect(provider.user?.token, 'legacy-token');

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(AuthStorage.authTokenKey), isNull);
        expect(prefs.getString(AuthStorage.userDataKey), isNull);
      });

      test(
        'deve limpar sessao segura quando dados salvos estao corrompidos',
        () async {
          FlutterSecureStorage.setMockInitialValues({
            AuthStorage.authTokenKey: 'jwt-token-mock-123',
            AuthStorage.userDataKey: '{json invalido',
          });
          final provider = AuthProvider();

          await provider.tryAutoLogin();

          expect(provider.authAttempted, isTrue);
          expect(provider.isAuthenticated, isFalse);
          final storage = AuthStorage();
          expect(await storage.getToken(), isNull);
          expect(await storage.getUserData(), isNull);
        },
      );
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
