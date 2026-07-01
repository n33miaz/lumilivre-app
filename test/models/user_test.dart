import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/models/user.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('LoginResponse', () {
    group('fromJson', () {
      test('deve parsear resposta de login completa', () {
        final user = LoginResponse.fromJson(UserFixtures.validLoginResponse);
        expect(user.id, '1');
        expect(user.email, 'leitor@escola.com');
        expect(user.role, 'READER');
        expect(user.readerRegistrationNumber, '2025001');
        expect(user.token, 'jwt-token-mock-123');
        expect(user.isInitialPassword, isFalse);
      });

      test('deve parsear usuário com senha inicial obrigatória', () {
        final user = LoginResponse.fromJson(UserFixtures.initialPasswordUser);
        expect(user.isInitialPassword, isTrue);
        expect(user.readerRegistrationNumber, '2025002');
      });

      test('deve aceitar a chave legada matriculaAluno', () {
        final user = LoginResponse.fromJson(UserFixtures.legacyLoginResponse);
        expect(user.readerRegistrationNumber, '2025003');
      });

      test('deve usar false como default para isInitialPassword', () {
        final json = Map<String, dynamic>.from(UserFixtures.validLoginResponse)
          ..remove('isInitialPassword');
        final user = LoginResponse.fromJson(json);
        expect(user.isInitialPassword, isFalse);
      });

      test('deve aceitar readerRegistrationNumber como null', () {
        final json = Map<String, dynamic>.from(UserFixtures.validLoginResponse)
          ..['readerRegistrationNumber'] = null;
        final user = LoginResponse.fromJson(json);
        expect(user.readerRegistrationNumber, isNull);
      });
    });

    group('toJson', () {
      test('deve serializar todos os campos', () {
        final user = LoginResponse.fromJson(UserFixtures.validLoginResponse);
        final json = user.toJson();
        expect(json['id'], '1');
        expect(json['email'], 'leitor@escola.com');
        expect(json['token'], 'jwt-token-mock-123');
        expect(json['initialPasswordChange'], isFalse);
      });
    });

    group('roundtrip', () {
      test('deve ser idempotente (fromJson -> toJson -> fromJson)', () {
        final original = LoginResponse.fromJson(
          UserFixtures.validLoginResponse,
        );
        final restored = LoginResponse.fromJson(original.toJson());
        expect(restored.id, original.id);
        expect(restored.email, original.email);
        expect(restored.token, original.token);
        expect(restored.isInitialPassword, original.isInitialPassword);
      });

      test('deve funcionar via JSON string encode/decode', () {
        final original = LoginResponse.fromJson(
          UserFixtures.validLoginResponse,
        );
        final jsonStr = jsonEncode(original.toJson());
        final restored = LoginResponse.fromJson(jsonDecode(jsonStr));
        expect(restored.id, original.id);
        expect(restored.token, original.token);
      });
    });

    group('loginResponseFromJson', () {
      test('deve parsear JSON string de login', () {
        final jsonStr = jsonEncode(UserFixtures.validLoginResponse);
        final user = loginResponseFromJson(jsonStr);
        expect(user.id, '1');
        expect(user.email, 'leitor@escola.com');
      });
    });
  });
}
