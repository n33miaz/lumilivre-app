import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumilivre/main.dart';
import 'package:lumilivre/models/user.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/favorites.dart';
import 'package:lumilivre/providers/theme.dart';
import 'package:lumilivre/screens/auth/login.dart';
import 'package:lumilivre/screens/navigator_bar.dart';
import 'package:lumilivre/services/auth_storage.dart';

Widget buildBootstrappedApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) {
          final authProvider = AuthProvider();
          unawaited(authProvider.tryAutoLogin());
          return authProvider;
        },
      ),
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ChangeNotifierProvider(create: (context) => FavoritesProvider()),
    ],
    child: const LumiLivreApp(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('mostra splash enquanto tenta restaurar a sessao', (
    tester,
  ) async {
    await tester.pumpWidget(buildBootstrappedApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('restaura sessao salva e abre a navegacao principal', (
    tester,
  ) async {
    final user = LoginResponse(
      id: 7,
      token: 'jwt-token',
      email: 'aluno@lumilivre.test',
      role: 'ALUNO',
      isInitialPassword: false,
      matriculaAluno: '2024001',
    );

    FlutterSecureStorage.setMockInitialValues({
      AuthStorage.authTokenKey: user.token,
      AuthStorage.userDataKey: jsonEncode(user),
    });

    await tester.pumpWidget(buildBootstrappedApp());
    await tester.pump();

    expect(find.byType(MainNavigator), findsOneWidget);
  });
}
